//
//  AlertView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 7/7/23.
//
// swiftlint:disable line_length
import SwiftUI

struct AlertView: View {
    var body: some View {
        VStack {
            icon
            oops
        }
    }
        private var icon: some View {
                Image("icon")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(25)
        }
    private var oops: some View {
        VStack(spacing: 20) {
            Text("Oops!")
                .bold()
                .font(.system(size: 20))
            Text("Your query is 2248 characters long.it exceeds the 500-character limit.To send longer messages,please upgrade to PRO")
                .font(.system(size: 20))
                .lineLimit(4)
                .lineSpacing(5)
            Button {
            } label: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black)
                    .frame(height: 50)
                    .overlay {
                        HStack {
                            Text("Update to Pro")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                            Text("🚀")
                        }
                    }
            }
            Button {
            } label: {
                Text("Cancel")
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(.black)
            }
        }
         .padding(16)
    }
}
struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView()
    }
}
// swiftlint:enable line_length
