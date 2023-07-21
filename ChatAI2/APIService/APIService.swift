//
//  APIService.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 4/4/23.
//
// swiftlint:disable line_length
import Foundation

class APIService {
    private static let session = URLSession.shared
    static func getRequest<T: Codable>(urlString: String, completion: @escaping (Result<T, NetworkingError>) -> Void) {
        print("debug: urlString ", urlString)
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // make them dynamic later
        request.setValue("6b64bef4a2msh603a4ce8b33da36p195460jsn3a0fcc339895", forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("api-baseball.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard let jsonData = data else {
                completion(.failure(.nodataAvailable))
                return}
            guard let response = response as? HTTPURLResponse else {
                print("Error: ", error as Any)
                completion(.failure(.canNotProcessData(message: error!.localizedDescription)))
                return
            }
            print(response.statusCode, url.absoluteURL, " :STATUS CODE")
            if response.statusCode == 200 {
                do {
                    let decoder = JSONDecoder()
                    let responseObject = try decoder.decode(T.self, from: jsonData)
                    completion(.success(responseObject))} catch {
                    print("Error \(error)")
                    completion(.failure(.canNotProcessData(message: error.localizedDescription)))}} else {
                print(error as Any, "ERROR")
                completion(.failure(.statusCodeIsNotOkay))
            }
        }
        dataTask.resume()
    }
    static func deleteRequest<T: Codable>(urlString: String, completion: @escaping (Result<T?, NetworkingError>) -> Void) {
        print("debug: urlString ", urlString)
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        // request.addAWSAccessToken()
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard data != nil else {
                completion(.failure(.nodataAvailable))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.canNotProcessData(message: error!.localizedDescription)))
                return
            }
            print(response.statusCode, url.absoluteURL, " :STATUS CODE")
            if response.statusCode == 204 || response.statusCode == 200 {
               completion(.success(nil))} else {
                print(error as Any, "ERROR")
                completion(.failure(.statusCodeIsNotOkay))
            }
        }
        dataTask.resume()
    }
    static func putRequest<T: Codable, U>(urlString: String, body: U, completion: @escaping (Result<T, NetworkingError>) -> Void) where U: Encodable {
        print("debug: urlString ", urlString)
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        // request.addAWSAccessToken()

        guard let jsonData = try? JSONEncoder().encode(body) else {
            completion(.failure(.encodingError))
            return
        }

        request.httpBody = jsonData

        let dataTask = session.dataTask(with: request) { data, response, error in
            guard let jsonData = data else {
                completion(.failure(.nodataAvailable))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.canNotProcessData(message: error!.localizedDescription)))
                return
            }
            print(response.statusCode, url.absoluteURL, " :STATUS CODE", response, jsonData, error?.localizedDescription ?? "NIL")
            if response.statusCode == 200 {
                do {
                    let decoder = JSONDecoder()
                    let responseObject = try decoder.decode(T.self, from: jsonData)
                    completion(.success(responseObject))
                } catch {
                    print("Error \(error)")
                    completion(.failure(.canNotProcessData(message: error.localizedDescription)))
                }
            } else {
                print(error as Any, "ERROR")
                completion(.failure(.statusCodeIsNotOkay))
            }

        }

        dataTask.resume()
    }
}

enum NetworkingError: Error, LocalizedError {
    case nodataAvailable
    case invalidURL
    case canNotProcessData(message: String)
    case decodingError(message: String)
    case statusCodeIsNotOkay
    case encodingError

    var errorDescription: String? {
        switch self {
        case .nodataAvailable:
            return NSLocalizedString("No data available", comment: "1")
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "2")
        case .canNotProcessData(let message):
            return NSLocalizedString("Can not process data / No internet Connection. \(message)", comment: "3")
        case .decodingError(let message):
            return NSLocalizedString("Decoding error. \(message)", comment: "4")
        case .statusCodeIsNotOkay:
            return NSLocalizedString("Status code is not okay", comment: "5")
        case .encodingError:
            return "Encoding Error"
        }
    }
}
// swiftlint:enable line_length
