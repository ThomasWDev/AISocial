//
//  ChatAI2App.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 22/2/23.
//

import SwiftUI
import Firebase
import RevenueCat

@main
struct ChatAI2App: App {
    init() {
        FirebaseApp.configure()
    }
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var launchScreenState = LaunchScreenStateManager()
    @StateObject private var navViewModel = InitialNavigationViewModel.shared
    @StateObject private var iapVM = InAppPurchaseViewModel.shared
    @AppStorage("showTab") var showTab = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showTab {
                    ChatGPTTabBar()
                } else if navViewModel.shouldShowFirstTab {
                    ChatGPTTabBar()
                } else {
                    NavigationStack {
                         IntroductionScreenOne()
                    }
                }

                if launchScreenState.state != .finished {
                    LaunchScreenView()
                        .task {
                            try? await Task.sleep(for: Duration.seconds(3))
                            self.launchScreenState.dismiss()
                        }
                }
            }.environmentObject(launchScreenState)
            .preferredColorScheme(.light)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_PiVRaEiaOnlvsdDactPKfSalyvH")
        return true
    }
}
