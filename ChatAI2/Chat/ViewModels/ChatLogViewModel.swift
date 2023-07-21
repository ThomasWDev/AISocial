//
//  ChatLogViewModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 31/5/23.
//
// swiftlint:disable type_body_length file_length identifier_name

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class ChatLogViewModel: ObservableObject {
    @Published var chatMessage: String = ""
    @Published var errorMessage: String = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var chatHistoryMessages = [ChatHistoryMessage]()
    @Published var blocking = false
    var shouldScrollDown = true
    @Published var endReached = false
    @Published var blockStateUser: BlockState = .networkCallStarted
    @Published var blockStateAnotherUser: BlockState = .networkCallStarted

    func sendMessage(fromId: String, toId: String) {
        let document = FirebaseManager.shared.firestore
            .collection(Keys.chat)
            .document(fromId)
            .collection(toId).document()
        let data = [
            Keys.from: fromId,
            Keys.to: toId,
            Keys.message: chatMessage,
            Keys.createdAt: Timestamp()
        ] as [String: Any]

        document.setData(data) { err in
            if let err = err {
                print("debug: ", err.localizedDescription)
            } else {
                print("debug: SUCCESS sending messages")
                self.saveToChatHistory(fromId: fromId, toId: toId, data: data)
                self.saveToPeopleIChattedWith(fromId: fromId, toId: toId, data: data)
            }
        }

        // Recipient
        let recDocument = FirebaseManager.shared.firestore
            .collection(Keys.chat)
            .document(toId)
            .collection(fromId).document()

        recDocument.setData(data) { err in
            if let err = err {
                print("debug: recipient", err.localizedDescription)
            } else {
                print("debug: SUCCESS sending messages for recipeient")
                self.saveToChatHistory(fromId: toId, toId: fromId, data: data)

                // has the recipient sent me messages yet? don't save it until it already exits.
                // Check if toid and fromID already exists.
                print("\(toId)  \(fromId)")
                FirebaseManager.shared.firestore
                    .collection(Keys.chattedWith)
                    .document(toId).collection(Keys.chatHistoryMessages)
                    .document(fromId).getDocument { (document, _) in
                    if let err = err {
                        print(err)
                    }
                    if let doc = document {
                        if doc.exists {
                            self.saveToPeopleIChattedWith(fromId: toId, toId: fromId, data: data)
                        } else {
                            print("document does not exists")
                        }

                    }
             }

            }
        }
        chatMessage = ""
    }

    func checkBlocked(anotherUserId: String) {

        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {return}
        FirebaseManager.shared.firestore.collection(Keys.blocked).document(userId).collection(Keys.blockedUsers)
            .whereField(Keys.blockedUser, isEqualTo: "\(anotherUserId)").addSnapshotListener { snapShot, _ in
                if let snapShot = snapShot {
                    if snapShot.isEmpty {
                        self.blockStateAnotherUser = .notBlocked
                    } else {
                        self.blockStateAnotherUser = .anotherUserIsBlocked
                    }
                }
            }
    }

    func checkUserIsBlocked(by anotherUserId: String) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {return}
        FirebaseManager.shared.firestore.collection(Keys.blocked).document(anotherUserId).collection(Keys.blockedUsers)
            .whereField(Keys.blockedUser, isEqualTo: "\(userId)").addSnapshotListener { snapShot, _ in
                if let snapShot = snapShot {
                    if snapShot.isEmpty {
                        self.blockStateUser = .notBlocked
                    } else {
                        self.blockStateUser = .userIsBlocked
                    }
                }
            }
    }

    func unBlockUser(with anotherUser: String) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {return}
        FirebaseManager.shared.firestore
            .collection(Keys.blocked)
            .document(userId).collection(Keys.blockedUsers)
            .document(anotherUser)
            .delete { err in
            if let err = err {
                print("deleting Error: ", err.localizedDescription)
            }
            self.blockStateAnotherUser = .notBlocked
        }
    }

    func addToBlockList(anotherUser: String) {

        guard !blocking else {return}
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {return}

        blocking = true

        let data = [
            "blocked_user": anotherUser,
            "blocked_at": Timestamp()
        ] as [String: Any]

        FirebaseManager.shared.firestore.collection(Keys.blocked)
            .document(userId).collection(Keys.blockedUsers)
            .document(anotherUser).setData(data) { err in
            if let err = err {
                print("Blocking Error: ", err.localizedDescription)
            } else {
                self.blockStateAnotherUser = .anotherUserIsBlocked
            }
            self.blocking = false
        }
    }

    func updateSeen(userId: String, anotherUserId: String, forFavorite: Bool) {

        FirebaseManager.shared.firestore.collection(Keys.chattedWith)
            .document(userId).collection(Keys.chatHistoryMessages)
            .document(anotherUserId).updateData(["seen": true])
        FirebaseManager.shared.firestore.collection(Keys.chatHistory)
            .document(userId).collection(Keys.chatHistoryMessages)
            .document(anotherUserId).updateData(["seen": true])

    }

    func saveToPeopleIChattedWith(fromId: String, toId: String, data: [String: Any]) {
        var myData = data
        if fromId == FirebaseManager.shared.auth.currentUser?.uid {
            myData["seen"] = true
        } else {
            myData["seen"] = false
        }

        FirebaseManager.shared.firestore.collection(Keys.chattedWith)
            .document(fromId).collection(Keys.chatHistoryMessages)
            .document(toId).setData(myData) { err in
            if let err = err {
                print("Error saving data ", err.localizedDescription)
            } else {

            }
        }
    }

    func saveToChatHistory(fromId: String, toId: String, data: [String: Any]) {
        var myData = data
        if fromId == FirebaseManager.shared.auth.currentUser?.uid {
            myData["seen"] = true
        } else {
            myData["seen"] = false
        }
        FirebaseManager.shared.firestore.collection(Keys.chatHistory)
            .document(fromId).collection(Keys.chatHistoryMessages)
            .document(toId).setData(myData) { err in
            if let err = err {
                print("Error saving data ", err.localizedDescription)
            } else {

            }
        }
    }

    func fetchMessages(fromId: String, toId: String) {

        FirebaseManager.shared.firestore.collection(Keys.chat).document(fromId).collection(toId)
            .order(by: Keys.createdAt).addSnapshotListener { querySnapShot, err in

            if let err = err {
                self.errorMessage = err.localizedDescription
                print("DEBUG: ", err.localizedDescription)
            } else {
                querySnapShot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let doc = change.document
                        do {
                            let message = try doc.data(as: ChatMessage.self)
                            self.chatMessages.append(message)
                        } catch {
                            print("err \(err?.localizedDescription ?? "Error")")
                        }

                    }
                })
            }
        }
    }

    // MARK: - Pagination 2 this is working
    var lastDocumentSnapshot: DocumentSnapshot?
    var snapShotListener: ListenerRegistration?
    var loadMoreClicked = true
    @Published var endRichedforMessages = false

    func observeUsersWithPagination(fromId: String, toId: String) {
        var query: Query!

        guard !endRichedforMessages else {
            return
        }

        let usersCollectionRef = FirebaseManager.shared.firestore
            .collection(Keys.chat).document(fromId).collection(toId)

        if let nextStartingSnap = self.lastDocumentSnapshot {
            query = usersCollectionRef.order(by: Keys.createdAt, descending: true)
                .start(afterDocument: nextStartingSnap).limit(to: 10)
        } else {
            query = usersCollectionRef.order(by: Keys.createdAt, descending: true).limit(to: 10)
        }

        snapShotListener = query.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(String(describing: error))")
                return
            }
            if snapshot.isEmpty {
                self.endRichedforMessages = true
            }
            self.lastDocumentSnapshot = snapshot.documents.last

            print(snapshot.documentChanges.count, "count document changes")

            if snapshot.documentChanges.count <= 2 {
                self.shouldScrollDown = true
            }
            snapshot.documentChanges.forEach { diff in

                if diff.type == .added {
                    let doc = diff.document
                    do {
                        let message = try doc.data(as: ChatMessage.self)
                        if self.loadMoreClicked {
                            self.chatMessages.insert(message, at: 0)
                        } else {
                            self.chatMessages.append(message)
                        }
                        print("chat: \(message.message)")
                    } catch {
                        print("err \(error.localizedDescription )")
                    }
                }

                /*
                if (diff.type == .modified) {
                    print("Modified user: \(userName)", age)
                }
                if (diff.type == .removed) {
                    print("Removed user: \(userName)", age)
                }
                 */
            }
            self.loadMoreClicked = false

        }
    }

    // MARK: - Pagination for chat history
    var lastDocumentSnapshotChatHistory: DocumentSnapshot?
    var snapShotListenerChatHistory: ListenerRegistration?
    var loadMoreChatHistoryClicked = true
    @Published var endReachedChatHistory = false
    var firstBatch = true

    func loadFirstBatchChatHistoryWithListener() {

        if firstBatch {
            chatHistoryMessages.removeAll()
        }

        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {return}
        var query: Query!

        let usersCollectionRef = FirebaseManager.shared.firestore.collection(Keys.chatHistory)
            .document(userId).collection(Keys.chatHistoryMessages)

        query = usersCollectionRef.order(by: Keys.createdAt, descending: true).limit(to: 10)

         query.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }

             if self.chatHistoryMessages.isEmpty {
                 self.lastDocumentSnapshotChatHistory = snapshot.documents.last
             }

            snapshot.documentChanges.forEach { diff in

                let diffId = diff.document.documentID
                if let index = self.chatHistoryMessages.firstIndex(where: {$0.id == diffId}) {
                    self.chatHistoryMessages.remove(at: index)
                }
                if diff.type == .added {
                    let doc = diff.document
                    do {
                        let message = try doc.data(as: ChatHistoryMessage.self)
                        if self.firstBatch {
                            self.chatHistoryMessages.append(message)
                        } else {
                            self.chatHistoryMessages.insert(message, at: 0)
                        }
                    } catch {
                        print("err \(error.localizedDescription )")
                    }
                } else {
                    do {
                        let message = try diff.document.data(as: ChatHistoryMessage.self)
                        self.chatHistoryMessages.insert(message, at: 0)
                    } catch {
                        print("err \(error.localizedDescription )")
                    }
                }
            }
             self.loadMoreChatHistoryClicked = false
             self.firstBatch = false
        }
    }

    func loadNextChatHistories() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {return}
        guard !endReachedChatHistory else {return}

        var query: Query!

        if let nextStartingSnap = self.lastDocumentSnapshotChatHistory {
            query = FirebaseManager.shared.firestore
                .collection(Keys.chatHistory)
                .document(userId).collection(Keys.chatHistoryMessages)
                .order(by: Keys.createdAt, descending: true)
                .start(afterDocument: nextStartingSnap).limit(to: 10)
        } else {
            return
        }

        query.getDocuments { snapShot, err in
            if let snapShot = snapShot {
                if snapShot.isEmpty {
                    self.endReachedChatHistory = true
                    return
                }
                snapShot.documents.forEach {
                    do {
                        let chatMessage = try $0.data(as: ChatHistoryMessage.self)
                        self.chatHistoryMessages.append(chatMessage)
                    } catch {
                        print(err?.localizedDescription ?? "")
                    }

                }

                self.lastDocumentSnapshotChatHistory = snapShot.documents.last
            }
        }
    }

    // MARK: - Pagination in QuerySnapShot, This is not working
    func makeQuery(fromId: String, toId: String) -> Query {
        FirebaseManager.shared.firestore.collection(Keys.chat).document(fromId).collection(toId)
    }

    var first: Query!
    var fetchMoreCalled = false

    func loadFirstSetMessages(fromId: String, toId: String) {

        makeQuery(fromId: fromId, toId: toId).limit(to: 10)
            .order(by: Keys.createdAt).addSnapshotListener { (snapshot, error) in

            guard let snapshot = snapshot else {
                print("Error retrieving cities: \(error.debugDescription)")
                return
            }
            print("MESSAGE: Fetch first Two Messages")
            snapshot.documentChanges.forEach({ change in
                if change.type == .added {
                    let doc = change.document
                    do {
                        let message = try doc.data(as: ChatMessage.self)
                        self.chatMessages.append(message)
                    } catch {
                        print("err \(error.localizedDescription )")
                    }

                }
            })

            guard let lastSnapshot = snapshot.documents.last else {
                // The collection is empty.
                return
            }

            // Construct a new query starting after this document,
            // retrieving the next 25 cities.
            let next = self.makeQuery(fromId: fromId, toId: toId).order(by: Keys.createdAt)
                .start(afterDocument: lastSnapshot).limit(to: 10)

            self.first = next

            // Use the query for pagination.
        }
    }

    func fetchMoreMessages(fromId: String, toId: String) {
        fetchMoreCalled = true
        self.first.getDocuments { (snapshot, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }

            guard let snapshot = snapshot else { return }

            guard let lastSnapshot = snapshot.documents.last else { return }

            let next = self.makeQuery(fromId: fromId, toId: toId)
                .order(by: Keys.createdAt).start(afterDocument: lastSnapshot).limit(to: 10)

            self.first = next

            print("MESSAGE: Fetch Two More Messages")
            snapshot.documents.forEach({ doc in

                    do {
                        let message = try doc.data(as: ChatMessage.self)
                        self.chatMessages.append(message)
                    } catch {
                        print("err \(error.localizedDescription )")
                    }

            })
        }
    }
}

struct Keys {
    static let from = "from"
    static let to = "to"
    static let message = "message"
    static let createdAt = "createdAt"
    static let chat = "chat"
    static let chatHistory = "chatHistory"
    static let chatHistoryMessages = "chatHistoryMessages"
    static let chattedWith = "chattedWith"
    static let blocked = "blocked"
    static let blockedUsers = "blockedUsers"
    static let blockedUser = "blocked_user"
}

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let from: String
    let to: String
    let message: String
    let createdAt: Timestamp
}

struct ChatHistoryMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let from: String
    let to: String
    let message: String
    let createdAt: Timestamp
    let seen: Bool?
}

enum BlockState {
    case networkCallStarted
    case userIsBlocked
    case anotherUserIsBlocked
    case networkCallEnded
    case notBlocked
}

// swiftlint:enable type_body_length file_length identifier_name
