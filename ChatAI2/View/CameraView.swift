//
//  CameraView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 23/6/23.
//

import SwiftUI

struct CameraView: View {
    @Binding var showActionSheet: Bool
    @Binding var closeSheet: Bool
    var body: some View {
        NavigationView {
            ScrollView {
                Image(systemName: "doc.viewfinder.fill")
                    .resizable()
                    .frame(width: 200, height: 200)
                scanImage
            }
            .navigationTitle("Scaner view")
            .navigationBarTitleDisplayMode(.automatic)
            .padding(.top, 50)
        }
    }
    private var scanImage: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Scan a Text")
                .bold()
                .font(.system(size: 30))
            Text("You can scan a text with your camera and send it to AISocial")
            Button {
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5, execute: {
                    showActionSheet = true
                })
                closeSheet = false
            } label: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black)
                    .frame(height: 50)
                    .overlay {
                        Text("Continue")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
            }
        }
        .padding(16)
    }
}
// struct CameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraView()
//    }
// }
