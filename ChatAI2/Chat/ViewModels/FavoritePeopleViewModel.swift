//
//  FavoritePeopleViewModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 1/6/23.
//

import Foundation
import Firebase

class FavoritePeopleViewModel: ObservableObject {
    @Published var favoriteChatHistoryMessages = [ChatHistoryMessage]()
    // MARK: - Pagination for chat history
    var lastDocumentSnapshotChatHistory: DocumentSnapshot?
    var snapShotListenerChatHistory: ListenerRegistration?
    var loadMoreChatHistoryClicked = true
    @Published var endReachedChatHistory = false
    var firstBatch = true

    func loadFirstBatchChatHistoryWithListener() {
        if firstBatch {
            favoriteChatHistoryMessages.removeAll()
        }

        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        var query: Query!

        let usersCollectionRef = FirebaseManager.shared.firestore
            .collection(Keys.chattedWith)
            .document(userId)
            .collection(Keys.chatHistoryMessages)

        query = usersCollectionRef.order(by: Keys.createdAt, descending: true).limit(to: 10)

         query.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }

             if self.favoriteChatHistoryMessages.isEmpty {
                 self.lastDocumentSnapshotChatHistory = snapshot.documents.last
             }

            // Listen to only I have sent messages
            snapshot.documentChanges.forEach { diff in
                let diffId = diff.document.documentID
                if let index = self.favoriteChatHistoryMessages.firstIndex(where: {$0.id == diffId}) {
                    self.favoriteChatHistoryMessages.remove(at: index)
                }
                if diff.type == .added {
                    let doc = diff.document
                    do {
                        let message = try doc.data(as: ChatHistoryMessage.self)
                        if self.firstBatch {
                            self.favoriteChatHistoryMessages.append(message)
                        } else {
                            self.favoriteChatHistoryMessages.insert(message, at: 0)
                        }
                    } catch {
                        print("err \(error.localizedDescription )")
                    }
                } else {
                    do {
                        let message = try diff.document.data(as: ChatHistoryMessage.self)
                        self.favoriteChatHistoryMessages.insert(message, at: 0)
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
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard !endReachedChatHistory else {return}

        var query: Query!

        if let nextStartingSnap = self.lastDocumentSnapshotChatHistory {
            query = FirebaseManager.shared.firestore.collection(Keys.chattedWith)
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
                        self.favoriteChatHistoryMessages.append(chatMessage)
                    } catch {
                        print(err?.localizedDescription ?? "")
                    }
                }

                self.lastDocumentSnapshotChatHistory = snapShot.documents.last
            }
        }
    }
}
