//
//  IAPCardComponent.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 19/7/23.
//

import SwiftUI

struct IAPCardComponent: View {
    var imageIcon: String
    var boldText: String
    var normalText: String
    var body: some View {
            RoundedRectangle(cornerRadius: 10)
            .stroke(AppColors.buttonColor, lineWidth: 3)
            .padding(.horizontal, 16)
                    .frame(width: UIScreen.main.bounds.width, height: 70)
                   .overlay {
                        HStack {
                            Spacer()
                            Image(imageIcon)
                                .resizable()
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading) {
                                Text(boldText)
                                    .bold()
                                    .foregroundColor(AppColors.themeColor)
                                Text(normalText)
                            }
                            Spacer()
                            Spacer()
                        }
                        .padding(.trailing, 32)
               }
    }
}

struct IAPCardComponent_Previews: PreviewProvider {
    static var previews: some View {
        IAPCardComponent(imageIcon: "handIcon", boldText: "Powered by GPT 4", normalText: "Latest ChatGPT AI Model")
    }
}
