//
//  IntroductionScreenThree.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 11/7/23.
//

import SwiftUI

struct IntroductionScreenThree: View {
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
                            .padding(.bottom, 16)
                    }
                    .padding(.top, 130)
                 .frame(height: UIScreen.main.bounds.height)
                 .offset(y: deviceVM.currentDevice == .iPhone8 ? -60 : 0)
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
        VStack {
            Image("rectangle")
                .resizable()
                .frame(width: 300, height: 300)
                .padding(.top, 20)
            .overlay {
                VStack {
                    Spacer()
                    Rectangle()
                        .overlay(content: {
                            HStack {
                                Text("Hi!")
                                    .bold()
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                Image("hand")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                            }
                        })
                        .frame(width: 200, height: 70)
                        .foregroundColor(AppColors.shapeColor)
                        .cornerRadius(10)
                    Spacer()
                    Rectangle()
                        .overlay {
                            HStack {
                                Text("What can you do?")
                                    .bold()
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .padding(.trailing, 70)
                            }
                        }
                        .frame(width: 250, height: 70)
                        .foregroundColor(AppColors.shapeColor)
                        .cornerRadius(10)
                        .padding(.leading, 50)
                        .overlay {
                            Image("girl")
                                .resizable()
                                .frame(width: 100, height: 180)
                                .padding(.leading, 190)
                                .offset(x: 25)
                        }
                    Spacer()
                }
            }
            .overlay(alignment: .leading) {
                Image("AI")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 200)
                    .offset(x: -25)
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
                .offset(y: 35)
        }
    }
    private var button: some View {
            NavigationLink {
                IntroductionScreenFour()
            } label: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                    .frame(width: UIScreen.main.bounds.width/1.25, height: 70)
                    .padding(16)
                    .overlay {
                        Text("Let’s go")
                            .bold()
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                    }
            }
    }
    private var bottomCurve: some View {
            Image("bottomCurve")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: 200)
        }
    private var text: some View {
        VStack(alignment: .center) {
            Text("Your personal")
                .foregroundColor(AppColors.shapeColor)
                .bold()
                .font(.system(size: 40))
            Text("Assistant")
                .foregroundColor(.black)
                .bold()
                .font(.system(size: 40))
            Text("Communicate with the most sophisticated AI on your phone.")
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(AppColors.shapeColor)
        }
        .padding(16)
    }
}

struct IntroductionScreenThree_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionScreenThree()
    }
}
