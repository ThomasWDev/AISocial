//
//  AuthViewModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 30/5/23.
//

import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var password = ""
    @Published var email = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var cityName = ""
    @Published var message = ""
    @Published var showAlert = false
    @Published var loading = false
    @Published var gotoHome = false
    @Published var loggedOut = false
    @Published var image: UIImage?
    @Published var profileImageURL = ""
    @Published var showForgotPassSheet = false

    func signup() {
        guard !email.isEmpty && !password.isEmpty && !cityName.isEmpty
                && !firstName.isEmpty && !lastName.isEmpty else {
            message = "Please fill up all the data."
            showAlert = true
            return
        }
        loading = true
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                print("debug: Signup error \(error)")
                self.showAlertWithMessage(error.localizedDescription)
            } else {
                if let imageData = self.image?.jpegData(compressionQuality: 0.2) {
                    self.uploadImage(with: imageData)
                } else {
                    self.saveSignupDataToFirestore()
                }
            }
        }
    }

    func sendForgotPassEmail() {
        FirebaseManager.shared.auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("debug: Forgot pass error \(error)")
                self.showForgotPassSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.showAlertWithMessage(error.localizedDescription)
                })
            } else {
                self.showForgotPassSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.showAlertWithMessage("Please Check Your Email to Reset Password.")
                })
            }
        }
    }

    func uploadImage(with image: Data) {
        let imageData = image
        let fileName = FirebaseManager.shared.auth.currentUser?.uid ?? UUID().uuidString
        let storageRef = FirebaseManager.shared.storage.reference(withPath: "/profile_images/\(fileName)")
        storageRef.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                print("Error uploading image to Firebase: \(error.localizedDescription)")
                return
            }
            print("Image successfully uploaded to Firebase!")
            storageRef.downloadURL { url, _ in
                guard let imageUrl = url?.absoluteString else { return }
                self.profileImageURL = imageUrl
                self.saveSignupDataToFirestore()
            }
        }
    }

    private func saveSignupDataToFirestore() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {return }
        let data = [
            "userid": userId,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "cityName": cityName,
            "profileImage": profileImageURL
        ] as [String: Any]
        FirebaseManager.shared.firestore.collection("users").document(userId).setData(data) { err in
            if let err = err {
                print("debug: error saving userdata to firestore \(err)")
                self.showAlertWithMessage(err.localizedDescription)
            } else {
                self.gotoHome = true
                self.reset()
            }
        }
    }

    func signin() {
        loading = true
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { _, err in
            if let err = err {
                print("debug: sign in error \(err)")
                self.showAlertWithMessage(err.localizedDescription)
                self.loading = false
            } else {
                self.gotoHome = true
                self.reset()
            }
        }
    }

    func logout() {
        do {
            try FirebaseManager.shared.auth.signOut()
            loggedOut = true
            gotoHome = false
        } catch {
            print("debug: Error logging out")
        }
    }

    private func showAlertWithMessage(_ message: String) {
        self.loading = false
        self.message = message
        showAlert = true
    }

    func reset() {
        firstName = ""
        lastName = ""
        cityName = ""
        password = ""
        email = ""
        profileImageURL = ""
        loading = false
        image = nil
    }
}
