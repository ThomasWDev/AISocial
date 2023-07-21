//
//  ButtonComponents.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 24/3/23.
//

import SwiftUI

struct ButtonComponents: View {
    var buttonName: String
    var bgColor: Color
    var onTap: () -> Void
    var body: some View {
        Button {
            onTap()
        } label: {
            Text(buttonName)
                .padding()
                .frame(maxWidth: .infinity)
                .background(bgColor)
                .cornerRadius(10)
                .foregroundColor(.white)
        }
    }
}

struct ButtonComponents_Previews: PreviewProvider {
    static var previews: some View {
        ButtonComponents(buttonName: "Log In", bgColor: .blue, onTap: {})
    }
}
