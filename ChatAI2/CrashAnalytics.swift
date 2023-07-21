//
//  CrashAnalytics.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 29/5/23.
//

import SwiftUI

struct CrashAnalytics: View {
    var body: some View {
        Button("Crash") {
          fatalError("Crash was triggered")
        }
    }
}

struct CrashAnalytics_Previews: PreviewProvider {
    static var previews: some View {
        CrashAnalytics()
    }
}
