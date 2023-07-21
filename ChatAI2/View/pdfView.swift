//
//  pdfView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 17/4/23.
//
// swiftlint:disable type_body_length function_body_length file_length
import SwiftUI
import PDFKit

struct PdfView: View {
    @State private var showingSheet = false
    @ObservedObject var viewModel  = TextGeneratorViewModel.shared
    var body: some View {
        NavigationStack {
                VStack(spacing: 0) {
                    nav
                    LocalConvertView(viewModel: viewModel)
                }
                .edgesIgnoringSafeArea(.all)
                 .navigationTitle("Send The Text To AI")
                 .navigationBarHidden(true)
                .navigationBarTitleDisplayMode(.automatic)
        }
    }
    var nav: some View {
        ZStack(alignment: .top) {
            Image("topShape")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: 150)
            HStack(alignment: .center) {
                Spacer()
                Text("Send The Text To AI")
                  .padding(.trailing, 32)
                Spacer()
            }
            .bold()
            .font(.system(size: 30))
            .padding(.top, 70)
            .foregroundColor(.white)
            .background(AppColors.themeColor)
        }
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
                    showingSheet.toggle()
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
                .sheet(isPresented: $showingSheet) {
                    PdfSuggestionsView()
                }

            }
            .padding(16)
        }
        .background(AppColors.suggestionBgColor)
    }

    func localConvertPdfToText(url: URL) {
        if let pdf = PDFDocument(url: url) {
            let pageCount = pdf.pageCount
            let documentContent = NSMutableAttributedString()
            for index in 0 ..< pageCount {
                guard let page = pdf.page(at: index) else { continue }
                guard let pageContent = page.attributedString else { continue }
                documentContent.append(pageContent)
                // self.localText = pageContent
                documentContent.append(pageContent)
            }
            print("debug", documentContent.string)

            if documentContent.string.count > 2500 {
                viewModel.makeChunks(text: documentContent.string)
            } else {
                viewModel.question = documentContent.string
            }
        }
    }
}

struct PdfView_Previews: PreviewProvider {
    static var previews: some View {
        PdfView()
    }
}

