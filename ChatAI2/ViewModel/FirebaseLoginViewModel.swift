//
//  FirebaseLoginViewModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 28/3/23.
//

import Foundation
import Firebase

class FireBaseLoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggedIn = false
    @Published var authStatusMessage = ""
    @Published var showAlert = false
    @Published var isLoading = false
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.authStatusMessage = error.localizedDescription
                    self.showAlert = true
                }
                print("debug signIn: ", error)} else {
                    print("Logged In")
                    DispatchQueue.main.async {
                        self.isLoggedIn = true
                    }
                }
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
