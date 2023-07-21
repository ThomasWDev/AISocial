//
//  BaseBallAPIModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 5/4/23.
//

import Foundation

// let baseBallAPIModel = try? JSONDecoder().decode(BaseBallAPIModel.self, from: jsonData)

// MARK: - BaseBallAPIModel
struct BaseBallModel: Codable {
    let baseBallAPIModelGet: String?
    let parameters: Parameters?
    let errors: [String]?
    let results: Int?
    let response: [Response]?

    enum CodingKeys: String, CodingKey {
        case baseBallAPIModelGet = "get"
        case parameters, errors, results, response
    }
}

// MARK: - Parameters
struct Parameters: Codable {
    let league, season: String?
}

// MARK: - Response
struct Response: Codable {
    let id: Int?
    let name: String?
    let logo: String?
    let national: Bool?
    let country: Country?
}

// MARK: - Country
struct Country: Codable {
    let id: Int?
    let name: Name?
    let code: Code?
    let flag: String?
}

enum Code: String, Codable {
    case unitedState = "US"
}

enum Name: String, Codable {
    case usa = "USA"
}
