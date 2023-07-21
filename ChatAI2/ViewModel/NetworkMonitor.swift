//
//  NetworkMonitor.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 27/6/23.
//

import Foundation
import Network
import SwiftUI

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    @Published var isConnected = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied ? true : false
            }
        }
        monitor.start(queue: queue)
    }
}

struct NointernetView: ViewModifier {
    @Binding var isConnected: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if !isConnected {
                    VStack {
                        Image(systemName: "wifi.slash")
                        Text("No Internet Connection is Available!")
                    }
                    .foregroundColor(.white)
                    .padding(30)
                    .background(.black)
                    .cornerRadius(12)
                }
            }
    }
}

extension View {
    func noInternetView(isConnected: Binding<Bool>) -> some View {
        modifier(NointernetView(isConnected: isConnected))
    }
}
