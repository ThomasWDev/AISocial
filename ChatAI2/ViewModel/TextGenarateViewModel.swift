//
//  ViewModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 1/3/23.
//
// swiftlint:disable line_length type_body_length file_length
import Foundation
import OpenAISwift
import Speech
import Combine
import Firebase

class TextGeneratorViewModel: NSObject, ObservableObject {
    static var shared = TextGeneratorViewModel()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    @Published var selectedLanguage: Language = .english {
        didSet {
            selectedLanguagePrompt = "Your response should be in \(selectedLanguage.rawValue). "
        }
    }
    var voiceLanguage: String {
        switch selectedLanguage {
        case .english:
            return "en-US"
        case .spanish:
            return "es-ES"
        }
    }
    @Published var selectedLanguagePrompt = "Your response should be in english. "
    @Published var chatHistoryLastQuestion = ""
    @Published var isRecording  = false
    @Published var isEnabled = false
    @Published var storeChatId = true
    @Published var currentChatId = ""
    @Published var question = ""
    @Published var imagePromptQuestion = ""
    @Published var fromPdfPrompts = false
    @Published var fromPdfSuggestions = false
    @Published var fromSecondMic = false
    @Published var fromSecondCamera = false
    @Published var isComplete = true
    @Published var pdfSuggestion = ""{
        didSet {
            question = question.replacingOccurrences(of: oldValue, with: "")
            question = pdfSuggestion + " " + question
        }
    }
    @Published var contentType = "" {
        didSet {
            makeSentence()
        }
    }
    @Published var chosenDescription = "" {
        didSet {
            makeSentence()
        }
    }
    @Published var chosenStyle = "" {
        didSet {
            makeSentence()
        }
    }
    @Published var composition = "" {
        didSet {
            makeSentence()
        }
    }
    @Published var model = [String]()
    @Published var isLoading: Bool = false
    @Published var recentChatIds = [ChatIdEntity]()
    @Published var currentSpecificChatsFromHistory = [ChatHistoryEntity]()
    var cancelAbles = Set<AnyCancellable>()
    @Published var counter: Int = 0
    private var client: OpenAISwift?
    private override init() {
        super.init()
        self.addQuestionSubscriber()
    }
    func reset() {
        question = ""
        isLoading = false
        model.removeAll()
        messages.removeAll()
    }
    private func makeSentence() {
        question = contentType + " " + chosenDescription + " " + chosenStyle + " " + composition
    }
    func deleteId(id: String) {
        CoreDataManager.shared.deleteId(id: id)
    }
    func addQuestionSubscriber() {
        $question
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .map { (text) -> String in
                self.searchFirestore(searchText: text)
                return text}.sink {_ in
                }
                .store(in: &cancelAbles)
    }
    private var database = Firestore.firestore()
    func searchFirestore(searchText: String) {
        database.collection("NewFuns")
            .whereField("funny", isEqualTo: searchText)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting document:\(error)")} else {
                    if let querySnapshot = querySnapshot {
                        for document in querySnapshot.documents {
                            let data  = document.data()
                            let funny = data["funny"] as? String ?? ""
                            print(funny, "SEARCH RESULT")}}
                }
            }
    }

    // Make pagination
    func fetchChatIds() {
        recentChatIds = CoreDataManager.shared.fetchChatIds(fetchLimit: 100)
    }
    func fetchSpecificChat(withId id: String, fetchOnlyOneChat: Bool = false) {
        if fetchOnlyOneChat {
            currentSpecificChatsFromHistory = CoreDataManager.shared.fetchChat(chatId: id, fetchLimit: 1)
        } else {
            currentSpecificChatsFromHistory = CoreDataManager.shared.fetchChat(chatId: id)
        }
    }
    func saveChatToFirestore(with id: String, isItChatGPT: Bool, chat: String) {
        guard !id.isEmpty, !chat.isEmpty else {
            return
        }
        database.collection("ChatHistory").addDocument(data: [
            "chatCreator": isItChatGPT ? "CHATGPT" : "USER",
            "chat": chat,
            "createdAt": Timestamp(date: Date()),
            "id": id,
            "chatName": ""
        ]) { err in
            if let err = err {
                print("Error writing chat: \(err)")
            } else {
                print("Chat successfully written!")
            }
        }
    }

    func setUp() {
        client = OpenAISwift(authToken: Constants.openAIApiKey)
    }

    var historyList = [String]()
    private var histoListText: String {
        if historyList.count > 1 {
            return historyList.joined(separator: " ")
        } else if historyList.count == 1 {
            return historyList[0]
        } else {
            return ""
        }
    }

    private let basePrompt = "You are ChatGPT, a large language model trained by OpenAI. Your answer should be as concise as possible. Keep proper spacing between sentences. "

    func generateChatGPTPrompt(from text: String) -> String {
        guard !text.lowercased().contains("thank you") && !text.lowercased().contains("thanks")  else {
            return text
        }
        var prompt = basePrompt + histoListText + text
        if prompt.count > 2500 && !historyList.isEmpty {
            _ = historyList.removeFirst()
            prompt = generateChatGPTPrompt(from: text)
        }
        return prompt
    }
    /*
    func send(text: String, completion: @escaping(String) -> Void) {
        let finalPrompt = generateChatGPTPrompt(from: text)
        print("finalPrompt: ", finalPrompt)
        client?.sendCompletion(with: finalPrompt, maxTokens: 256, completionHandler: { result in
            switch result {
            case.success(let model):
                let output = model.choices?.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? "-"
                if output.count <= 500 {
                    self.historyList.append(output)
                } else {
                    self.historyList.append(contentsOf: output.components(separatedBy: ".").map({$0 + ". "}).prefix(2))
                }
                completion(output)
            case .failure(let error):
                print(error)
                completion("There is an issue with your AI request, Please make sure it is under 3000 characters and try again.")
            }
            DispatchQueue.main.async {
                self.isLoading = false
            }
        })
    }
     */

    @Published var pdfResponse = ""
    @Published var connectedToInternet = false
    @Published var sendSuccess = false

    func send(fromHistory: Bool = false, fromPDF: Bool = false) {
        guard NetworkMonitor.shared.isConnected else {
            if fromHistory {
                return
            }
            self.model.append("\(question) \n")
            self.model.append("No Internet Connection is Available.")
            return
        }
        guard question.count <= 3000 else {
            self.model.append("Text is too large!! \n")
            self.model.append("The Max AI can process is 3000 characters per request. Please resubmit your document for review in sets or 3000 or less at a time.")
            return
        }

        guard !question.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        isLoading = true
        isComplete = false
        if !currentChatId.isEmpty && storeChatId {
            if let chatId = CoreDataManager.shared.fetchChatId(id: currentChatId), chatId.count == 0 {
                CoreDataManager.shared.saveChatId(chatId: currentChatId, chatName: question)
            }
        }
        model.append("\(question) \n")
        CoreDataManager.shared.saveChat(chatId: self.currentChatId, chat: self.question, isItChatGPT: false)
        if fromHistory {
            self.fetchMoreCurrentChat()
        }

        print("Question Sending..\(question)")
        // No Stream
        // sendMessage(fromHistory: fromHistory, fromPdf: fromPDF)

        // Stream
        sendAndGetStream(fromHistory: fromHistory, fromPdf: fromPDF)

        // This was done previously, now we are taking a better approach.
        /*
        send(text: question) { response in
            DispatchQueue.main.async {
                print("DEBUG RESPONSE: ", response)
                var trimmedResponse = response.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                CoreDataManager.shared.saveChat(chatId: self.currentChatId, chat: trimmedResponse, isItChatGPT: true)
                if fromHistory {
                    self.fetchMoreCurrentChat()
                } else {
                    if trimmedResponse == "" {
                        trimmedResponse = "There is an issue with your AI request, Please make sure it is under 3000 characters and try again."
                    }
                    self.model.append(trimmedResponse)
                }
                self.isLoading = false
            }
        }
        */
    }

    @Published var messages = [Message]()
    @Published var currentInput = ""
    private let openAIService = OpenAIService()

    func sendMessage(fromHistory: Bool, fromPdf: Bool = false) {
        let newMessage = Message(id: UUID().uuidString, content: (fromPdf ? selectedLanguagePrompt : "") + "Your response should be as concise as possible. " + question, createdAt: .now, senderRole: .user)
        messages.append(newMessage)
        print(newMessage.content, question, "testt")
        question = ""

        Task {
            let response = await openAIService.sendMessage(messages: messages)
            await MainActor.run {
                isLoading = false
            }
            guard let aiMessage = response?.choices.first?.message else {
                print("Had No Receive Message")
                return
            }

            await MainActor.run {
                self.sendSuccess = true
            }

            CoreDataManager.shared.saveChat(chatId: self.currentChatId, chat: aiMessage.content, isItChatGPT: true)
            print(aiMessage.role, "ROLE")
            let recievedMessage = Message(id: UUID().uuidString, content: aiMessage.content,
                                          createdAt: Date(),
                                          senderRole: SenderRole(rawValue: aiMessage.role) ?? .user)
            if fromHistory {
                await MainActor.run(body: {
                    self.fetchMoreCurrentChat()
                })
            } else {
                await MainActor.run {
                    var trimmedResponse = aiMessage.content
                    if trimmedResponse == "" {
                        trimmedResponse = "There is an issue with your AI request, Please make sure it is under 3000 characters and try again."
                    }
                    messages.append(recievedMessage)
                    self.model.append(trimmedResponse)
                }
            }
        }
    }

    // Stream Message
    func sendAndGetStream(fromHistory: Bool, fromPdf: Bool = false) {
        let newMessage = Message(id: UUID().uuidString, content: (fromPdf ? selectedLanguagePrompt : "") + "Your response should be as concise as possible. " + question, createdAt: .now, senderRole: .user)
        messages.append(newMessage)
        question = ""

        openAIService.sendStreamMessage(messages: messages).responseStreamString { [weak self] stream in
            guard let self = self else { return }
            switch stream.event {
            case .stream(let response):
                isLoading = false
                switch response {
                case .success(let string):
                    let streamResponse = self.parseStreamData(string)
                    streamResponse.forEach({ newMessageResponse in
                        guard let messageContent = newMessageResponse.choices.first?.delta.content else {
                            return
                        }

                        guard let existingMessageIndex = self.messages.lastIndex(where: {$0.id == newMessageResponse.id}) else {
                            let newMessage = Message(id: newMessageResponse.id, content: messageContent, createdAt: Date(), senderRole: .assistant)
                            self.messages.append(newMessage)
                            self.model.append(newMessage.content)
                            return
                        }

                        let newMessage = Message(id: newMessageResponse.id, content: self.messages[existingMessageIndex].content + messageContent, createdAt: Date(), senderRole: .assistant)
                        self.messages[existingMessageIndex] = newMessage
                        self.model[existingMessageIndex] = newMessage.content
                    })

                case .failure(let failure):
                    print("Something Wrong", failure)
                    self.model.append("Something is Wrong!")
                    CoreDataManager.shared.saveChat(chatId: self.currentChatId, chat: self.model.last ?? "-", isItChatGPT: true)
                }
            case .complete(let completeMessage):
                print("Complete", completeMessage)
                DispatchQueue.main.async {
                    self.sendSuccess = true
                }
                isComplete = true
                if (self.model.count % 2) == 0 {
                    // everything is okay
                } else {
                    self.model.append("Something is Wrong!")
                }
                CoreDataManager.shared.saveChat(chatId: self.currentChatId, chat: self.model.last ?? "-", isItChatGPT: true)
            }
        }
    }

    func parseStreamData(_ data: String) -> [ChatStreamCompletionResponse] {
        let responseString = data.split(separator: "data:").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)}).filter({!$0.isEmpty})
        let jsonDecoder = JSONDecoder()

        // print("RESPONSESTRING: ", responseString)

        return responseString.compactMap { jsonStirng in
            guard let jsonData = jsonStirng.data(using: .utf8), let streamResponse = try? jsonDecoder.decode(ChatStreamCompletionResponse.self, from: jsonData) else {
                return nil
            }
            return streamResponse
        }
    }

    @Published var responseFromHistory = false
    @Published var text = ""{
        didSet {
            if oldValue == ""{
                if self.model.last != ""{
                    self.model.append(text)}} else {
                if model.count % 2 == 0 {
                    self.model.removeLast()
                    self.model.append(text)}
            }
        }
    }
    @Published var textInHistory = ""
    func typeWriter(at position: Int = 0, finalText: String) {
        if position == 0 {
            text = ""
        }
        if position < finalText.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.text.append(finalText[position])
                self.typeWriter(at: position + 1, finalText: finalText)
            }
        }
    }

    func fetchMoreCurrentChat() {
        fetchSpecificChat(withId: currentChatId)
    }

    func isItCode(_ input: String) -> Bool {
        if input.contains("var ") || input.contains("let ") || input.contains("const ") {
            // this covers most of the programming languages
            return true
        } else if input.contains("(") && input.contains(")") && input.contains(";") && input.contains("{") && input.contains("}") {
            // this is c c++
            return true
        } else if input.contains(":") && input.contains("=") {
            // this is python code
            return true
        } else if input.contains("(") && input.contains(")") && input.contains("{") && input.contains("}") && input.contains("func ") {
            // this is swift
            return true
        } else {
            return false
        }
    }

    func formatToCodeIfNecessary(from input: String) -> String {
        guard isItCode(input) else { return input }
        var spaceNo = 0
        var result = ""

        for (index, char) in input.enumerated() {
            if char == ";"{
                result.append(";\n")
            } else if char == "{" {
                spaceNo += 1
                result.append(" {\n")
            } else if char == "}" {
                if spaceNo > 0 {
                    spaceNo -= 1
                }
                result.append("\n\(createSpace(number: spaceNo))}\n")
            } else if char == "\t" {
                result.append("\n")
            } else {
                let prevExits = (index - 1) >= 0
                if prevExits {
                    if input[index-1] == "\t" {
                        result.append("\(createSpace(number: spaceNo))\(char)")
                    } else {
                        result.append("\(char)")
                    }
                } else {
                    result.append("\(char)")
                }
            }
        }

        return result
    }

    func createSpace(number: Int) -> String {
        var space = ""
        if number > 0 {
            for _ in 0...number {
                space.append("   ")
            }
        }
        return space
    }

    var arrayOfLines: [String] = []
    @Published var mychunks: [String] = []

    func makeChunks(text: String) {
        DispatchQueue.main.async {
            self.mychunks.removeAll()
        }
        var chunks: [String] = []
        arrayOfLines.removeAll()
        arrayOfLines = text.components(separatedBy: ".")
        var lessThan500WordsChunk = ""
        var chunk = ""
        var count = 0

        arrayOfLines.forEach({
            count += 1
            lessThan500WordsChunk += ($0 + ". ")
            if lessThan500WordsChunk.count < 2500 {
                chunk += ($0 + ". ")
            }
            if lessThan500WordsChunk.count >= 2500 ||
                (lessThan500WordsChunk.count < 2500 && count == arrayOfLines.count) {
                chunks.append(chunk)
                lessThan500WordsChunk = $0
                chunk = $0
            }
        })
        DispatchQueue.main.async {
            self.mychunks = chunks
        }
    }
}

