//
//  ImageGeneratorView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 9/3/23.
//

import SwiftUI
struct ImageGeneratorView: View {
    @FocusState var textEditorFocused
    private let photo = Image("label")
    let link = URL(string: "https://www.facebook.com")!
    @ObservedObject var viewModel = ImageGeneratorViewModel()
    @State private var selectedItem = ""
    @ObservedObject var textViewModel  = TextGeneratorViewModel.shared
    @State var isShowing  = false
    var body: some View {
        NavigationView {
                VStack {
                    nav
                    GeometryReader { geo in
                        ScrollView {
                            imageGenerateView()
                            textEditorView()
                            generateButton()
                            chosePromptButton()
                                .sheet(isPresented: $isShowing) {
                                    NavigationView {
                                        imagePromptsView()
                                    }
                                    .navigationViewStyle(.stack)
                               }
                        }
                        .frame(height: geo.size.height)
                        .padding(16)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .showLoadingView(viewModel.isLoading)
                .navigationTitle("Image Generator")
                .navigationBarHidden(true)
                .onAppear {
                    textViewModel.reset()
                    viewModel.setup()
                }
                .onDisappear {
                    textViewModel.question = ""
            }
        }
        .navigationViewStyle(.stack)
    }

    func choseContentPromptView() -> some View {
        NavigationLink {
            CustomNavigationPicker(items: ChatGPTImagePrompts.photograph, selectedItem: $textViewModel.contentType)
        } label: {
            HStack {
                Text("Chose Some Content:")
                Spacer()
                Text(textViewModel.contentType)
                    .foregroundColor(.gray)
            }
        }
    }

    func choseDescriptionPromptView() -> some View {
        NavigationLink {
            CustomNavigationPicker(items:
                                    ChatGPTImagePrompts.descriptions,
                                   selectedItem: $textViewModel.chosenDescription)
        } label: {
            HStack {
                Text("Choose a Description:")
                Spacer()
                Text(textViewModel.chosenDescription)
                    .foregroundColor(.gray)
            }
        }
    }
    func choseStylePromptView() -> some View {
        NavigationLink {
            CustomNavigationPicker(items:
                                    ChatGPTImagePrompts.chosenStyles,
                                   selectedItem: $textViewModel.chosenStyle)
        } label: {
            HStack {
                Text("Choose a Style:")
                Spacer()
                Text(textViewModel.chosenStyle)
                    .foregroundColor(.gray)
            }
        }
    }
    func choseCompositionsPromptsView() -> some View {
        NavigationLink {
            CustomNavigationPicker(items:
                                    ChatGPTImagePrompts.compositions,
                                   selectedItem: $textViewModel.composition)
        } label: {
            HStack {
                Text("Chose a Composition:")
                Spacer()
                Text(textViewModel.composition)
                    .foregroundColor(.gray)
            }
        }
    }
    func imagePromptsView() -> some View {
        List {
            HStack {
                Spacer()
                Text("Done")
                    .foregroundColor(AppColors.themeColor)
                    .padding(16)
                    .onTapGesture {
                        isShowing = false
                    }
            }
            choseContentPromptView()
            choseDescriptionPromptView()
            choseStylePromptView()
            choseCompositionsPromptsView()
        }
    }
    var nav: some View {
        ZStack(alignment: .top) {
            Image("topShape")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: 150)
            HStack(alignment: .center) {
                Spacer()
                Text("Image Generator")
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

    func imageGenerateView() -> some View {
        ScrollView {
            VStack {
                if let image = viewModel.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width-32, height: 350)
                        .clipped()
                    ShareLink(item: image, preview: SharePreview("label", image: image))
                } else {
                    Image("typeImageIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text("Add prompts to generate an image")
                        .padding(.bottom, 16)
                        .bold()
                        .foregroundColor(.blue)
                }
            }
        }
    }

    func textEditorView() -> some View {
        TextEditor(text: $textViewModel.question)
            .focused($textEditorFocused)
            .frame(height: (textEditorFocused || !textViewModel.question.isEmpty) ? 150 : 50)
            .padding(16)
            .overlay {
                TextEditorShape(cornerRadius: 20, gap: 110, offset: 30)
                    .stroke(lineWidth: 2.0)
                    .foregroundColor(AppColors.buttonColor)
                    .overlay(alignment: .topLeading) {
                        Text("Type here...")
                            .bold()
                            .offset(x: 60, y: -10)
                    }
            }
            .overlay(alignment: .topTrailing, content: {
                if textEditorFocused || !textViewModel.question.isEmpty {
                    Image(systemName: "xmark")
                        .padding(20)
                        .contentShape(Rectangle())
                        .offset(x: 5, y: -10)
                        .onTapGesture {
                            textViewModel.question = ""
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

    func generateButton() -> some View {
        Button {
            if !textViewModel.question.trimmingCharacters(in: .whitespaces).isEmpty {
                viewModel.isLoading = true
                Task {
                    let temp = textViewModel.question
                    textViewModel.question = ""
                    textViewModel.chosenStyle = ""
                    textViewModel.contentType = ""
                    textViewModel.chosenDescription = ""
                    textViewModel.composition = ""
                    textEditorFocused = false
                    let result = await viewModel.generateImage(prompt: temp)

                    viewModel.isLoading = false
                    if viewModel.image == nil {
                        print("Failed to get image")
                    }
                    self.viewModel.image = result
                    textViewModel.question = ""
                    textEditorFocused = false
                }
            }
        } label: {
            HStack {
                Image("imageGenerateButtonIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                Text("Generate")
                    .font(.system(size: 18))
                    .bold()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(viewModel.isLoading ? AppColors.buttonColor.opacity(0.5):AppColors.buttonColor)
            .cornerRadius(10)
            .foregroundColor(.blue)

        }
        .disabled(viewModel.isLoading)
    }

    func chosePromptButton() -> some View {
        Button {
            isShowing = true
        } label: {
            HStack {
                Image("chosePromptIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                Text("Choose a Prompt")
                    .bold()

            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(AppColors.themeColor)
            .cornerRadius(10)
            .foregroundColor(.white)

        }
    }
}

struct ImageGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGeneratorView()
    }
}
