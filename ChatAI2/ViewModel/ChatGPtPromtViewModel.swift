//
//  ChatGPtPromptViewModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 5/5/23.
//

import Foundation
import Firebase

class ChatGPTPromptViewModel: ObservableObject {
    @Published var prompts: [String] = []
    @Published var selectedPrompt = ""{
        didSet {
            TextGeneratorViewModel.shared.question = selectedPrompt
        }
    }
    private var dataBase = Firestore.firestore()
    func fetchNewPrompts() {
        prompts.removeAll()
        dataBase.collection("NewFuns").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting document:\(error)")} else {
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        let data  = document.data()
                        let funny = data["funny"] as? String ?? ""
                        self.prompts.append(funny)
                    }
                }
            }
        }
    }
}
