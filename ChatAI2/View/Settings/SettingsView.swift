//
//  SettingsView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 19/6/23.
//

import SwiftUI
import StoreKit
import MessageUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State var result: Result<MFMailComposeResult, Error>?
    @State var isShowingMailView = false

    var body: some View {
            VStack {
                nav
                GeometryReader { geo in
                    ScrollView(showsIndicators: false) {
                        twoComponents
                        threeComponents
                        fourComponents
                    }
                    .frame(height: geo.size.height)
                    .padding(.top, 10)
                    .padding(.horizontal, 16)
                    .background(.white)
                    .cornerRadius(12)
                    .padding(20)
                    .offset(y: -75)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
    }

    var nav: some View {
        ZStack(alignment: .top) {
            Image("topShape")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: 150)
            HStack(alignment: .center) {
                Image(systemName: "chevron.left")
                     .padding(.leading, 16)
                    .onTapGesture {
                        dismiss()
                    }
                Spacer()
                Text("Settings")
                  .padding(.trailing, 32)
                Spacer()
//                Image(systemName: "ellipsis")
//                    .font(.system(size: 30))
//                    .rotationEffect(Angle(degrees: 90))
//                    .padding(.trailing, 16)
            }
            .bold()
            .font(.system(size: 30))
            .padding(.top, 70)
            .foregroundColor(.white)
            .background(AppColors.themeColor)
        }
    }

    func settingsComponent(iconNmae: String, text: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 20) {
                Image(iconNmae)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    Text(text)
                    Spacer()
            }
            .font(.system(size: 18))
            .foregroundColor(.white)
            .padding(20)
            .background(AppColors.themeColor)
        }
    }

    @ViewBuilder
    func emailComponent(iconNmae: String, text: String, url: String) -> some View {
        if MFMailComposeViewController.canSendMail() {
            Button {
                self.isShowingMailView = true
            } label: {
                HStack(spacing: 20) {
                    Image(iconNmae)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text(text)
                    Spacer()
                }
                .font(.system(size: 18))
                .foregroundColor(.white)
                .padding(20)
                .background(AppColors.themeColor)
            }
            .sheet(isPresented: $isShowingMailView) {
                       MailView(result: $result) { composer in
                           composer.setSubject("About AI Social")
                           composer.setToRecipients(["Who@gmail.com"])
                       }
                   }
        } else {
            Text("Can't send emails from this device")
        }
    }
    var fourComponents: some View {
        VStack(spacing: 1) {
            settingsComponent(iconNmae: "privacy", text: "Privacy Policy",
                              url: "https://testflight.apple.com/join/QvjityE7")
            settingsComponent(iconNmae: "restore", text: "Restore Purchase", url: "https://www.google.com")
            settingsComponent(iconNmae: "community", text: "Community Guideline",
                              url: "https://testflight.apple.com/join/QvjityE7")
            settingsComponent(iconNmae: "about", text: "About", url: "https://www.google.com")
        }
        .cornerRadius(12)
    }
    var twoComponents: some View {
        VStack(spacing: 1) {
          //  settingsComponent(iconNmae: "email", text: "Email Support")
            emailComponent(iconNmae: "email", text: "Email Support", url: "")
                .cornerRadius(12)
            settingsComponent(iconNmae: "share", text: "Share AISocial", url: "https://www.facebook.com")
          //  settingsComponent(iconNmae: "like", text: "Like us, Rate us?", url:  "https://www.google.com")
        }
        .cornerRadius(12)
    }

    var threeComponents: some View {
        VStack(spacing: 1) {
            settingsComponent(iconNmae: "twitter", text: "Follow on Twitter", url: "https://twitter.com/")
            settingsComponent(iconNmae: "terms", text: "Terms of Service", url: "https://www.google.com")
            settingsComponent(iconNmae: "reddit", text: "Follow on Reddit", url: "https://www.reddit.com/")
        }
        .cornerRadius(12)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
