//
//  ChatView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 16/5/23.
//
// swiftlint:disable function_body_length type_body_length file_length
import SwiftUI
import Speech
import AVFoundation

struct ChatView: View {
    @FocusState var textEditorFocused
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss
    @State private var showingSheet = false
    @State var text = ""
    @State var buttonText = "Copy"
    @State var myCopyText = "Copy"
    let pasteboard = UIPasteboard.general
    @State var saveText = ""
    @State var recording = false
    @ObservedObject var viewModel  = TextGeneratorViewModel.shared
    @State private var lastQuestion: String = ""
    @State private var showScannerSheet = false
    @State private var texts: [ScanData] = []
    @State private var textsAsStringArray: [String] = []
    @StateObject private var speaker = Speaker.shared
    @State private var selectedImageForTextExtraction: UIImage?
    @AppStorage("firstTimeEverOnCamera") var firstTimeEverOnCamera: Bool = true
    @State private var showTutorial = false
    @State private var contentOffset = CGPoint(x: 0.0, y: 0.0)
    @AppStorage("todaysRequestCount") var todaysRequestCount = 0
    @AppStorage("todayDate") var todaysDate = 0.0
    @State private var showInAppSheet = false
    @StateObject private var iapVM = InAppPurchaseViewModel.shared
    @AppStorage("appOpenCounts") var appOpenCounts = 0
    @Environment(\.requestReview) var requestReview

