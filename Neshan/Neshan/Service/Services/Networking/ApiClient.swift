//
//  ApiClient.swift
//  CustomMaps
//
//  Created by Bahar on 9/25/1403 AP.
//

import Foundation


protocol APIClientTaskCancelable {
    func cancel()
}

extension URLSessionTask: APIClientTaskCancelable { }

protocol ApiClient: AnyObject {
    
    typealias CompletionHandler<T> = (Result<T, APIError>) -> Void
    
    @discardableResult
    func request<T: Decodable>(
        endpoint: ApiRequestable,
        completion: @escaping CompletionHandler<T>
    ) throws -> APIClientTaskCancelable?
    
    @discardableResult
    func requestData(
        endpoint: ApiRequestable,
        completion: @escaping CompletionHandler<Data>
    ) throws -> APIClientTaskCancelable?
}

