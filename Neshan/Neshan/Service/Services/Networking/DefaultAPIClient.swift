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
    
    
    func request<T: Decodable>(endpoint: ApiRequestable,
                               completion: @escaping CompletionHandler<T>) throws -> APIClientTaskCancelable? {
        let request = try buildURLRequest(endpoint: endpoint)
        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error as? URLError {
                guard error.code != .notConnectedToInternet else {
                    completion(.failure(APIError.notConnectedToInternet))
                    return
                }
                completion(.failure(APIError.requestFailed(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(APIError.validationResponse(statusCode: 0, message: "No Response")))
                return
            }
            
            guard 200..<300 ~= response.statusCode else {
                completion(.failure(APIError.validationResponse(statusCode: response.statusCode,
                                                                message: response.statusCode.description)))
                return
            }
            
            guard let data else {
                completion(.failure(APIError.validationResponse(statusCode: response.statusCode, message: "NO data")))
                    return
            }
            
            do  {
                print("data is \(String(data: data, encoding: .utf8) ?? "Invalid Data")")
                
                let object = try JSONDecoder().decode(T.self, from: data)
                completion(.success(object))
            } catch let error {
                completion(.failure(APIError.decodingError(error)))
            }
        }
        task.resume()
        return task
    }
    
    func requestData(endpoint: ApiRequestable,
                     completion: @escaping CompletionHandler<Data>) throws ->  APIClientTaskCancelable? {
        let request = try buildURLRequest(endpoint: endpoint)
        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error as? URLError {
                guard error.code != .notConnectedToInternet else {
                    completion(.failure(APIError.notConnectedToInternet))
                    return
                }
                completion(.failure(APIError.requestFailed(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(APIError.validationResponse(statusCode: 0, message: "No Response")))
                return
            }
            
            guard 200..<300 ~= response.statusCode else {
                completion(.failure(APIError.validationResponse(statusCode: response.statusCode,
                                                                message: response.statusCode.description)))
                return
            }
            
            guard let data else {
                completion(.failure(APIError.validationResponse(statusCode: response.statusCode, message: "NO data")))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
        return task
    }
    
    func buildURLRequest(endpoint: ApiRequestable) throws -> URLRequest {
        try endpoint.urlRequest(baseURL: baseURL,
                                apiKey: apiKey)
    }
}
