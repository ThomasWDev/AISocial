//
//  PeopleView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 31/5/23.
//

import SwiftUI

struct PeopleView: View {
    @StateObject private var viewModel = PeopleViewModel()
    @StateObject private var chatLogVM = ChatLogViewModel()
    @StateObject private var network = NetworkMonitor.shared

    var body: some View {
        // This is a list of people whome I have recently chatted with
        // There will be two search bars to search people by location and by firstname/ lastname
        VStack {
            // Searchbar name
            Text("Search by First name or City name or by both")
                .textGreen()
            SearchBar(text: $viewModel.firstName, placeHolderText: "First name")
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            SearchBar(text: $viewModel.cityName, placeHolderText: "City name")
                .padding(.horizontal, 16)
                .padding(.bottom, 6)

            Button {
                viewModel.searchPressed = true
                viewModel.fetchPeopleWithPagination(limit: 10, shouldRefresh: true)
            } label: {
                Text("Search")
                    .padding(12)
                    .foregroundColor(Color.white)
                    .font(.system(size: 21))
                    .frame(maxWidth: .infinity)
                    .background(AppColors.themeColor)
                    .cornerRadius(6)
                    .padding(.horizontal, 16)
                    .opacity((viewModel.firstName.isEmpty && viewModel.cityName.isEmpty) ? 0.6 : 1)
            }.disabled(viewModel.firstName.isEmpty && viewModel.cityName.isEmpty)
                .onAppear {
                    chatLogVM.firstBatch = true
                    chatLogVM.loadFirstBatchChatHistoryWithListener()
                }

            if shouldShowSearchResult() {
                HStack {
                    Text("< Back to Chat History")
                        .textGreen()
                        .onTapGesture {
                            cancelSearch()
                        }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            List {
                if shouldShowSearchResult() {
                    Text("People you are looking for")
                            .textGreen()
                    ForEach(0..<viewModel.searchedPeople.count, id: \.self) { index  in
                        let person = viewModel.searchedPeople[index]
                        NavigationLink {
                            ChatLogView(personInfo: person, seen: true)
                        } label: {
                            PersonCard(imageUrl: person.profileImage,
                                       fullName: person.firstName + " " +
                                       person.lastName,
                                       cityName: person.cityName)
                                .onAppear {
                                    getMoreData(index: index)
                                }
                        }
                    }
                    Text(viewModel.endReached ? "No more results" : "...")
                        .textGreen()
                        .padding(.bottom, 8)

                } else {
                    Text("Chat History")
                        .textGreen()
                    ForEach(chatLogVM.chatHistoryMessages) { chatHistoryMessage in
                        RecentMessageCard(message: chatHistoryMessage.message,
                                          toId: chatHistoryMessage.to,
                                          fromId: chatHistoryMessage.from,
                                          seen: chatHistoryMessage.seen,
                                          fromFavorite: false)
                    }
                    Button {
                        chatLogVM.loadMoreChatHistoryClicked = true
                        chatLogVM.loadNextChatHistories()
                    } label: {
                        Text( (chatLogVM.endReachedChatHistory || chatLogVM.chatHistoryMessages.isEmpty) ?
                              "No more chats" : "Load More")
                            .textGreen()
                    }.disabled(chatLogVM.endReachedChatHistory)
                }
            }
            .padding(.bottom, 8)
            .navigationTitle("People")
            .navigationBarTitleDisplayMode(.inline)
        }
        .noInternetView(isConnected: $network.isConnected)
    }

    func shouldShowSearchResult() -> Bool {
        viewModel.searchPressed
    }

    func getMoreData(index: Int) {
        if index == viewModel.searchedPeople.count-1 {
            if !viewModel.endReached {
                viewModel.fetchPeopleWithPagination(limit: 10, shouldRefresh: false)
            }
        }
    }

    func cancelSearch() {
        viewModel.searchedPeople.removeAll()
        viewModel.searchPressed = false
        viewModel.cityName = ""
        viewModel.firstName = ""
    }
}

struct PeopleView_Previews: PreviewProvider {
    static var previews: some View {
        PeopleView()
    }
}

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    @State var placeHolderText: String = "Search ..."

    var body: some View {
        HStack {
            TextField(placeHolderText, text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }, label: {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            })
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    // Dismiss the keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil,
                                                    from: nil,
                                                    for: nil)
                }, label: {
                    Text("Cancel")
                })
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}

struct PersonCard: View {
    let imageUrl: String
    let fullName: String
    let cityName: String

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 50)
            .cornerRadius(50)
            VStack(alignment: .leading) {
                Text(fullName)
                    .bold()
                    .font(.title2)
                Text(cityName)
            }
            Spacer()
        }
    }
}

struct RecentMessageCard: View {

    @State private var userModel: UserModel?
    let message: String
    let toId: String
    let fromId: String
    let seen: Bool?
    var fromFavorite: Bool
    @State private var fetchingData = true

    var body: some View {
        if let userModel = userModel {
            NavigationLink {
                ChatLogView(fromFavourite: fromFavorite, personInfo: userModel, seen: seen)
            } label: {
                HStack {
                    AsyncImage(url: URL(string: userModel.profileImage)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(50)

                    VStack(alignment: .leading) {
                        Text(userModel.firstName + " "+userModel.lastName )
                            .bold()
                            .foregroundColor(getForegroundColor())
                            .font(.title2)
                        Text(userModel.cityName)
                            .font(.caption)
                            .foregroundColor(getForegroundColor())
                        Text(message)
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundColor(getForegroundColor())
                    }
                    Spacer()
                }
            }
        } else if fetchingData {
            ProgressView()
                .onAppear {
                    fetchingData = true
                    fetchAnoetherPersonsData()
                }
        }
    }

    func getForegroundColor() -> Color {
        seen ?? true ?  Color.black : AppColors.themeColor
    }

    func fetchAnoetherPersonsData() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let anotherPersonsId = toId == userId ? fromId : toId
        FirebaseManager.shared.firestore.collection("users").document(anotherPersonsId).getDocument { snapshot, _ in
            if let snapshot = snapshot {
                do {
                    self.userModel = try snapshot.data(as: UserModel.self)
                } catch {
                    print("ERROR: recent message, \(error)")
                }
            }
            fetchingData = false
        }
    }
}

extension View {
    func textGreen() -> some View {
        modifier(GreenText())
    }
}

struct GreenText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(AppColors.themeColor)
            .font(.system(size: 11, weight: .regular))
            .padding(.vertical, 8)
    }
}
