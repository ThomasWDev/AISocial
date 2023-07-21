//
//  MovieAPIModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 4/4/23.
//

import Foundation

//   let movieAPIModel = try? JSONDecoder().decode(MovieAPIModel.self, from: jsonData)

// MARK: - MovieAPIModel
struct MovieAPIModel: Codable {
    let page: Int?
    let next: String?
    let entries: Int?
    let results: [ResultModel]?
}

// MARK: - Result
struct ResultModel: Codable {
    let id: String?
    let primaryImage: PrimaryImage?
    let titleType: TitleType?
    let titleText: TitleText?
    let releaseYear: ReleaseYear?
    let releaseDate: ReleaseDate?
}

// MARK: - PrimaryImage
struct PrimaryImage: Codable {
    let id: String?
    let width, height: Int?
    let url: String?
    let caption: Caption?
    let typename: String?

    enum CodingKeys: String, CodingKey {
        case id, width, height, url, caption
        case typename = "__typename"
    }
}

// MARK: - Caption
struct Caption: Codable {
    let plainText, typename: String?

    enum CodingKeys: String, CodingKey {
        case plainText
        case typename = "__typename"
    }
}

// MARK: - ReleaseDate
struct ReleaseDate: Codable {
    let day, month, year: Int?
    let typename: ReleaseDateTypename?

    enum CodingKeys: String, CodingKey {
        case day, month, year
        case typename = "__typename"
    }
}

enum ReleaseDateTypename: String, Codable {
    case releaseDate = "ReleaseDate"
}

// MARK: - ReleaseYear
struct ReleaseYear: Codable {
    let year: Int?
    let endYear: Int?
    let typename: String?

    enum CodingKeys: String, CodingKey {
        case year, endYear
        case typename = "__typename"
    }
}

// MARK: - TitleText
struct TitleText: Codable {
    let text: String?
    let typename: TitleTextTypename?

    enum CodingKeys: String, CodingKey {
        case text
        case typename = "__typename"
    }
}

enum TitleTextTypename: String, Codable {
    case titleText = "TitleText"
}

// MARK: - TitleType
struct TitleType: Codable {
    let text, id: String?
    let isSeries, isEpisode: Bool?
    let typename: TitleTypeTypename?
    let categories: [Category]?
    let canHaveEpisodes: Bool?

    enum CodingKeys: String, CodingKey {
        case text, id, isSeries, isEpisode
        case typename = "__typename"
        case categories, canHaveEpisodes
    }
}

// MARK: - Category
struct Category: Codable {
    let value, typename: String?

    enum CodingKeys: String, CodingKey {
        case value
        case typename = "__typename"
    }
}

enum TitleTypeTypename: String, Codable {
    case titleType = "TitleType"
}
