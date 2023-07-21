//
//  ImageGenerateViewModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 9/3/23.
//

import Foundation
import OpenAIKit
import SwiftUI

class ImageGeneratorViewModel: ObservableObject {
    @Published var text = ""
    @Published var image: Image?
    @Published var isLoading = false
    @Published var isShareLinkEnable = false
    private var openAI: OpenAI?
    func setup() {
        openAI = OpenAI(Configuration(
            organizationId: "Personal",
            apiKey: Constants.openAIApiKey
        ))
    }
    func generateImage(prompt: String) async -> Image? {
        guard let openAI = openAI else {return nil}
        do {
            let params = ImageParameters(
                prompt: prompt,
                resolution: .medium,
                responseFormat: .base64Json)
            let result = try await openAI.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openAI.decodeBase64Image(data)
            DispatchQueue.main.async {
                self.isShareLinkEnable = true
            }
            return Image(uiImage: image)
        } catch {
            print(String(describing: error))
            return nil}
    }
}
