//
//  FirebaseManager.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 30/5/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class FirebaseManager {
    static var shared = FirebaseManager()
    let auth = Auth.auth()
    let firestore = Firestore.firestore()
    let storage = Storage.storage()
}
