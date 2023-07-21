//
//  ContentView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 22/2/23.
//
// swiftlint:disable file_length function_body_length line_length type_body_length
import SwiftUI
import Speech
import AVFoundation

struct ContentView: View {
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    var coreDataManager = CoreDataManager.shared
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                Image("shapeImage")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: 150)
                    .ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    logo
                    Divider()
                        .frame(width: UIScreen.main.bounds.width/1.25)
                    Text("Type below to get answers Ask any open ended questions")
                        .font(.system(size: 15))
                        .lineLimit(2)
                    VStack {
                        typeHere
                        chatHistoryButton
                            .offset(y: -25)
                    }
                }
            }
        }
    }
    private var shape: some View {
        GeometryReader { geometry in
            Ellipse()
                .fill(AppColors.themeColor)
                .frame(width: geometry.size.width * 1.4, height: geometry.size.height * 1.9)
                .position(x: geometry.size.width / 1.5, y: geometry.size.height * 0.2)
                .shadow(radius: 3)
                .edgesIgnoringSafeArea(.all)
        }
        .frame(height: 200)
        .overlay {
            GeometryReader { geometry in
                Ellipse()
                    .fill(AppColors.shapeColor)
                    .frame(width: geometry.size.width * 1.5, height: geometry.size.height * 1.8)
                    .position(x: geometry.size.width / 1.3, y: geometry.size.height * 0.1)
                    .shadow(radius: 3)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    private var logo: some View {
        VStack {
            Image("icon")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150)
                .clipShape(Circle())
                Text("AISocial")
                    .bold()
                    .font(.system(size: 30))
                    .overlay(alignment: .trailing) {
                        setting
                            .offset(x: 50)
                    }
            VStack(alignment: .leading) {
                AIInformationLogo(iconName: "PdfGenius",
                                  textInformationName:
                        "This name conveys the app's ability to process and analyze PDF files quickly and accurately, using advanced AI algorithms and machine learning techniques.",
                                  textIconName: "PDF Genius")
                AIInformationLogo(iconName:
                                    "scan",
                                  textInformationName:
                                  "This name highlights the app's intelligent scanning capabilities, which enable users to capture and analyze text and images from PDFs using VisionKit and OpenAI.",
                                  textIconName: "Smart Scan")
                AIInformationLogo(iconName: "AIReview",
                                  textInformationName:
                                    "This name emphasizes the app's core purpose of providing AI-powered evaluations and reviews of PDF documents,while also conveying a sense of innovation and cutting-edge technology.",
                                  textIconName: "AI Review")
            }
            /*VStack(alignment: .leading, spacing: 4) {
                Text("Type to receive AI answers")
                    .bold()
                Text("Ask open ended questions")
                    .bold()
                Text("Use the camera to read text to send to AI")
                    .bold()
                Text("Load PDFs to Send To AI")
                    .bold()
                Text("Use suggested prompts for ideas ")
                    .bold()
                Text("Use Siri to speak your prompts or questions and hear the responses ")
                    .bold()
                    .fixedSize(horizontal: false, vertical: true)
            }
           */
        }
    }
    private var setting: some View {
        NavigationLink {
            SettingsView()
        } label: {
            Image("settingIcon")
                .resizable()
                .frame(width: 30, height: 30)
        }

    }
    private func AIInformationLogo(iconName: String, textInformationName: String, textIconName: String) -> some View {
        HStack {
               Image(iconName)
                    .resizable()
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading, spacing: 5) {
                    Text(textIconName)
                        .font(.system(size: 11))
                    Text(textInformationName)
                        .font(.system(size: 11))
                }
        }.padding(8)
    }
    @State private var gotoChat = false
    private var typeHere: some View {
        Button {
            gotoChat = true
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.buttonColor)
                .frame(height: 50)
                .padding(16)
                .overlay {
                    Text("Enter AI Here..")
                        .bold()
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                }
        }
        .fullScreenCover(isPresented: $gotoChat) {
            ChatView()
        }
    }

    @State private var gotoChatHistory = false
    private var chatHistoryButton: some View {
        Button {
            gotoChatHistory = true
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.buttonColor)
                .frame(height: 50)
                .padding(16)
                .overlay {
                    Text("AI History")
                        .bold()
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                }
        }
        .fullScreenCover(isPresented: $gotoChatHistory) {
            ChatHistoryView()
        }
    }
}

