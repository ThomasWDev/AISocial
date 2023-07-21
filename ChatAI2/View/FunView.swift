//
//  FunView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 2/5/23.
//

import SwiftUI
struct FunView: View {
    @StateObject var viewModel = ChatGPTPromptViewModel()
    var body: some View {
        NavigationStack {
            CustomNavigationPicker(items: viewModel.prompts, selectedItem: $viewModel.selectedPrompt)
                .onAppear {
                    viewModel.fetchNewPrompts()
            }
        }
    }
}
    struct FunView_Previews: PreviewProvider {
        static var previews: some View {
            FunView()
        }
    }

    struct PlayerView: View {
        let name: String

        var body: some View {
            Text("Selected player: \(name)")
                .font(.largeTitle)
        }
    }
