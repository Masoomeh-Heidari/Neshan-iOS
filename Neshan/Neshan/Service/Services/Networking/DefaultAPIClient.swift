//
//  DefaultAPIClient.swift
//  CustomMap
//
//  Created by Bahar on 9/29/1403 AP.
//

import Foundation

class DefaultAPIClient: ApiClient {
    
    let apiKey: String
    let baseURL: URL
    let configuration: URLSessionConfiguration
    let session: URLSession
    
    init(baseURL: URL, configuration: URLSessionConfiguration, apiKey: String) {
        self.baseURL = baseURL
        self.configuration = configuration
        self.apiKey = apiKey
        self.session = URLSession(configuration: configuration)
    }
    
    
    func request<T: Decodable>(endpoint: ApiRequestable) async throws -> T {
        let request = try buildURLRequest(endpoint: endpoint)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.validationResponse(statusCode: 0, message: "No Response")
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.validationResponse(statusCode: httpResponse.statusCode,
                                              message: httpResponse.statusCode.description)
        }
        
        print("data is \(String(data: data, encoding: .utf8) ?? "Invalid Data")")
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    
    func requestData(endpoint: ApiRequestable) async throws -> Data {
        let request = try buildURLRequest(endpoint: endpoint)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.validationResponse(statusCode: 0, message: "No Response")
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.validationResponse(statusCode: httpResponse.statusCode,
                                              message: httpResponse.statusCode.description)
        }
        
        return data
    }

    
    func buildURLRequest(endpoint: ApiRequestable) throws -> URLRequest {
        try endpoint.urlRequest(baseURL: baseURL,
                                apiKey: apiKey)
    }
}