struct LocalConvertView: View {
    @State private var selectedTheme = "Dark"
        let themes = ["Dark", "Light", "Automatic"]
    @State private var showingSheet = false
    @FocusState var textEditorFocused
    @StateObject private var speaker = Speaker.shared
    @State private var lastQuestion: String = ""
    @State private var presentImporter = false
    @State var buttonText = "Copy to clipboard"
    let pasteboard = UIPasteboard.general
    @State var text = ""
    @ObservedObject var viewModel: TextGeneratorViewModel
    @State private var pdfText = ""
    @State private var pdfTextLoading = false
    @State private var shouldShowChunkView = false
    // @StateObject private var pdfVM = PDFViewMoel()
    @State private var pretendText = ""
    @State private var pdfIsClickedBools = [Bool]()
    @State private var shouldCollapse = false
    @State private var showPDFAlert = false
    @State private var errorMessage = ""
    @AppStorage("todaysRequestCount") var todaysRequestCount = 0
    @AppStorage("todayDate") var todaysDate = 0.0
    @State private var showInAppSheet = false
    @StateObject private var iapVM = InAppPurchaseViewModel.shared

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                chatResponseView()
                Spacer()
                if shouldCollapse {
                    collapseView
                } else {
                    inputSection
                        .overlay(alignment: .top) {
                            HStack {
                                Spacer()
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 25))
                            }
                            .overlay {
                                Divider()
                                    .frame(width: 50, height: 6)
                                    .background(.black)
                                    .clipShape(Capsule())
                                    .gesture(
                                        DragGesture()
                                            .onChanged { _ in
                                                shouldCollapse = true
                                            }
                                    )

                            }
                            .overlay(alignment: .top) {
                                Divider()
                            }
                            .background(.white)
                            .cornerRadius(6)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                shouldCollapse = true
                            }
                            .offset(y: -65)
                        }
                        .padding(.top, 32)
                }
            }
            .alert(errorMessage, isPresented: $showPDFAlert) {
                Button("OK", role: .cancel) { }
            }
            /*
            .onChange(of: pdfVM.latestPDFLink, perform: { newValue in
                if !newValue.isEmpty {
                    viewModel.question =  "Summarize the pdf from the link below \n : "+pdfVM.latestPDFLink
                }
            })
            .alert(pdfVM.errorMessage, isPresented: $pdfVM.showAlert) {
                Button("OK", role: .cancel) { }
            }*/
            .showLoadingView(viewModel.isLoading, loadingText: "AI is reviewing, please wait.")
            .onAppear {
                viewModel.reset()
                viewModel.setUp()
                viewModel.currentChatId = UUID().uuidString
                viewModel.fromPdfPrompts = true
            }
            .padding(16)
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
            .onDisappear {
                onDisappear()
            }
        } .navigationViewStyle(.stack)
    }

    private var collapseView: some View {
        HStack {
            Spacer()
            Image(systemName: "arrow.up")
                .font(.system(size: 25))
        }
        .overlay {
            Text("Expand")
        }
        .background(.gray.opacity(0.2))
        .cornerRadius(6)
        .contentShape(Rectangle())
        .onTapGesture {
            shouldCollapse = false
        }
    }

    private var inputSection: some View {
        VStack {
            textEditorView()
            openPdfFileButtonView()
                .fileImporter(isPresented: $presentImporter, allowedContentTypes: [.pdf]) { result in
                    pdfTextLoading = true
                    DispatchQueue.global().async {
                        do {
                            let fileURL = try result.get()
                            _ = fileURL.startAccessingSecurityScopedResource()
                            DispatchQueue.main.async {
                                viewModel.question = ""
                            }
                           // pdfVM.uploadPdfToStorage(with: fileURL)
                            guard let pdf = PDFDocument.init(url: fileURL) else {
                                DispatchQueue.main.async {
                                    pdfTextLoading = false
                                    // show pdf damage alert
                                    errorMessage = "Your PDF is Damaged or Empty!"
                                    showPDFAlert = true
                                }
                                return print("error pdf")
                            }
                            let pageCount = pdf.pageCount
                            let documentContent = NSMutableAttributedString()
                            print("Total page: \(pageCount)")
                            for index in 0..<pageCount {
                                guard let page = pdf.page(at: index) else { continue }
                                guard let pageContent = page.attributedString else { continue }
                                // print("page content: \(pageCount)")
                                documentContent.append(pageContent)
                            }
                            fileURL.stopAccessingSecurityScopedResource()
                            DispatchQueue.main.async {
                                viewModel.mychunks.removeAll()
                                pdfIsClickedBools.removeAll()
                                viewModel.question = ""
                                viewModel.question = viewModel.fromPdfSuggestions ? viewModel.pdfSuggestion :  ""
                            }
                            if documentContent.string.count > 2500 {
                                viewModel.makeChunks(text: documentContent
                                    .string.trimmingCharacters(in: .whitespacesAndNewlines))
                                DispatchQueue.main.async {
                                    for _ in 1...viewModel.mychunks.count {
                                        pdfIsClickedBools.append(false)
                                    }
                                }
                                shouldShowChunkView = true
                                pdfTextLoading = false
                            } else if documentContent.string.count < 1 {
                                // show pdf damage alert
                                errorMessage = "Your PDF is Damaged or Empty!"
                                showPDFAlert = true
                            } else {
                                shouldShowChunkView = false
                                pdfText = documentContent.string.trimmingCharacters(in: .whitespacesAndNewlines)
                                DispatchQueue.main.async {
                                    viewModel.question += pdfText
                                }
                                pdfTextLoading = false
                                DispatchQueue.main.async {[viewModel] in
                                    pdfText = documentContent.string
                                    pdfTextLoading = false
                                    viewModel.pdfResponse = pdfText
                                }
                            }
                        } catch {
                            DispatchQueue.main.async {
                                print(error)
                                pdfTextLoading = false
                            }
                        }
                    }
                }
                .showLoadingView(pdfTextLoading)
            textView()
            if shouldShowChunkView {
                chunkView
            }
            buttonView()
        }
    }

    private var chunkView: some View {
        VStack(spacing: 5) {
            Text("Please click an item below then send to AI.")
                .font(.system(size: 11))
            ScrollView(.horizontal) {
                LazyHStack(spacing: 5) {
                    ForEach(0..<viewModel.mychunks.count, id: \.self) { index in
                        VStack {
                            Text("Part-\(index+1)")
                                .foregroundColor(AppColors.themeColor)
                                .font(.system(size: 9))
                            Button {
                                viewModel.question += viewModel.mychunks[index]
                                lastQuestion = viewModel.question
                                pdfIsClickedBools[index] = true
                            } label: {
                                Image("openPdfButtonIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.white)
                                    .opacity(pdfIsClickedBools[index] ? 0.4 : 1)
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.bottom, 16)
                        .padding(.horizontal, 8)
                    }
                }
                .frame(height: 60)
            }
        }
    }

    private func chatResponseView() -> some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(0..<viewModel.model.count, id: \.self) { index in
                        let string  = viewModel.model[index]
                        if index % 2 == 0 {
                            HStack(alignment: .bottom) {
                                VStack {
                                    Image("person")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .padding(.horizontal, 4)
                                    Text("My Request")
                                        .font(.system(size: 9))
                                }
                                Text(string)
                                    .padding(.horizontal, 12)
                                    .padding(.top, 12)
                                    .background(AppColors.suggestionBgColor).clipShape(BubbleShape(myMessage: false))
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                            }
                        } else {
                            VStack(alignment: .leading) {
                                HStack(alignment: .bottom) {
                                    Spacer()
                                    Text(string)
                                        .padding(12)
                                        .background(AppColors.suggestionBgColor).clipShape(BubbleShape(myMessage: true))
                                        .fixedSize(horizontal: false, vertical: true)
                                    VStack {
                                        Image("icon")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(25)
                                            .padding(.horizontal, 4)
                                        Text("AI Response")
                                            .font(.system(size: 9))
                                    }
                                }
                                HStack {
                                    Button {
                                        self.text = string
                                        copyToClipboard()
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
                                            Image(systemName: speaker.speaking ?
                                                  "stop.circle.fill" :
                                                    "playpause.circle")
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
                    Spacer()
                        .frame(height: 1)
                        .id("1")
                        .padding(.bottom, 12)
                        .onChange(of: viewModel.model.count) { _ in
                            reader.scrollTo("1")
                        }
                        .onChange(of: viewModel.text) { _ in
                            reader.scrollTo("1")
                        }
                }
                .padding(16)
            }
        }
    }
    private func onDisappear() {
        viewModel.fetchSpecificChat(withId: viewModel.currentChatId, fetchOnlyOneChat: true)
        if viewModel.currentSpecificChatsFromHistory.isEmpty {
            viewModel.deleteId(id: viewModel.currentChatId)
        }
        viewModel.currentChatId = ""
        viewModel.model.removeAll()
        viewModel.fromPdfPrompts = false
        speaker.stopSpeaking()
    }
    private var regenerateButton: some View {
        Button {
            viewModel.question = lastQuestion
            // in-app purchase
            if iapVM.isActive {
                viewModel.send(fromPDF: true)
            } else {
                let savedDate = Date(timeIntervalSince1970: todaysDate)
                let notSameDay = !Calendar.current.isDate(Date(), inSameDayAs: savedDate)
                if notSameDay {
                    todaysRequestCount = 0
                    todaysDate = Date().timeIntervalSince1970
                    viewModel.sendSuccess = false
                }
                if todaysRequestCount < 9 {
                    viewModel.send(fromPDF: true)
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
            speaker.speak(msg: text, voiceLanguage: viewModel.voiceLanguage)
            speaker.speaking = true
        }
    }
    func responseView() -> some View {
        ScrollViewReader {reader in
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading) {
                    ForEach(0..<viewModel.model.count, id: \.self) { index in
                        let string  = viewModel.model[index]
                        if index % 2 == 0 {
                            Text(string)
                        } else {
                            VStack {
                                Text(string)
                                Button {
                                    self.text = string
                                    copyToClipboard()
                                } label: {
                                    Image(systemName: "doc.on.doc.fill")
                                    Text(buttonText)
                                }
                            }
                        }
                    }
                    Spacer()
                        .frame(height: 1)
                        .id("1")
                        .onChange(of: viewModel.model.count) { _ in
                            reader.scrollTo("1")
                     }
                }
            }
        }
    }

    func textEditorView() -> some View {
        HStack {
            TextEditor(text: $viewModel.question)
                .focused($textEditorFocused)
                .frame(height: viewModel.question.isEmpty ? 50: 150)
                .padding(12)
                .overlay {
                    TextEditorShape(cornerRadius: 20, gap: 120, offset: 30)
                        .stroke(lineWidth: 2.0)
                        .foregroundColor(AppColors.buttonColor)
                        .overlay(alignment: .topLeading) {

                            Text("Input Text")
                                .bold()
                                .offset(x: 60, y: -10)
                        }
                }
                .overlay(alignment: .topTrailing) {
                    HStack(spacing: 10) {
                        Text("\(viewModel.question.count)/3000")
                            .bold()
                            .font(.system(size: 10))
                            .padding(8)
                            .background(viewModel.question.count > 3000 ? .orange : .white)
                            .cornerRadius(4)
                            .offset(x: 0, y: -4)

                        Button {
                             showingSheet = true
                        } label: {

                            HStack {
                                Image("suggestionIcon")
                                    .resizable()
                                    .frame(width: 20, height: 20)
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
                            .offset(x: 0, y: -4)
                        }
                        Menu {
                            Picker(selection: $viewModel.selectedLanguage) {
                                ForEach(Language.allCases) { value in
                                    Text(value.rawValue)
                                        .tag(value)
                                        .font(.largeTitle)
                                }
                            } label: {}
                        } label: {
                            Text("Output Languages")
                            .font(.system(size: 10))
                            .bold()
                        }
                        .padding(8)
                        .frame(height: 30)
                        .background(AppColors.suggestionsColor)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .offset(x: 0, y: -4)
                    }
                    .padding(.trailing, 25)
                    .offset(y: -35)
                    .sheet(isPresented: $showingSheet) {
                        PdfSuggestionsView()
                    }
                }
                .overlay(alignment: .topTrailing, content: {
                    if textEditorFocused || !viewModel.question.isEmpty {
                        Image(systemName: "xmark")
                            .padding(20)
                            .contentShape(Rectangle())
                            .offset(x: 25, y: -30)
                            .onTapGesture {
                                viewModel.question = ""
                                pdfText = ""
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
        }
    }
    func openPdfFileButtonView() -> some View {
        HStack {
            Button {
                presentImporter = true
            } label: {
                Image("openPdfButtonIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 25, height: 25)
                    .padding(8)
                    .cornerRadius(4)
                    .foregroundColor(.white)
            }
            if !pdfText.isEmpty || !viewModel.mychunks.isEmpty {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .font(.system(size: 30))
                VStack {
                    Image(systemName: "xmark")
                        .foregroundColor(.orange)
                        .font(.system(size: 18))
                    Text("Clear")
                        .foregroundColor(.orange)
                        .font(.system(size: 10))
                }
                .onTapGesture {
                    resetPDF()
                }
            }
        }
    }

    func resetPDF() {
        viewModel.mychunks.removeAll()
        pdfIsClickedBools.removeAll()
        pdfText = ""
        viewModel.pdfSuggestion = ""
        textEditorFocused = false
        shouldShowChunkView = false
        viewModel.question = ""
    }

    func textView() -> some View {

        Text(!pdfText.isEmpty || !viewModel.mychunks.isEmpty ? "The PDF is Uploaded Successfully"
             : "Click on the icon above to upload the PDF")
            .font(.system(size: 10))
            .lineLimit(1)
            .bold()
            .offset(x: 0, y: -10)
    }

    func buttonView() -> some View {
        Button {
            lastQuestion = viewModel.question
            // in-app purchase
            if iapVM.isActive {
                viewModel.send(fromPDF: true)
            } else {
                let savedDate = Date(timeIntervalSince1970: todaysDate)
                let notSameDay = !Calendar.current.isDate(Date(), inSameDayAs: savedDate)
                if notSameDay {
                    todaysRequestCount = 0
                    todaysDate = Date().timeIntervalSince1970
                    viewModel.sendSuccess = false
                }
                if todaysRequestCount < 9 {
                    viewModel.send(fromPDF: true)
                } else {
                    showInAppSheet = true
                    return
                }
            }
            pdfText = ""
            viewModel.fromPdfSuggestions = false
        } label: {
            HStack {
                Image("PdfconvertButton")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                Text("SEND TO AI")
                    .bold()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(viewModel.isLoading ? AppColors.buttonColor.opacity(0.4) :AppColors.buttonColor)
            .cornerRadius(10)
            .foregroundColor(AppColors.themeColor)
        }
        .disabled(!viewModel.isComplete || viewModel.question.isEmpty)
    }
    func copyToClipboard() {
        let parsed = self.text.replacingOccurrences(of: "ChatGPT:", with: "")
        pasteboard.string = parsed
        self.buttonText = "Copied!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.buttonText = "Copy to clipboard"
        }
    }
    func localConvertPdfToText(url: URL) {
        if let pdf = PDFDocument(url: url) {
            let pageCount = pdf.pageCount
            let documentContent = NSMutableAttributedString()
            for index in 0 ..< pageCount {
                guard let page = pdf.page(at: index) else { continue }
                guard let pageContent = page.attributedString else { continue }
                documentContent.append(pageContent)
                // self.localText = pageContent
                documentContent.append(pageContent)
            }
            print("debug", documentContent.string)
            if documentContent.string.count > 500 {
                viewModel.makeChunks(text: documentContent.string)
            } else {
                viewModel.question = documentContent.string
            }
        }
    }
}
// swiftlint:enable type_body_length function_body_length file_length
