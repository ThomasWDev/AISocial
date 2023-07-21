//
//  ChatGPTPromptModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 5/5/23.
//

import Foundation

struct ChatGPTPromptModel: Hashable, Identifiable {
    var id = UUID().uuidString
    var funny: String
}
