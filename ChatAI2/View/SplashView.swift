//
//  SplashView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 27/3/23.
//

import SwiftUI

struct SplashView: View {
    @State var isActive = false
    var body: some View {
        VStack {
            if self.isActive {
                SignInView()
            } else {
                Image("socialAI")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()+2.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
