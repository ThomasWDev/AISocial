//
//  IntroductionScreenTwo.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 11/7/23.
//

import SwiftUI

struct IntroductionScreenTwo: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var deviceVM = DeviceDetectViewModel.shared
    var body: some View {
        ZStack(alignment: .top) {
               topShape
                ScrollView {
                    VStack {
                        Spacer()
                        logo
                        text
                        Spacer()
                        Spacer()
                        button
                            .padding(.bottom, deviceVM.currentDevice == .iPhoneX ?  50 : 0)
                    }
                    .padding(.top, 130)
                    .frame(height: UIScreen.main.bounds.height)
                    .offset(y: deviceVM.currentDevice == .iPhone8 ? -70 : 0)
                }
        }
        .overlay(alignment: .topLeading) {
                Image(systemName: "chevron.left")
                  .font(.system(size: 35))
                  .foregroundColor(.white)
                  .offset(x: 20, y: 40)
                  .padding(20)
                  .onTapGesture {
                    dismiss()
                  }
            }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    private var logo: some View {
            Image("rectangle")
                .resizable()
            .frame(width:
                    deviceVM.currentDevice == .iPhone8 ? 250 : 300,
                   height: deviceVM.currentDevice == .iPhone8 ? 250 : 300)
              //  .padding(.top, 20)
              .overlay(alignment: .center) {
            VStack {
                Image("talkImage")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.top, 20)
                Text("Ask questions")
                    .bold()
                    .font(.system(size: 20))
            }
    }
    }
    private var button: some View {
        NavigationLink {
            IntroductionScreenThree()
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .frame(width: UIScreen.main.bounds.width/1.25, height: 70)
                .padding(16)
                .overlay {
                    Text("Continue")
                        .bold()
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                }
        }
    }
    private var topShape: some View {
        VStack {
            Image("topCurve")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: 250)
             Spacer()
            bottomCurve
        }
    }
    private var bottomCurve: some View {
        Image("bottomCurve")
            .resizable()
            .frame(width: UIScreen.main.bounds.width, height: 200)
        }
    private var text: some View {
        VStack(alignment: .center, spacing: 6) {
            Text("Let’s Talk with")
                .foregroundColor(AppColors.shapeColor)
                .bold()
                .font(.system(size: 35))
            Text("AISocial")
                .foregroundColor(.black)
                .bold()
                .font(.system(size: 35))
            Text("Just type what you want to know and our expert bot will instant serve your needs")
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(AppColors.shapeColor)
        }
        .padding(16)
    }
}

struct IntroductionScreenTwo_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionScreenTwo()
    }
}
