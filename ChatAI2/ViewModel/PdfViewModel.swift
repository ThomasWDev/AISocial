//
//  PdfViewModel.swift
//  ChatAI2
//
//  Created by Tanvir Alam on 8/6/23.
//

import Foundation

class PDFViewMoel: ObservableObject, PdfUploadable {
    @Published var latestPDFLink: String = ""
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false

    func uploadPdfToStorage(with url: URL) {
        let fileName = UUID().uuidString
        let storageRef = FirebaseManager.shared.storage.reference(withPath: "/pdfs/\(fileName)")
        storageRef.putFile(from: url, metadata: nil) { metadata, _ in
            guard metadata != nil else {
                self.errorMessage = "Something went wrong! Please try again."
                self.showAlert = true
                return
            }
            storageRef.downloadURL { (url, _) in
                guard let downloadURL = url?.absoluteString else {
                    print("Uh-oh, an error occurred!")
                    self.errorMessage = "Something went wrong! Please try again."
                    self.showAlert = true
                    return
                }
                print(downloadURL, "URLD")
                self.uploadPdfLinkToFirestore(urlString: downloadURL)
            }
        }
    }

    func uploadPdfLinkToFirestore(urlString: String) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let data = [
            "pdfLink": urlString
        ]
        let documentRef = FirebaseManager.shared.firestore.collection("pdfs").document(userId)
        documentRef.setData(data) { err in
            if let err = err {
                print("debug: ", err.localizedDescription)
            } else {
                self.latestPDFLink = urlString
                print("debug: SUCCESS Saving pdflinks to firestore")
            }
        }
    }
}

protocol PdfUploadable {
    var latestPDFLink: String { get set }
    var errorMessage: String { get set }
    var showAlert: Bool { get set }
    func uploadPdfToStorage(with url: URL)
    func uploadPdfLinkToFirestore(urlString: String)
}