    var body: some View {
        NavigationView {
            VStack {
                UIScrollViewWrapper().overlay(content: {
                    if viewModel.model.count == 0 {
                        suggestionView()
                    }
                    chatResponseView()
                })
                Spacer()
                textEditorView()
                    .overlay(alignment: .topTrailing) {
                        HStack(spacing: 10) {
                            if !viewModel.question.isEmpty {
                                Button(action: {
                                    if firstTimeEverOnCamera {
                                        firstTimeEverOnCamera = false
                                        showTutorial = true
                                    } else {
                                        viewModel.fromSecondCamera = true
                                        showImageRecognitionActionSheet = true
                                    }
                                }, label: {
                                    Image("camera")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                    // .font(.system(size: 25))
                                    //  .foregroundColor(Color.black)
                                })
                                Button(action: {
                                    // viewModel.fromSecondMic = true
                                    realTimeButtonClick()
                                }, label: {
                                    if viewModel.isRecording {
                                        Image(systemName: "stop.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                            .font(.system(size: 25))
                                            .foregroundColor(Color.red)
                                    } else {
                                        Image("speaker")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                            .font(.system(size: 25))
                                            .foregroundColor(Color.black)
                                    }
                                }).disabled(!viewModel.isEnabled)
                            }
                            Button {
                                showingSheet = true
                            } label: {
                                HStack {
                                    Image("suggestionIcon")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                        .foregroundColor(.white)
                                    Text("Suggestions")
                                        .font(.system(size: 10))
                                        .bold()
                                }
                                .padding(8)
                                .frame(height: 30)
                                .background(AppColors.suggestionsColor)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                            }
                            // .scaleEffect(0.6)
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 8)
                        .background(.white)
                        .cornerRadius(8)
                        .offset(y: -33)
                    }
                    .background(.white)
            }.fullScreenCover(isPresented: $showTutorial, content: {
                CameraView(showActionSheet: $showImageRecognitionActionSheet, closeSheet: $showTutorial)
                    .clearModalBackground()
            })
            .sheet(isPresented: $showingSheet) {
                SuggestionsView()
            }
            .sheet(isPresented: $showScannerSheet, content: {
                self.makeScannerView()
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImageForTextExtraction)
            }
            .onChange(of: selectedImageForTextExtraction, perform: { newValue in
                if let image = newValue {
                    TextRecognizer.recognizeText(fromImage: image) { texts in
                        DispatchQueue.main.async {
                            self.viewModel.question = TextGeneratorViewModel.shared
                                .formatToCodeIfNecessary(from: texts.joined(separator: "\t"))
                        }
                    }
                }
            })
            .onAppear {
                viewModel.reset()
                viewModel.currentChatId = UUID().uuidString
                viewModel.historyList.removeAll()
                viewModel.messages.removeAll()
                viewModel.model.removeAll()
                viewModel.setUp()
                realTimeOnAppear()
                viewModel.historyList.removeAll()
                appOpenCounts += 1
                if appOpenCounts == 20 {
                    requestReview()
                }
            }.onDisappear {
                onDisappear()
            }
            .navigationTitle("AISocial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "chevron.backward")
                        .font(.title)
                        .onTapGesture {
                            dismiss()
                        }
                }
            })
            .confirmationDialog("Image to Text",
                                isPresented: $showImageRecognitionActionSheet, titleVisibility: .visible) {
                Button("Take Shots") {
                    showScannerSheet = true
                }

                Button("Select from Gallery") {
                    showImagePicker = true
                    viewModel.fromSecondCamera = false
                }
            }
        } .navigationViewStyle(.stack)
    }

    @State private var showImageRecognitionActionSheet = false
    @State private var showImagePicker = false

    private func textEditorView() -> some View {
        HStack {
            TextEditor(text: $viewModel.question)
                .focused($textEditorFocused)
                .frame(height: (textEditorFocused || !viewModel.question.isEmpty) ? 150 : 50)
                .padding(12)
                .overlay {
                    TextEditorShape(cornerRadius: 20, gap: 180, offset: 30)
                        .stroke(lineWidth: 2.0)
                        .foregroundColor(AppColors.buttonColor)
                        .overlay(alignment: .topLeading) {
                            Text("Enter to Message AI...")
                                .bold()
                                .offset(x: 60, y: -11)
                        }
                }
                .overlay(
                    HStack(spacing: 12) {
                        if viewModel.question.isEmpty {
                            Button(action: {
                                if firstTimeEverOnCamera {
                                    firstTimeEverOnCamera = false
                                    showTutorial = true
                                } else {
                                    showImageRecognitionActionSheet = true
                                }
                            }, label: {
                                Image("camera")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                // .font(.system(size: 25))
                                // .foregroundColor(Color.black)
                            })
                            Button(action: {
                                realTimeButtonClick()
                            }, label: {
                                Image(viewModel.isRecording ? "stop.circle.fill":"speaker")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 10)
                                    .font(.system(size: 25))
                                    .foregroundColor(viewModel.isRecording ? Color.red : Color.black)
                            }).disabled(!viewModel.isEnabled)
                        }
                    }
                    ,
                    alignment: .trailing
                )
                .overlay(alignment: .topTrailing, content: {
                    if textEditorFocused || !viewModel.question.isEmpty {
                        Image(systemName: "xmark")
                            .padding(20)
                            .contentShape(Rectangle())
                            .offset(x: 5, y: -10)
                            .onTapGesture {
                                viewModel.question = ""
                                turnOffMicrophone()
                                textEditorFocused = false
                            }
                    }
                })
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            textEditorFocused = false
                        }
                    }
                }
            if !viewModel.question.isEmpty {
                Button {
                    lastQuestion = viewModel.question
                    // in app purchase check
                    if iapVM.isActive {
                        viewModel.send()
                    } else {
                        let savedDate = Date(timeIntervalSince1970: todaysDate)
                        let notSameDay = !Calendar.current.isDate(Date(), inSameDayAs: savedDate)
                        if notSameDay {
                            todaysRequestCount = 0
                            todaysDate = Date().timeIntervalSince1970
                            viewModel.sendSuccess = false
                        }
                        if todaysRequestCount < 9 {
                            viewModel.send()
                        } else {
                            showInAppSheet = true
                            return
                        }
                    }
                    textEditorFocused = false
                    viewModel.fromSecondMic = false
                    if viewModel.isRecording {
                        // stop audio
                        realTimeButtonClick()
                        // start audio again
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                            realTimeButtonClick()
                        })
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(16)
                        .background(viewModel.isLoading ? AppColors.themeColor.opacity(0.5) :AppColors.themeColor)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .disabled(!viewModel.isComplete)
            }
        }
        .onChange(of: viewModel.sendSuccess) { success in
            if success {
                let savedDate = Date(timeIntervalSince1970: todaysDate)
                if Calendar.current.isDate(Date(), inSameDayAs: savedDate) {
                    todaysRequestCount += 1
                    viewModel.sendSuccess = false
                } else {
                    todaysRequestCount = 1
                    todaysDate = Date().timeIntervalSince1970
                    viewModel.sendSuccess = false
                }
            }
        }
        .fullScreenCover(isPresented: $showInAppSheet, content: {
            // IAPViews(show: $showInAppSheet)
            InAppPurchaseView()
        })
        .padding(16)
    }
    private func chatResponseView() -> some View {
        ScrollViewReader { reader in
            LazyVStack(alignment: .leading) {
                ForEach(0..<viewModel.model.count, id: \.self) { index in
                    let string  = viewModel.model[index]
                    if index % 2 == 0 {
                        VStack {
                            HStack(alignment: .bottom) {
                                Image("person")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding(.horizontal, 4)
                                    .offset(y: 10)
                                Text(string)
                                    .padding(.horizontal, 12)
                                    .padding(.top, 12)
                                    .background(AppColors.suggestionBgColor).clipShape(BubbleShape(myMessage: false))
                                Spacer()
                            }
                            HStack {
                                Button {
                                    self.text = string
                                    copyToClipboard(itIsMe: true)
                                } label: {
                                    HStack {
                                        Image(systemName: "doc.on.doc.fill")
                                        Text(myCopyText)
                                    }
                                }
                                .font(.system(size: 12))
                                .padding(6)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Capsule())
                                Spacer()
                            }
                            .padding(8)
                        }
                    } else {
                        VStack(alignment: .leading) {
                            HStack(alignment: .bottom) {
                                Spacer()
                                Text(string)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(12)
                                    .background(AppColors.suggestionBgColor).clipShape(BubbleShape(myMessage: true))
                                Image("icon")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(15)
                                    .padding(.horizontal, 4)
                                    .offset(y: 10)
                            }
                            HStack {
                                Button {
                                    self.text = string
                                    copyToClipboard(itIsMe: false)
                                } label: {
                                    HStack {
                                        Image(systemName: "doc.on.doc.fill")
                                        Text(buttonText)
                                    }
                                }
                                .font(.system(size: 12))
                                .padding(6)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Capsule())
                                Spacer()
                                regenerateButton
                                Spacer()
                                Button {
                                    if speaker.speaking {
                                        speaker.stopSpeaking()
                                    } else {
                                        speakResponse(text: string)
                                    }
                                } label: {
                                    HStack {
                                        Text( speaker.speaking ? "Stop" : "Listen")
                                        Image(systemName: speaker.speaking ? "stop.circle.fill" : "playpause.circle")
                                    }
                                }
                                .font(.system(size: 12))
                                .padding(6)
                                .background(speaker.speaking ? Color.gray.opacity(0.01) : Color.gray.opacity(0.1))
                                .clipShape(Capsule())
                            }
                            .padding(8)
                        }
                        .frame(width: UIScreen.main.bounds.width-32, alignment: .leading)
                    }
                }
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        LoadingDots(text: "")
                            .offset(y: -10)
                    }.padding(.horizontal, 30)
                }
                Spacer()
                    .frame(height: 1)
                    .id("1")
                    .padding(.bottom, 12)
                    .onChange(of: viewModel.model) { _ in
                        reader.scrollTo("1")
                    }
                    .onChange(of: viewModel.text) { _ in
                        reader.scrollTo("1")
                    }
            }
            .padding(16)
        }
    }
    private func makeScannerView() -> ScannerView {
        ScannerView(completion: { textPerPage in
            if let outputText = textPerPage?.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines) {
                let newScanData = ScanData(content: outputText)
                self.textsAsStringArray.append(outputText)
                self.texts.append(newScanData)
            }
            if viewModel.fromSecondCamera {
                viewModel.question += "\n" + textsAsStringArray.joined(separator: "\n")
            } else {
                viewModel.question = textsAsStringArray.joined(separator: "\n")
            }
            self.showScannerSheet = false
            viewModel.fromSecondCamera = false
        })
    }
    private func suggestionView() -> some View {
        VStack {
            HStack {
                Image("icon")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
                Spacer()
                Text("Hi! I am AISocial, you can send your message or get inspired from suggestions.🙂")
                    .lineLimit(3)
            }
            .padding(16)
            .foregroundColor(.black)
            HStack {
                Spacer()
                Button {
                    showingSheet = true
                } label: {
                    HStack {
                        Image("suggestionIcon")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.white)
                        Text("Suggestions")
                            .bold()
                    }
                    .padding(16)
                    .frame(height: 60)
                    .background(AppColors.suggestionsColor)
                    .cornerRadius(20)
                    .foregroundColor(.white)
                }
            }
            .padding(8)
        }
        .background(AppColors.suggestionBgColor)
    }
    private func onDisappear() {
        viewModel.fetchSpecificChat(withId: viewModel.currentChatId, fetchOnlyOneChat: true)
        if viewModel.currentSpecificChatsFromHistory.isEmpty {
            viewModel.deleteId(id: viewModel.currentChatId)
        }
        viewModel.currentChatId = ""
        speaker.stopSpeaking()
        viewModel.reset()
    }
    private var regenerateButton: some View {
        Button {
            viewModel.question = lastQuestion
            // in app purchase check
            if iapVM.isActive {
                viewModel.send()
            } else {
                let savedDate = Date(timeIntervalSince1970: todaysDate)
                let notSameDay = !Calendar.current.isDate(Date(), inSameDayAs: savedDate)
                if notSameDay {
                    todaysRequestCount = 0
                    todaysDate = Date().timeIntervalSince1970
                    viewModel.sendSuccess = false
                }
                if todaysRequestCount < 9 {
                    viewModel.send()
                } else {
                    showInAppSheet = true
                    return
                }
            }
        } label: {
            HStack {
                Image(systemName: "goforward")
                Text("Regenerate")
                    .font(.system(size: 12))
            }
        }
        .padding(6)
        .background(Color.gray.opacity(0.1))
        .clipShape(Capsule())
    }
    func speakResponse(text: String) {
        if !speaker.speaking {
            speaker.speak(msg: text, voiceLanguage: "en-US")
            speaker.speaking = true
        }
    }
    func copyToClipboard(itIsMe: Bool) {
        let parsed = self.text.replacingOccurrences(of: "ChatGPT:", with: "")
        pasteboard.string = parsed
        if itIsMe {
            myCopyText = "Copied!"
        } else {
            self.buttonText = "Copied!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if itIsMe {
                myCopyText = "Copy!"
            } else {
                self.buttonText = "Copy!"
            }
        }
    }
    func turnOffMicrophone() {
        if viewModel.audioEngine.isRunning {
            viewModel.question = ""
            viewModel.isRecording = false
            viewModel.audioEngine.stop()
            viewModel.recognitionRequest?.endAudio()
            viewModel.recognitionTask?.cancel()
            viewModel.isEnabled = false
            viewModel.audioEngine.reset()
        }
    }
    func realTimeButtonClick() {
        if viewModel.audioEngine.isRunning {
            viewModel.question = ""
            viewModel.isRecording = false
            viewModel.audioEngine.stop()
            viewModel.recognitionRequest?.endAudio()
            viewModel.recognitionTask?.cancel()
            viewModel.isEnabled = false
            viewModel.audioEngine.reset()
        } else {
            viewModel.question = ""
            if viewModel.audioEngine.inputNode.inputFormat(forBus: 0).channelCount == 0 {
                print("Not enough available inputs!")
                return
            }
            do {
                try viewModel.startRecording()
            } catch {
            }
        }
    }
    func realTimeOnAppear() {
        // Configure the SFSpeechRecognizer object already
        // stored in a local member variable.
        viewModel.speechRecognizer.delegate = viewModel
        // Asynchronously make the authorization request.
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Divert to the app's main thread so that the UI
            // can be updated.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    viewModel.isEnabled = true
                case .denied:
                    viewModel.isEnabled = false
                case .restricted:
                    viewModel.isEnabled = false
                case .notDetermined:
                    viewModel.isEnabled = false
                default:
                    viewModel.isEnabled = false
                }
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

class Speaker: NSObject, AVSpeechSynthesizerDelegate, ObservableObject {
    let synthesizer = AVSpeechSynthesizer()
    static let shared = Speaker()
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    @Published var speaking = false
    func speak(msg: String, voiceLanguage: String) {
        try? AVAudioSession.sharedInstance()
            .setCategory(.playback, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        let utterance = AVSpeechUtterance(string: msg)
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        let voice = AVSpeechSynthesisVoice(language: voiceLanguage)
        utterance.voice = voice
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("speech finished")
        speaking = false
        try? AVAudioSession.sharedInstance()
            .setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
    }
}

struct UIScrollViewWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // Update the scroll view if needed
    }
}
// swiftlint:enable function_body_length type_body_length file_length