struct ChatHistoryView: View {
    @ObservedObject var viewModel  = TextGeneratorViewModel.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                if viewModel.recentChatIds.count == 0 {
                    VStack {
                        Text("Chat history is empty")
                    }
                } else {
                    ForEach(viewModel.recentChatIds, id: \.chatId) { id in
                        NavigationLink {
                            SpecificChatView(chatId: id.chatId ?? "-", chatIdEntity: id)
                        } label: {
                            Text(id.chatName ?? "-")
                                .lineLimit(2)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onAppear {
                viewModel.fetchChatIds()
            }
            .navigationTitle("Chat History")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "chevron.backward")
                        .font(.title)
                        .onTapGesture {
                            dismiss()
                    }
                }
            })
        }
    }
}

struct SpecificChatView: View {
    @ObservedObject var viewModel  = TextGeneratorViewModel.shared
    @State private var bottomInputSectionHeight = 0.0
    var chatId: String
    var chatIdEntity: ChatIdEntity
    @State var buttonText = "Copy"
    @State var myCopyText = "Copy"
    @State var text = ""
    let pasteboard = UIPasteboard.general
    @State private var lastQuestion: String = ""
    @State private var firstTime = true
    @State private var showSettings = false
    @State private var chatName = ""
    @State private var settingsDetent = PresentationDetent.medium
    @AppStorage("todaysRequestCount") var todaysRequestCount = 0
    @AppStorage("todayDate") var todaysDate = 0.0
    @State private var showInAppSheet = false
    @StateObject private var iapVM = InAppPurchaseViewModel.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                ScrollViewReader { scrollProxy in
                    VStack {
                        ForEach(0..<viewModel.model.count, id: \.self) { index in
                            let chat = viewModel.model[index]
                            HStack(alignment: .top) {
                                if index % 2 == 1 {
                                    VStack(alignment: .trailing) {
                                        HStack(alignment: .bottom) {
                                            Spacer()
                                            Text(chat)
                                                .padding(8)
                                                .background(AppColors.suggestionBgColor)
                                                .clipShape(BubbleShape(myMessage: true))
                                            Image("icon")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .cornerRadius(15)
                                                .padding(4)
                                                .offset(y: 10)
                                        }
                                        HStack {
                                            Button {
                                                self.text = chat
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
                                            regenerateButton
                                        }
                                        .padding(8)
                                    }
                                } else {
                                    HStack(alignment: .bottom) {
                                        Image("person")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .padding(4)
                                            .offset(y: 10)
                                        Text(chat)
                                            .padding(8)
                                            .background(AppColors.suggestionBgColor)
                                            .clipShape(BubbleShape(myMessage: false))
                                    }
                                }
                                Spacer()
                            }
                        }
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                LoadingDots(text: "")
                                    .offset(y: -10)

                            }.padding(.horizontal, 30)
                        }
                        Text("")
                            .id("bottom").onChange(of: viewModel.currentSpecificChatsFromHistory.count, perform: { _ in
                                scrollProxy.scrollTo("bottom")
                            })
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                    withAnimation {
                                        scrollProxy.scrollTo("bottom")
                                    }

                                })
                            }
                            .onChange(of: viewModel.textInHistory) { _ in
                                scrollProxy.scrollTo("bottom")
                            }
                    }
                }

            }
            .padding(.bottom, bottomInputSectionHeight + 10)
            .sheet(isPresented: $showSettings) {
                settingsView
                    .presentationDetents(
                        [.medium],
                        selection: $settingsDetent
                    )
            }

            ChatGPTInputView(fromHistory: true)
                .background(Color.white)
                .overlay {
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                bottomInputSectionHeight = geo.size.height

                            }
                    }
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
        .navigationTitle("Chat")
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gear")
                }

            }
        })
        .padding(16)
        .scrollIndicators(.hidden)
        .onAppear {
            viewModel.storeChatId = false
            viewModel.currentChatId = chatId
            viewModel.fetchSpecificChat(withId: chatId)
            viewModel.messages.removeAll()
            viewModel.model.removeAll()
            viewModel.currentSpecificChatsFromHistory.forEach({ chat in
                viewModel.messages.append(Message(id: UUID().uuidString, content: chat.chat ?? "-", createdAt: chat.createdAt ?? Date(), senderRole: chat.isItChatGPT ? .assistant : .user))
                viewModel.model.append(chat.chat ?? "-")
            })
           // viewModel.chatHistoryLastQuestion = viewModel.currentSpecificChatsFromHistory[viewModel.currentSpecificChatsFromHistory.count-2].chat ?? ""
        }
        .onDisappear {
            viewModel.reset()
            viewModel.storeChatId = true
            viewModel.responseFromHistory = false
        }
    }

    private var regenerateButton: some View {
        Button {
            viewModel.question = viewModel.chatHistoryLastQuestion
            // in-app purchase
            if iapVM.isActive {
                viewModel.send(fromHistory: true)
            } else {
                let savedDate = Date(timeIntervalSince1970: todaysDate)
                let notSameDay = !Calendar.current.isDate(Date(), inSameDayAs: savedDate)
                if notSameDay {
                    todaysRequestCount = 0
                    todaysDate = Date().timeIntervalSince1970
                    viewModel.sendSuccess = false
                }
                if todaysRequestCount < 9 {
                    viewModel.send(fromHistory: true)
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
    var settingsView: some View {
        VStack(spacing: 12) {
            Divider()
                .frame(width: 60, height: 10)
                .foregroundColor(.black)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 16)

            Spacer()

            TextField("Chat name", text: $chatName)
                .padding(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke()
                        .foregroundColor(.gray)
                }

            Button {
                CoreDataManager.shared.editChatName(chatIdEntity: chatIdEntity, chatName: chatName)
                showSettings = false
            } label: {
                Text("Change")
                    .padding(12)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .background(AppColors.themeColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(16)

            }

            Spacer()
        }
        .padding(16)
    }

    func typeWriter(at position: Int = 0, finalText: String) {
        if position == 0 {
            viewModel.textInHistory = ""
        }
        if position < finalText.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.viewModel.textInHistory.append(finalText[position])
                self.typeWriter(at: position + 1, finalText: finalText)
            }
        }
    }
}

struct ChatGPTInputView: View {
    @ObservedObject var viewModel  = TextGeneratorViewModel.shared
    @State private var showingSheet = false
    @State var fromHistory = false
    @State private var showScannerSheet = false
    @State private var texts: [ScanData] = []
    @State private var textsAsStringArray: [String] = []
    @FocusState var textEditorFocused
    @State private var showImageRecognitionActionSheet = false
    @State private var showImagePicker = false
    @State private var selectedImageForTextExtraction: UIImage?
    @AppStorage("firstTimeEverOnCamera") var firstTimeEverOnCamera: Bool = true
    @State private var showTutorial = false
    @AppStorage("todaysRequestCount") var todaysRequestCount = 0
    @AppStorage("todayDate") var todaysDate = 0.0
    @State private var showInAppSheet = false
    @StateObject private var iapVM = InAppPurchaseViewModel.shared

    var body: some View {
        VStack {
            HStack {
                TextEditor(text: $viewModel.question)
                    .frame(height: (textEditorFocused || !viewModel.question.isEmpty) ? 150 : 50)
                    .padding(12)
                    .focused($textEditorFocused)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke()
                            .foregroundColor(AppColors.buttonColor)
                    }
                    .onChange(of: viewModel.question, perform: { newValue in
                        print(newValue)
                    })
                    .overlay(
                        Text(viewModel.question.count>0 ? "" : "Write here...")
                            .padding(20)
                            .padding(.trailing, 20)
                            .foregroundColor(.gray)
                            .allowsHitTesting(false)
                        ,
                        alignment: .topLeading
                    ).overlay(alignment: .topTrailing, content: {
                        if textEditorFocused || !viewModel.question.isEmpty {
                            Image(systemName: "xmark")
                                .padding(20)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.question = ""
                                    textEditorFocused = false
                                    turnOffMicroPhone()
                                }
                        }
                    })
                    .overlay(
                        HStack {
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
                                      //  .foregroundColor(Color.black)
                                })

                                Button(action: {
                                    realTimeButtonClick()
                                }, label: {
                                    Image(viewModel.isRecording ?
                                          "stop.circle.fill":"speaker")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                     //   .font(.system(size: 25))
                                        .padding(12)
                                        .foregroundColor(viewModel.isRecording ? Color.red : Color.black)
                                }).disabled(!viewModel.isEnabled)
                            }
                        }
                        ,
                        alignment: .trailing
                    )
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
                        textEditorFocused = false
                        viewModel.responseFromHistory = true
                        viewModel.chatHistoryLastQuestion = viewModel.question
                        // in-app purchase
                        if iapVM.isActive {
                            viewModel.send(fromHistory: fromHistory)
                        } else {
                            let savedDate = Date(timeIntervalSince1970: todaysDate)
                            let notSameDay = !Calendar.current.isDate(Date(), inSameDayAs: savedDate)
                            if notSameDay {
                                todaysRequestCount = 0
                                todaysDate = Date().timeIntervalSince1970
                                viewModel.sendSuccess = false
                            }
                            if todaysRequestCount < 9 {
                                viewModel.send(fromHistory: fromHistory)
                            } else {
                                showInAppSheet = true
                                return
                            }
                        }

                        // stop audio
                        if viewModel.isRecording {
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
                            .background(viewModel.isLoading ? AppColors.themeColor.opacity(0.5) : AppColors.themeColor)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .disabled(!viewModel.isComplete)
                }
            }
        }
        .fullScreenCover(isPresented: $showTutorial, content: {
            CameraView(showActionSheet: $showImageRecognitionActionSheet, closeSheet: $showTutorial)
                .clearModalBackground()
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
        .confirmationDialog("Image to Text",
                            isPresented: $showImageRecognitionActionSheet, titleVisibility: .visible) {
            Button("Take Shots") {
                showScannerSheet = true
            }

            Button("Select from Gallery") {
                showImagePicker = true
            }
        }
        .sheet(isPresented: $showScannerSheet, content: {
            self.makeScannerView()
        })
        .onAppear {
            viewModel.setUp()
            realTimeOnAppear()
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
    }
    func turnOffMicroPhone() {
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

    private func makeScannerView() -> ScannerView {
        ScannerView(completion: { textPerPage in
            if let outputText = textPerPage?.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines) {
                let newScanData = ScanData(content: outputText)
                self.textsAsStringArray.append(outputText)
                self.texts.append(newScanData)
            }
            viewModel.question = textsAsStringArray.joined(separator: "\n")
            self.showScannerSheet = false
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(LaunchScreenStateManager())
    }
}

struct LoadingDots: View {
    var text: String
    var color: Color = .black

    @State var dotsCount = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundColor(dotsCount > 0 ? color : .clear)
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundColor(dotsCount > 1 ? color : .clear)
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundColor(dotsCount > 2 ? color : .clear)
        }
        .animation(.easeOut(duration: 0.2), value: dotsCount)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()) { _ in dotsAnimation() }
            .onAppear(perform: dotsAnimation)
    }

    func dotsAnimation() {
        withAnimation {
            dotsCount = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                dotsCount = 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                dotsCount = 2
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation {
                dotsCount = 3
            }
        }
    }
}

