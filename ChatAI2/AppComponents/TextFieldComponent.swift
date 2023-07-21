//
//  TextFieldComponent.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 24/3/23.
//

import SwiftUI

struct TextFieldComponent: View {
    @State var email = ""
    @State var  password = ""
    var body: some View {
        TextField("Email", text: $email)
            .padding(8)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke()
            }
    }
}

struct TextFieldComponent_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldComponent()
    }
}
