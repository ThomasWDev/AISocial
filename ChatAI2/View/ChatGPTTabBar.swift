//
//  ChatGPTTabBar.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 8/3/23.
//

import SwiftUI
struct ChatGPTTabBar: View {
    @StateObject private var network = NetworkMonitor.shared
    var body: some View {
        TabView {
            NavigationStack {
                ContentView()
                    .noInternetView(isConnected: $network.isConnected)
            } .tabItem {
                Label("Chat", systemImage: "text.bubble.fill")
            }
            ImageGeneratorView()
                .noInternetView(isConnected: $network.isConnected)
                .tabItem {
                    Label("Image Art", systemImage: "square.and.pencil")
                }
            PdfView()
                .noInternetView(isConnected: $network.isConnected)
                .tabItem {
                    Label("PDF Upload", systemImage: "arrow.up")
                }

            NavigationStack {
                AuthView()
                    .noInternetView(isConnected: $network.isConnected)
            }.tabItem {
                Label("Social", systemImage: "paperplane.fill")
            }
        }
        .accentColor(AppColors.themeColor)
        .navigationBarBackButtonHidden(true)
    }
}

struct ChatGPTTabBar_Previews: PreviewProvider {
    static var previews: some View {
        ChatGPTTabBar().environmentObject(LaunchScreenStateManager())
    }
}
