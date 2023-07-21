//
//  LaunchScreenView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 17/5/23.
//

import Foundation
import SwiftUI

struct LaunchScreenView: View {
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager

    @State private var firstAnimation = false
    @State private var secondAnimation = false
    @State private var startFadeoutAnimation = false

    @ViewBuilder
    private var image: some View {
        Image(systemName: "hurricane")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .rotationEffect(firstAnimation ? Angle(degrees: 900) : Angle(degrees: 1800))
            .scaleEffect(secondAnimation ? 0 : 1)
            .offset(y: secondAnimation ? 400 : 0)
    }

    @ViewBuilder
    private var backgroundColor: some View {
        Color.orange.ignoresSafeArea()
    }

    private let animationTimer = Timer
        .publish(every: 1, on: .current, in: .common)
        .autoconnect()
    var body: some View {
        ZStack {
            backgroundColor
            image
        }.onReceive(animationTimer) { _ in
            updateAnimation()
        }.opacity(startFadeoutAnimation ? 0 : 1)
    }
    private func updateAnimation() {
        switch launchScreenState.state {
        case .firstStep:
            withAnimation(.easeInOut(duration: 1)) {
                firstAnimation.toggle()
            }
        case .secondStep:
            if secondAnimation == false {
                withAnimation(.linear) {
                    self.secondAnimation = true
                    startFadeoutAnimation = true
                }
            }
        case .finished:
            break
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
            .environmentObject(LaunchScreenStateManager())
    }
}

enum LaunchScreenStep {
    case firstStep
    case secondStep
    case finished
}

final class LaunchScreenStateManager: ObservableObject {

@MainActor @Published private(set) var state: LaunchScreenStep = .firstStep
    @Published var firstTime = true

    @MainActor func dismiss() {
        Task {
            state = .secondStep

            if firstTime {
                try? await Task.sleep(for: Duration.seconds(1))
            }

            firstTime = false
            self.state = .finished
        }
    }
}
