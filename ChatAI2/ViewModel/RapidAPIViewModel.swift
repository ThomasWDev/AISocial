//
//  RapidAPIViewModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 4/4/23.
//

/*

import Foundation
import OpenAISwift

class RapidAPIViewModel: ObservableObject {
    let baseballAPIEndpoint = "https://api-baseball.p.rapidapi.com/teams?league=1&season=2020"
    @Published var movieData: MovieAPIModel?
    private var client: OpenAISwift?
    @Published var isLoading = false
    @Published var chatGPTResponse: String?
    init() {
        setUp()
    }
    func onAppear() {
        chatGPTResponse = nil
        getDataFromRapidAPI()
    }
    private func getDataFromRapidAPI() {
        isLoading = true
        APIService.getRequest(urlString: baseballAPIEndpoint) {(completion: Result<BaseBallModel, NetworkingError>) in
            switch completion {
            case .success(let result):
                self.send(text: result.response?.first?.name ?? "Year 3000") { responseFromChatGPT in
                    self.chatGPTCompletionHandler(response: responseFromChatGPT)
                }
            case .failure(let error):
                print("debug: rapid api error ", error)
            }
        }
    }
    func chatGPTCompletionHandler(response: String) {
        DispatchQueue.main.async {
            self.chatGPTResponse = response
            self.isLoading = false
        }
    }
    func send(text: String, completion: @escaping(String) -> Void) {
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: { result in
            switch result {
            case.success(let model):
                let output = model.choices.first?.text ?? ""
                print("GPT Response:", output)
                completion(output)
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                self.isLoading = false
            }
        })
    }
    func setUp() {
        client = OpenAISwift(authToken: Constants.openAIApiKey)
    }
}
*/
