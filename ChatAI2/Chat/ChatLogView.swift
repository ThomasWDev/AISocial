//
//  ChatLogView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 31/5/23.
//

import SwiftUI

struct ChatLogView: View {
    @StateObject private var chatLogVM = ChatLogViewModel()
    @State private var placeHolderText = "Write Message.."
    var fromFavourite = false
    var personInfo: UserModel
    var seen: Bool?
    @FocusState var textEditorFocused
    @StateObject private var network = NetworkMonitor.shared

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: personInfo.profileImage)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)

                } placeholder: {
                    Color.gray
                }
                .frame(width: 100, height: 100)
                .cornerRadius(50)
                .onAppear {
                    print(personInfo.profileImage, "URL")
                }

                VStack(alignment: .leading) {
                    Text(personInfo.firstName + " " + personInfo.lastName)
                        .bold()
                        .font(.title)
                    Text(personInfo.cityName)
                }

                Spacer()

                VStack(alignment: .trailing) {

                    NavigationLink {
                        ProfileView(user: personInfo)
                    } label: {
                        Text("Visit Profile")
                            .font(.system(size: 12))
                            .padding(6)
                    }

                    if chatLogVM.blockStateUser == .networkCallStarted ||
                        chatLogVM.blockStateAnotherUser == .networkCallStarted {
                        ProgressView()

                    } else if chatLogVM.blockStateAnotherUser == .anotherUserIsBlocked {
                        Button {
                            chatLogVM.unBlockUser(with: personInfo.userid)
                        } label: {
                            Text("Unblock")
                                .font(.system(size: 12))
                                .padding(6)
                        }

                    } else if chatLogVM.blockStateUser == .notBlocked &&
                                chatLogVM.blockStateAnotherUser == .notBlocked {
                        Button {
                            chatLogVM.addToBlockList(anotherUser: personInfo.userid)
                        } label: {
                            Text("Block")
                                .foregroundColor(Color.red)
                                .font(.system(size: 12))
                                .padding(6)
                        }
                    }
                }
            }
            Divider()
                .shadow(radius: 5)

            // MARK: - Chat
            GeometryReader { geo in

                    ScrollViewReader { reader in
                        ScrollView(showsIndicators: false) {
                            Spacer()

                            LazyVStack {
                                Button {
                                    guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {return}
                                    chatLogVM.loadMoreClicked = true
                                    chatLogVM.shouldScrollDown = false
                                    chatLogVM.observeUsersWithPagination(fromId: userId, toId: personInfo.userid)
                                } label: {
                                    Text( (chatLogVM.endRichedforMessages ||
                                           chatLogVM.chatMessages.isEmpty) ? "No More Messages":"Load More")
                                }
                                .disabled(chatLogVM.endRichedforMessages)

                                ForEach(0..<chatLogVM.chatMessages.count, id: \.self) { index in
                                    let message = chatLogVM.chatMessages[index]
                                    chatBubble(message: message.message, from: getFrom(message))
                                }
                                Spacer()
                                    .frame(height: 1)
                                    .id("down")
                                    .onChange(of: chatLogVM.chatMessages.count) { _ in
                                        if chatLogVM.shouldScrollDown {
                                            reader.scrollTo("down")
                                            chatLogVM.shouldScrollDown = false
                                        }
                                    }

                            }

                        }
                        .frame(height: geo.size.height)
                    }
                    .padding(.horizontal, 12)

            }

            Divider()
                .shadow(radius: 5)

            /// this portion is conditional. if none of the recipient or sender is blocked:

            if chatLogVM.blockStateUser == .networkCallStarted ||
                chatLogVM.blockStateAnotherUser == .networkCallStarted {
                ProgressView()
                    .frame(height: 60)
                    .padding()
            } else if chatLogVM.blockStateUser == .userIsBlocked ||
                        chatLogVM.blockStateAnotherUser == .anotherUserIsBlocked {
                Text("Blocked")
                    .frame(height: 60)
                    .padding()
            } else if chatLogVM.blockStateUser == .notBlocked &&
                        chatLogVM.blockStateAnotherUser == .notBlocked {
                HStack {
                    ZStack {
                        if self.chatLogVM.chatMessage.isEmpty {
                                TextEditor(text: $placeHolderText)
                                .frame(height: 60)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .disabled(true)
                                    .padding()
                        }
                        TextEditor(text: $chatLogVM.chatMessage)
                            .frame(height: 60)
                            .font(.body)
                            .opacity(self.chatLogVM.chatMessage.isEmpty ? 0.25 : 1)
                            .padding()
                            .focused($textEditorFocused)
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                textEditorFocused = false
                            }
                        }
                    }

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .padding()
                    }.disabled(chatLogVM.chatMessage.isEmpty)
                }

            }

            Spacer()
        }
        .noInternetView(isConnected: $network.isConnected)
        .onAppear {
            guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {return}
            // todo: rename this function
            chatLogVM.observeUsersWithPagination(fromId: userId, toId: personInfo.userid)
            chatLogVM.checkUserIsBlocked(by: personInfo.userid)
            chatLogVM.checkBlocked(anotherUserId: personInfo.userid)

            // make seen true if seen is false
            if let seen = seen, seen == false {
                chatLogVM.updateSeen(userId: userId, anotherUserId: personInfo.userid, forFavorite: fromFavourite)
            }

        }

    }

    func sendMessage() {
        guard let currentUserId = FirebaseManager.shared.auth.currentUser?.uid else {return}
        chatLogVM.loadMoreClicked = false
        chatLogVM.shouldScrollDown = true
        chatLogVM.sendMessage(fromId: currentUserId, toId: personInfo.userid)
    }

    func getFrom(_ message: ChatMessage) -> Bool {
        message.from == FirebaseManager.shared.auth.currentUser?.uid
    }

    func chatBubble(message: String, from: Bool) -> some View {
        HStack {
            if from {
                Spacer()
            }
            Text(message)
                .foregroundColor(from ? Color.black : Color.white)
                .padding()
                .background(
                    Color.black
                        .opacity(from ? 0.2 : 0.8)
                )
                .cornerRadius(12)
                .frame(maxWidth: UIScreen.main.bounds.width/1.2, alignment: from ? .trailing : .leading)

            if !from {
                Spacer()
            }
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        ChatLogView(personInfo: UserModel(cityName: "Jamalpur",
                                          email: "tanvirgeek@gmail.com", firstName: "Tanvir",
                                          lastName: "Alam", userid: "", profileImage: ""),
                    seen: true)
    }
}
