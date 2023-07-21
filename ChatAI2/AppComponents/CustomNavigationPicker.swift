//
//  CustomNavigationPicker.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 6/4/23.
//

import SwiftUI

struct CustomNavigationPicker: View {
    var items: [String]
    @Binding var selectedItem: String
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                HStack {
                    Text(item)
                    Spacer()
                    if item == selectedItem {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.green)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedItem = item
                }
            }
        }
        .navigationTitle("Select Item")
    }
}

struct CustomNavigationPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationPicker(items: ["A", "B", "C"], selectedItem: .constant("A"))
    }
}