extension String {
    public subscript(_ idx: Int) -> Character {
        self[self.index(self.startIndex, offsetBy: idx)]
    }
}

extension TextGeneratorViewModel: SFSpeechRecognizerDelegate {
    func startRecording() throws {
        isRecording = true
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        recognitionRequest = nil
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetoothA2DP])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        let promptText = question + (question.isEmpty ? "" : " ")
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            if let result = result {
                // Update the text view with the results.

                self.question = promptText + result.bestTranscription.formattedString
                isFinal = result.isFinal
                print("Text \(result.bestTranscription.formattedString)")
            }
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isEnabled = true
            }
        }
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0);inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, _: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Starting Error: ", error)
        }
        // Let the user know to start talking.
        self.question = "(Go ahead, I'm listening)"
    }
    // MARK: SFSpeechRecognizerDelegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            isEnabled = true
            //           recordButton.setTitle("Start Recording", for: [])
        } else {
            isEnabled = false
            //           recordButton.setTitle("Recognition Not Available", for: .disabled)
        }
    }
    /*
     func fetchMessages(fromId:String, toId:String){
     
     FM.shared.firestore.collection(Keys.chat).document(fromId).collection(toId)
     .order(by: Keys.createdAt).addSnapshotListener { querySnapShot, err in
     
     if let err = err{
     self.errorMessage = err.localizedDescription
     print("DEBUG: ",err.localizedDescription)
     }else{
     querySnapShot?.documentChanges.forEach({ change in
     if change.type == .added{
     let doc = change.document
     do{
     let message = try doc.data(as: ChatMessage.self)
     self.chatMessages.append(message)
     }catch{
     print("err \(err?.localizedDescription ?? "Error")")
     }
     
     }
     })
     }
     }
     }
     */
}

enum Language: String, CaseIterable, Identifiable {
    var id: RawValue { rawValue }
    case english, spanish
}
// swiftlint:enable line_length type_body_length file_length
