//
//  DeviceDetectViewModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 13/7/23.
//
// swiftlint:disable discouraged_direct_init

import Foundation
import SwiftUI

class DeviceDetectViewModel: ObservableObject {
    @Published var currentDevice = Device.iPhoneAbove8
    static let shared = DeviceDetectViewModel()
    let device = UIDevice()

    private init() {
        detectDevice()
    }

    func detectDevice() {
        if device.userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                currentDevice = .iPhone8
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                currentDevice = .iPhoneX
                print("iPhone X/XS/11 Pro")
            case 2688:
                print("iPhone XS Max/11 Pro Max")
            case 1792:
                print("iPhone XR/ 11 ")
            default:
                print("Unknown")
            }
        }
    }
}

enum Device: String {
    case iPhone8
    case iPhoneAbove8
    case iPhoneX
}

// swiftlint:enable discouraged_direct_init
