//
//  SuggestionsView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 27/4/23.
//

import SwiftUI
struct SuggestionsView: View {
    @State var isShowing  = true
    @State var isShowingDetailView = false
    @State private var selectedButton: ButtonCases = .fun
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
                                SuggestionButtonComponent(buttonEmoji: "🎓", buttonText:
                                    ButtonCases
                                    .promptsForMultipleChoice.rawValue,
                                                selectedButton:
                                                        $selectedButton, currentButton: .promptsForMultipleChoice) {
                                    selectedButton = .promptsForMultipleChoice
                                }
                                SuggestionButtonComponent(buttonEmoji: "😀",
                                                          buttonText: "Fun",
                                                          selectedButton: $selectedButton,
                                                          currentButton: .fun,
                                                          onTap: {
                                    selectedButton = .fun
                                })
                                .navigationDestination(isPresented: $isShowingDetailView, destination: { FunView() })
                                Group {
                                    SuggestionButtonComponent(buttonEmoji: "🎓",
                                                              buttonText: "Education",
                                                              selectedButton: $selectedButton,
                                                              currentButton: .education,
                                                              onTap: {
                                        selectedButton = .education
                                    })
                                    SuggestionButtonComponent(buttonEmoji: "✈️",
                                                              buttonText: "Travel",
                                                              selectedButton: $selectedButton,
                                                              currentButton: .travel, onTap: {
                                        selectedButton = .travel
                                    })
                                    SuggestionButtonComponent(buttonEmoji: "💪",
                                                              buttonText: "Business & Marketing",
                                                              selectedButton: $selectedButton,
                                                              currentButton: .businessAndMarketing,
                                                              onTap: {
                                        selectedButton = .businessAndMarketing
                                    })
                                    SuggestionButtonComponent(buttonEmoji: "👥",
                                                              buttonText: "Social",
                                                              selectedButton: $selectedButton,
                                                              currentButton: .social,
                                                              onTap: {
                                        selectedButton = .social
                                    })
                                    SuggestionButtonComponent(buttonEmoji: "🤵‍♂️",
                                                              buttonText: "Career",
                                                              selectedButton: $selectedButton,
                                                              currentButton: .career,
                                                              onTap: {
                                        selectedButton = .career
                                    })
                                }
                                Group {
                                    SuggestionButtonComponent(buttonEmoji: "",
                                                              buttonText: "10 Advanced Prompt",
                                                              selectedButton: $selectedButton,
                                                              currentButton: .advancedPrompt) {
                                        selectedButton = .advancedPrompt
                                    }
                                    SuggestionButtonComponent(buttonEmoji: "",
                                                              buttonText: "Legal section",
                                                              selectedButton: $selectedButton,
                                                              currentButton: .legalSectionPrompt) {
                                        selectedButton = .legalSectionPrompt
                                    }
                                    SuggestionButtonComponent(buttonEmoji: "",
                                                              buttonText: "Act As Adivisor",
                                                              selectedButton: $selectedButton,
                                                              currentButton: .actAsAdvisorPrompt) {
                                        selectedButton = .actAsAdvisorPrompt
                                    }
                                    SuggestionButtonComponent(buttonEmoji: "🌈",
                                                              buttonText: ButtonCases.promptForDesigners.rawValue,
                                                              selectedButton:
                                                                $selectedButton, currentButton: .promptForDesigners) {
                                        selectedButton  = .promptForDesigners
                                    }
                                    SuggestionButtonComponent(buttonEmoji: "💻", buttonText:
                                        ButtonCases
                                        .promptsForDevelopers.rawValue,
                                                    selectedButton:
                                                            $selectedButton, currentButton: .promptsForDevelopers) {
                                        selectedButton = .promptsForDevelopers
                                    }
                                    SuggestionButtonComponent(buttonEmoji: "🤵‍♂️", buttonText:
                                        ButtonCases
                                        .promptsForMarketers.rawValue,
                                                    selectedButton:
                                                            $selectedButton, currentButton: .promptsForMarketers) {
                                        selectedButton = .promptsForMarketers
                                    }
                                    SuggestionButtonComponent(buttonEmoji: "", buttonText:
                                        ButtonCases
                                        .promptForFinance.rawValue,
                                                    selectedButton:
                                                            $selectedButton, currentButton: .promptForFinance) {
                                        selectedButton = .promptForFinance
                                    }
                                    SuggestionButtonComponent(buttonEmoji: "🏠", buttonText:
                                        ButtonCases
                                        .promptsForRealEstate.rawValue,
                                                    selectedButton:
                                                            $selectedButton, currentButton: .promptsForRealEstate) {
                                        selectedButton = .promptsForRealEstate
                                    }
                                    SuggestionButtonComponent(buttonEmoji: "", buttonText:
                                        ButtonCases
                                        .promtsForEconomicsIndicators.rawValue,
                                                    selectedButton:
                                                                $selectedButton,
                                                              currentButton:
                                            .promtsForEconomicsIndicators) {
                                        selectedButton = .promtsForEconomicsIndicators
                                    }
                                }
                            }
                        }
                        switch selectedButton {
                        case .fun:
                            SelectedButtonView(items: funCategory.keys.map({String($0)}), dismiss: {
                                dismiss()
                            }, selectedButton: .fun)
                        case .education:
                            SelectedButtonView(items: educationCategory.keys.map({String($0)}), dismiss: {
                                dismiss()
                            }, selectedButton: .education)
                        case .travel:
                            SelectedButtonView(items: travel.keys.map({String($0)}), dismiss: {
                                dismiss()
                            }, selectedButton: .travel)
                        case .businessAndMarketing:
                            SelectedButtonView(items: businessAndMarketing.keys.map({String($0)}), dismiss: {
                                dismiss()
                            }, selectedButton: .businessAndMarketing)
                        case .social:
                            SelectedButtonView(items: social.keys.map({String($0)}), dismiss: {
                                dismiss()
                            }, selectedButton: .social)
                        case .career:
                            SelectedButtonView(items: career.keys.map({String($0)}), dismiss: {
                                dismiss()
                            }, selectedButton: .career)
                        case .advancedPrompt:
                            SelectedButtonView(items: advancedPrompt.keys.map({String($0)}), dismiss: {
                                dismiss()
                            }, selectedButton: .advancedPrompt)
                        case.legalSectionPrompt:
                            SelectedButtonView(items: legalSection.keys.map({String($0)}), dismiss: {
                                dismiss()
                            }, selectedButton: .legalSectionPrompt)
                        case .actAsAdvisorPrompt:
                            SelectedButtonView(items: actAsAdvisor.keys.map({String($0)}), dismiss: {
                                dismiss()
                            }, selectedButton: .actAsAdvisorPrompt)
                        case .promptForDesigners:
                            SelectedButtonView(items: designers.keys.map({String($0)}),
                                               dismiss: {
                                dismiss()
                            }, selectedButton: .promptForDesigners)
                        case .promptsForDevelopers:
                            SelectedButtonView(items: developers.keys.map({String($0)}), dismiss: {
                                dismiss()
                            }, selectedButton: .promptsForDevelopers)
                        case .promptsForMarketers:
                            SelectedButtonView(items: marketers.keys.map({String($0)}), dismiss: {
                                dismiss()
                            }, selectedButton: .promptsForMarketers)
                        case .promptsForMultipleChoice:
                            SelectedButtonView(items: multipleQuestion.keys.map({String(($0))}), dismiss: {
                                dismiss()
                            }, selectedButton: .promptsForMultipleChoice)
                        case .promptForFinance:
                            SelectedButtonView(items: finance.keys.map({String(($0))}), dismiss: {
                                dismiss()
                            }, selectedButton: .promptForFinance)
                        case .promptsForRealEstate:
                            SelectedButtonView(items: realEstate.keys.map({String(($0))}), dismiss: {
                                dismiss()
                            }, selectedButton: .promptsForRealEstate)
                        case .promtsForEconomicsIndicators:
                            SelectedButtonView(items: economic.keys.map({String(($0))}), dismiss: {
                                dismiss()
                            }, selectedButton: .promtsForEconomicsIndicators)
                        }
                    }
                    .padding(16)
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct SuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionsView()
    }
}
