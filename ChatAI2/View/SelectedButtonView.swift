//
//  SelectedButtonView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 8/5/23.
//

import SwiftUI
struct SelectedButtonView: View {
    let items: [String]
    let dismiss: () -> Void
    let selectedButton: ButtonCases
    var body: some View {
        VStack {
            ForEach(items, id: \.self) { item in
                FullButtonComponent(buttonName: item, dismiss: dismiss, category: selectedButton)
            }
        }
    }
}
struct PdfSelectedButtonView: View {
    let items: [String]
    let dismiss: () -> Void
    let selectedButton: ButtonCasesPdf
    var body: some View {
        VStack {
            ForEach(items, id: \.self) { item in
                PdfFullButtonComponent(buttonName: item, dismiss: dismiss, category: selectedButton)
            }
        }
    }
}
