//
//  PeopleViewModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 31/5/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class PeopleViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var cityName = ""
    @Published var searchedPeople = [UserModel]()
    @Published var searchPressed = false

    var lastDocumentSnapshot: DocumentSnapshot!
    @Published var endReached = false

    func getSearchedPeople() {
        var query: Query
        if !firstName.isEmpty && !cityName.isEmpty {
            query = FirebaseManager.shared.firestore.collection("users")
                .whereField("firstName", isEqualTo: firstName)
                .whereField("cityName", isEqualTo: cityName)
        } else if !firstName.isEmpty && cityName.isEmpty {
            query = FirebaseManager.shared.firestore.collection("users")
                .whereField("firstName", isEqualTo: firstName)
        } else if firstName.isEmpty && !cityName.isEmpty {
            query = FirebaseManager.shared.firestore.collection("users")
                .whereField("cityName", isEqualTo: cityName)
        } else {
            return
        }

        query.getDocuments { snapShot, err in
            if let err = err {
                print("Debug: Error searching people, \(err)")
            } else if let snapShot = snapShot {
                var persons = [UserModel]()
                for doc in snapShot.documents {
                    do {
                        let person = try doc.data(as: UserModel.self)
                        persons.append(person)
                    } catch {
                        print("Debug: Error searching people, \(String(describing: err))")
                    }
                }
                self.searchedPeople.removeAll()
                self.searchedPeople = persons
            }
        }
    }

    func fetchPeopleWithPagination(limit: Int, shouldRefresh: Bool) {

        if shouldRefresh {
            searchedPeople.removeAll()
            endReached = false
        }
        var query: Query
        if !firstName.isEmpty && !cityName.isEmpty {
            query = FirebaseManager.shared.firestore.collection("users")
                .whereField("firstName", isEqualTo: firstName)
                .whereField("cityName", isEqualTo: cityName)
        } else if !firstName.isEmpty && cityName.isEmpty {
            query = FirebaseManager.shared.firestore.collection("users")
                .whereField("firstName", isEqualTo: firstName)
        } else if firstName.isEmpty && !cityName.isEmpty {
            query = FirebaseManager.shared.firestore.collection("users")
                .whereField("cityName", isEqualTo: cityName)
        } else {
            return
        }

        if searchedPeople.isEmpty {
            query = query.limit(to: limit)
            print("First \(limit) people loaded")
        } else {
            query = query.start(afterDocument: lastDocumentSnapshot).limit(to: limit)
            print("Next \(limit) people loaded")
        }

        query.getDocuments { (snapshot, err) in
            if let err = err {
                print("\(err.localizedDescription)")
            } else if snapshot!.isEmpty {
                self.endReached = true
                return
            } else {
                var persons = [UserModel]()
                for doc in snapshot!.documents {
                    do {
                        let person = try doc.data(as: UserModel.self)
                        persons.append(person)
                    } catch {
                        print("Debug: Error searching people, \(String(describing: err))")
                    }
                }

                self.searchedPeople.append(contentsOf: persons)
                self.lastDocumentSnapshot = snapshot!.documents.last
            }
        }
    }
}

struct UserModel: Codable, Identifiable {
    @DocumentID var id: String?
    var cityName: String
    var email: String
    var firstName: String
    var lastName: String
    var userid: String
    var profileImage: String
}
