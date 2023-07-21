//
//  PdfSuggestionView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 5/6/23.
//

import SwiftUI

struct PdfSuggestionsView: View {
    @State var isShowing  = true
    @State var isShowingDetailView = false
    @State private var selectedButton: ButtonCasesPdf = .review
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.suggestionsColor.opacity(0.8)
                ScrollView {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Suggestions")
                                .bold()
                                .foregroundColor(.white)
                            Image(systemName: "lightbulb.led.fill")
                                .foregroundColor(.white)
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                PdfSuggestionButtonComponent(buttonEmoji: "👍",
                                                             buttonText: ButtonCasesPdf.review.rawValue,
                                                             selectedButton: $selectedButton,
                                                             currentButton: .review,
                                                             onTap: {
                                    selectedButton = .review
                                })
                                PdfSuggestionButtonComponent(buttonEmoji: "",
                                                            buttonText: ButtonCasesPdf.promptsForLegalResearch.rawValue,
                                                             selectedButton: $selectedButton,
                                                             currentButton: .promptsForLegalResearch,
                                                             onTap: {
                                    selectedButton = .promptsForLegalResearch
                                })
                                /*
                                PdfSuggestionButtonComponent(buttonEmoji: "",
                                                             buttonText: ButtonCasesPdf.promptForDesigners.rawValue,
                                                             selectedButton: $selectedButton,
                                                             currentButton: .promptForDesigners,
                                                             onTap: {
                                    selectedButton = .promptForDesigners
                                })
                                PdfSuggestionButtonComponent(buttonEmoji: "",
                                                             buttonText: ButtonCasesPdf.promptsForDevelopers.rawValue,
                                                             selectedButton: $selectedButton,
                                                             currentButton: .promptsForDevelopers,
                                                             onTap: {
                                    selectedButton = .promptsForDevelopers
                                })
                                 */
                            }
                        }
                            switch selectedButton {
                            case .review:
                                PdfSelectedButtonView(items: review.keys.map({String($0)}), dismiss: {
                                    dismiss()
                                }, selectedButton: .review)
                           /* case .promptForDesigners:
                                PdfSelectedButtonView(items: designers.keys.map({String($0)}), dismiss: {
                                    dismiss()
                                }, selectedButton: .promptForDesigners)
                            case .promptsForDevelopers:
                                PdfSelectedButtonView(items: developers.keys.map({String($0)}), dismiss: {
                                    dismiss()
                                }, selectedButton: .promptsForDevelopers)
                            */
                            case .promptsForLegalResearch:
                                PdfSelectedButtonView(items: legalResearch.keys.map({String($0)}), dismiss: {
                                    dismiss()
                                }, selectedButton: .promptsForLegalResearch)
                            }
                    }
                    .padding(16)
                }
            }
            .ignoresSafeArea()
        }
    }
    struct PdfSuggestionsView_Previews: PreviewProvider {
        static var previews: some View {
            PdfSuggestionsView()
        }
    }
}
enum ButtonCasesPdf: String {
    case review = "Review"
    case promptsForLegalResearch = "Legal Research"
    /*case promptForDesigners = "Designers"
    case promptsForDevelopers = "Developer" */
}
