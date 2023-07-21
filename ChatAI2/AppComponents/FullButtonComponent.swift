//
//  FullButtonComponent.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 27/4/23.
//

import SwiftUI

struct FullButtonComponent: View {
    @StateObject var viewModel = TextGeneratorViewModel.shared
    var buttonName: String
    let dismiss: () -> Void
    let category: ButtonCases
    var body: some View {
        Button {
            switch category {
            case .fun:
                viewModel.question = funCategory[buttonName] ?? ""
            case .education:
                viewModel.question = educationCategory[buttonName] ?? ""
            case .travel:
                viewModel.question = travel[buttonName] ?? ""
            case .businessAndMarketing:
                viewModel.question = businessAndMarketing[buttonName] ?? ""
            case .social:
                viewModel.question = social[buttonName] ?? ""
            case .career:
                viewModel.question = career[buttonName] ?? ""
            case .advancedPrompt:
                viewModel.question = advancedPrompt[buttonName] ?? ""
            case .legalSectionPrompt:
                viewModel.question = legalSection[buttonName] ?? ""
            case .actAsAdvisorPrompt:
                viewModel.question = actAsAdvisor[buttonName] ?? ""
            case .promptForDesigners:
                viewModel.question = designers[buttonName] ?? ""
            case .promptsForDevelopers:
                viewModel.question = developers[buttonName] ?? ""
            case .promptsForMarketers:
                viewModel.question = marketers[buttonName] ?? ""
            case .promptsForMultipleChoice:
                viewModel.question = multipleQuestion[buttonName] ?? ""
            case .promptForFinance:
                viewModel.question = finance[buttonName] ?? ""
            case .promptsForRealEstate:
                viewModel.question = realEstate[buttonName] ?? ""
            case .promtsForEconomicsIndicators:
                viewModel.question = economic[buttonName] ?? ""
            }
          // viewModel.question = PromptCategorySuggestion.educationCategory[buttonName] ?? ""
            dismiss()
        } label: {
            Text(buttonName)
                .bold()
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.backgroundColor.opacity(0.8))
                .cornerRadius(10)
                .foregroundColor(.white)
        }
    }
}

struct PdfFullButtonComponent: View {
    @StateObject var viewModel = TextGeneratorViewModel.shared
    var buttonName: String
    let dismiss: () -> Void
    let category: ButtonCasesPdf
    var body: some View {
        Button {
            switch category {
            case .review:
                viewModel.pdfSuggestion = review[buttonName] ?? ""
           /* case .promptForDesigners:
                viewModel.question = designers[buttonName] ?? ""
            case .promptsForDevelopers:
                viewModel.question = developers[buttonName] ?? ""
            */
            case .promptsForLegalResearch:
                viewModel.pdfSuggestion = legalResearch[buttonName] ?? ""
            }
        viewModel.fromPdfSuggestions = true
          // viewModel.question = PromptCategorySuggestion.educationCategory[buttonName] ?? ""
            dismiss()
        } label: {
            Text(buttonName)
                .bold()
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.backgroundColor.opacity(0.8))
                .cornerRadius(10)
                .foregroundColor(.white)
        }

    }
}
