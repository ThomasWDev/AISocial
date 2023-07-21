//
//  IntroductionScreenFour.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 12/7/23.
//
// swiftlint:disable line_length
import SwiftUI

struct IntroductionScreenFour: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var navViewModel = InitialNavigationViewModel.shared
    @StateObject var deviceVM = DeviceDetectViewModel.shared

    var body: some View {
        ZStack(alignment: .top) {
               topShape
                ScrollView {
                    VStack {
                        Spacer()
                        text
                        Spacer()
                        Spacer()
                         button
                            .padding(.bottom, 16)
                    }
                    .padding(.top, 130)
                    .frame(height: UIScreen.main.bounds.height)
                    .offset(y: deviceVM.currentDevice == .iPhone8 ? -43 : 0)
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
    private var text: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 300, height: 500)
                .foregroundColor(.white)
                .border(.blue, width: 5)
                .cornerRadius(10)
                .overlay {
                    Rectangle()
                        .overlay {
                            HStack {
                                Text("Write a paragraph on water pollution ")
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
                        .offset(y: -200)
                }
                .overlay {
                    VStack {
                        Rectangle()
                            .overlay(content: {
                                    Text("Water pollution is the contamination of water sources by substances which make the water unusable for drinking, cooking, cleaning, swimming, and other activities. Pollutants include chemicals, trash, bacteria, and parasites. All forms of pollution eventually make their way to water.!")
                                    .lineSpacing(2)
                                    .padding(16)
                                        .bold()
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                            })
                            .frame(width: 250, height: 250)
                            .foregroundColor(AppColors.shapeColor)
                            .cornerRadius(10)
                            .padding(.top, 100)
                        Text("Ask ")
                            .bold()
                            .font(.system(size: 40)) +
                        Text("any")
                            .foregroundColor(AppColors.shapeColor)
                            .bold()
                            .font(.system(size: 40))
                        Text("questions")
                            .foregroundColor(.black)
                            .bold()
                            .font(.system(size: 40))
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
    private var button: some View {
            Button {
                UserDefaults.standard.set(true, forKey: "showTab")
                navViewModel.shouldShowFirstTab = true
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
                .frame(width: UIScreen.main.bounds.width, height: 350)
            Spacer()
            bottomCurve
                .offset(y: 35)
        }
    }
    private var bottomCurve: some View {
        Image("bottomCurve")
            .resizable()
            .frame(width: UIScreen.main.bounds.width, height: 250)
        }
}

struct IntroductionScreenFour_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionScreenFour()
    }
}

class InitialNavigationViewModel: ObservableObject {
    static let shared = InitialNavigationViewModel()

    private init() { }

    @Published var shouldShowFirstTab = false
}

// swiftlint:enable line_length
