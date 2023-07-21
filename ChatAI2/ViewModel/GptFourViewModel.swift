//
//  GptFourViewModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 10/7/23.
//

import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages = [Message]()
    @Published var currentInput = ""
    private let openAIService = OpenAIService()

    func sendMessage() {
        let newMessage = Message(id: UUID().uuidString, content: currentInput, createdAt: .now, senderRole: .user)
        messages.append(newMessage)
        currentInput = ""

        Task {
            let response = await openAIService.sendMessage(messages: messages)
            guard let aiMessage = response?.choices.first?.message else {
                print("Had No Receive Message")
                return
            }

            let recievedMessage = Message(id: UUID().uuidString, content: aiMessage.content,
                                          createdAt: Date(),
                                          senderRole: SenderRole(rawValue: aiMessage.role) ?? .user)
            await MainActor.run {
                messages.append(recievedMessage)
            }
        }
    }
}

struct Message: Codable {
    let id: String
    let content: String
    let createdAt: Date
    let senderRole: SenderRole
}

import Alamofire

class OpenAIService {
    private let openAIEndPointURL = "https://api.openai.com/v1/chat/completions"
    func sendMessage(messages: [Message]) async -> OpenAIChatResponse? {
        let openAIMessages = messages.map({AIMessage(role: $0.senderRole.rawValue, content: $0.content)})
        let body = OpenAIChatBody(model: "gpt-4", messages: openAIMessages, stream: false)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAIApiKey)"
        ]

        do {
            let response =  try await AF.request(openAIEndPointURL,
                                                 method: .post,
                                                 parameters: body,
                                                 encoder: .json,
                                                 headers: headers).serializingDecodable(OpenAIChatResponse.self).value
            print(response.model.first ?? "No Model", response.model, "MODEL")
            return response
        } catch {
            print(error, "ERROR")
            return nil
        }
    }

    func sendStreamMessage(messages: [Message]) -> DataStreamRequest {
        let openAIMessages = messages.map({AIMessage(role: $0.senderRole.rawValue, content: $0.content)})
        let body = OpenAIChatBody(model: "gpt-4", messages: openAIMessages, stream: true)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAIApiKey)"
        ]
        return AF.streamRequest(openAIEndPointURL, method: .post, parameters: body, encoder: .json, headers: headers)
    }
}

struct ChatStreamCompletionResponse: Decodable {
    let id: String
    let choices: [ChatStreamChoice]
}

struct ChatStreamChoice: Decodable {
    let delta: ChatStreamContent
}

struct ChatStreamContent: Decodable {
    let content: String
}

struct OpenAIChatBody: Encodable {
    let model: String
    let messages: [AIMessage]
    let stream: Bool
}

// MARK: - OpenAIChatResponse
struct OpenAIChatResponse: Codable {
    let id, object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
}

// MARK: - Choice
struct Choice: Codable {
    let index: Int
    let message: AIMessage
    let finishReason: String

    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

// MARK: - Message
struct AIMessage: Codable {
    let role, content: String
}

// MARK: - Usage
struct Usage: Codable {
    let promptTokens, completionTokens, totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

enum SenderRole: String, Codable {
    case system
    case user
    case assistant
}

struct Constants {
    static func getStringValueFromInfoPlist(forKey key: String) -> String {
        // 1: Locate Info Plist
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            fatalError("Couldn't find file 'Info.plist'.")
        }
        // 2: Search key
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: key) as? String else {
            fatalError("Couldn't find key \(key) in 'Info.plist'.")
        }
        // 3: Check if value is blank
        if value.isEmpty {
            fatalError("API KEY IS EMPTY")
        }
        // 4: return value
        return value

    }
    static var openAIApiKey: String {
        return Constants.getStringValueFromInfoPlist(forKey: "OPENAI_API_KEY")
    }
}
