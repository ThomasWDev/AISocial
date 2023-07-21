//
//  SuggestionButtonComponent.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 27/4/23.
//

import SwiftUI

struct SuggestionButtonComponent: View {
    var buttonEmoji: String
    var buttonText: String
    @State var isSelected = false
    @Binding var selectedButton: ButtonCases
    let currentButton: ButtonCases
    var onTap: () -> Void
    var body: some View {
        HStack {
            Button {
                onTap()
                isSelected.toggle()
            } label: {
                Text(buttonEmoji)
                Text(buttonText)
            }
            .bold()
            .padding(16)
            .background(selectedButton == currentButton ?
                        AppColors.promptColor.opacity(0.7):AppColors.backgroundColor.opacity(0.4))
            .cornerRadius(10)
            .shadow(radius: 5)
            .foregroundColor(.white)
        }
    }
}
struct PdfSuggestionButtonComponent: View {
    var buttonEmoji: String
    var buttonText: String
    @State var isSelected = false
    @Binding var selectedButton: ButtonCasesPdf
    let currentButton: ButtonCasesPdf
    var onTap: () -> Void
    var body: some View {
        HStack {
            Button {
                onTap()
                isSelected.toggle()
            } label: {
                Text(buttonEmoji)
                Text(buttonText)
            }
            .bold()
            .padding(16)
            .background(selectedButton == currentButton ?
                        AppColors.promptColor.opacity(0.7):AppColors.backgroundColor.opacity(0.4))
            .cornerRadius(10)
            .shadow(radius: 5)
            .foregroundColor(.white)
        }
    }
}
