//
//  MailView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 20/7/23.
//

import SwiftUI
import MessageUI

public struct MailView: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    public var configure: ((MFMailComposeViewController) -> Void)?

    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }

        public func mailComposeController(_ controller: MFMailComposeViewController,
                                          didFinishWith result: MFMailComposeResult,
                                          error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result)
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) ->
    MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = context.coordinator
        configure?(viewController)
        return viewController
    }

    public func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: UIViewControllerRepresentableContext<MailView>) {

    }
}
