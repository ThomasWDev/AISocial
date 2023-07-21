//
//  localPDFView.swift
//  ChatAI2
//
//  Created by Md Maruf Prodhan on 18/4/23.
//

import SwiftUI
import PDFKit

struct ResumeView: View {
    let fileUrl = Bundle.main.url(forResource: "Resume", withExtension: "pdf")!
    var body: some View {
        Button(action: {
            PDFKitView(url: self.fileUrl)
        }, label: {
            Text("text")
                .foregroundColor(.black)
        })
    }
}
struct PDFKitView: View {
    var url: URL
    var body: some View {
        PDFKitRepresentedView(url)
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let url: URL
    init(_ url: URL) {
        self.url = url
    }

    func makeUIView(context: UIViewRepresentableContext<PDFKitRepresentedView>) -> PDFKitRepresentedView.UIViewType {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.url)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PDFKitRepresentedView>) {
        // Update the view.
    }
}