struct BubbleShape: Shape {
    var myMessage: Bool
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let bezierPath = UIBezierPath()
        if !myMessage {
            bezierPath.move(to: CGPoint(x: 20, y: height))
            bezierPath.addLine(to: CGPoint(x: width - 15, y: height))
            bezierPath.addCurve(to: CGPoint(x: width, y: height - 15),
                                controlPoint1: CGPoint(x: width - 8, y: height),
                                controlPoint2: CGPoint(x: width, y: height - 8))
            bezierPath.addLine(to: CGPoint(x: width, y: 15))
            bezierPath.addCurve(to: CGPoint(x: width - 15, y: 0),
                                controlPoint1: CGPoint(x: width, y: 8),
                                controlPoint2: CGPoint(x: width - 8, y: 0))
            bezierPath.addLine(to: CGPoint(x: 20, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 5, y: 15),
                                controlPoint1: CGPoint(x: 12, y: 0),
                                controlPoint2: CGPoint(x: 5, y: 8))
            bezierPath.addLine(to: CGPoint(x: 5, y: height - 10))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height),
                                controlPoint1: CGPoint(x: 5, y: height - 1),
                                controlPoint2: CGPoint(x: 0, y: height))
            bezierPath.addLine(to: CGPoint(x: -1, y: height))
            bezierPath.addCurve(to: CGPoint(x: 12, y: height - 4),
                                controlPoint1: CGPoint(x: 4, y: height + 1),
                                controlPoint2: CGPoint(x: 8, y: height - 1))
            bezierPath.addCurve(to: CGPoint(x: 20, y: height),
                                controlPoint1: CGPoint(x: 15, y: height),
                                controlPoint2: CGPoint(x: 20, y: height))
        } else {
            bezierPath.move(to: CGPoint(x: width - 20, y: height))
            bezierPath.addLine(to: CGPoint(x: 15, y: height))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height - 15),
                                controlPoint1: CGPoint(x: 8, y: height),
                                controlPoint2: CGPoint(x: 0, y: height - 8))
            bezierPath.addLine(to: CGPoint(x: 0, y: 15))
            bezierPath.addCurve(to: CGPoint(x: 15, y: 0),
                                controlPoint1: CGPoint(x: 0, y: 8),
                                controlPoint2: CGPoint(x: 8, y: 0))
            bezierPath.addLine(to: CGPoint(x: width - 20, y: 0))
            bezierPath.addCurve(to: CGPoint(x: width - 5, y: 15),
                                controlPoint1: CGPoint(x: width - 12, y: 0),
                                controlPoint2: CGPoint(x: width - 5, y: 8))
            bezierPath.addLine(to: CGPoint(x: width - 5, y: height - 12))
            bezierPath.addCurve(to: CGPoint(x: width, y: height),
                                controlPoint1: CGPoint(x: width - 5, y: height - 1),
                                controlPoint2: CGPoint(x: width, y: height))
            bezierPath.addLine(to: CGPoint(x: width + 1, y: height))
            bezierPath.addCurve(to: CGPoint(x: width - 12, y: height - 4),
                                controlPoint1: CGPoint(x: width - 4, y: height + 1),
                                controlPoint2: CGPoint(x: width - 8, y: height - 1))
            bezierPath.addCurve(to: CGPoint(x: width - 20, y: height),
                                controlPoint1: CGPoint(x: width - 15, y: height),
                                controlPoint2: CGPoint(x: width - 20, y: height))
        }
        return Path(bezierPath.cgPath)
    }
}

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

struct ClearBackgroundViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(ClearBackgroundView())
    }
}

extension View {
    func clearModalBackground() -> some View {
        self.modifier(ClearBackgroundViewModifier())
    }
}
// swiftlint:enable file_length function_body_length line_length type_body_length
