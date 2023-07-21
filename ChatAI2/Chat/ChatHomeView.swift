//
//  ChatHomeView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 31/5/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ChatHomeView: View {
    @AppStorage("username") var username: String = ""
    @State private var user: UserModel?

    var body: some View {
        chatPeople
            .onAppear {
                getUserName()
            }
    }

    private func getUserName() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }

        FirebaseManager.shared.firestore
            .collection("users")
            .document(userId)
            .getDocument { doc, err in
                if let err = err {
                    print(err, "Error")
                } else if let doc = doc {
                    self.username = doc.data()?["firstName"] as? String ?? ""
                    print(self.username, "USERNAME")
                    let person = try? doc.data(as: UserModel.self)
                    self.user = person
                }
            }
    }

    private var chatPeople: some View {
        List {
            Text("Welcome ") +
            Text(username)
                .bold()
            NavigationLink {
                PeopleView()
            } label: {
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.themeColor)
                    Text("People")
                        .font(.system(size: 20))
                    Spacer()
                }
            }

            NavigationLink {
                FavoritePeopleView()
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.themeColor)
                    Text("People I Chatted With")
                        .font(.system(size: 20))
                    Spacer()
                }
            }

            if let user = user {
                NavigationLink {
                    ProfileView(user: user)
                } label: {
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.themeColor)
                        Text("My Profile")
                            .font(.system(size: 20))
                        Spacer()
                    }
                }
            } else {
                ProgressView()
            }
        }
        .frame(height: 250)
        .navigationTitle("Social")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .onAppear {
            print("ChatHomeView")
        }
    }
}

struct ChatHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ChatHomeView()
    }
}
