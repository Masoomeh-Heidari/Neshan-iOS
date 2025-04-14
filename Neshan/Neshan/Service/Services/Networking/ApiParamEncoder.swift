//
//  ApiParamEncoder.swift
//  CustomMaps
//
//  Created by Bahar on 9/25/1403 AP.
//

import Foundation

protocol APIParamEncoder {
    func encodeRequestParameters<T>(_ request: URLRequest, _ value: T) throws -> URLRequest where T : Encodable
    
    func encodeRequestParameters(_ request: URLRequest, _ value: [String: Any]) throws -> URLRequest
}


struct JSONAPIParamEncoder: APIParamEncoder {
    
    let encoder: JSONEncoder
    
    func encodeRequestParameters(_ request: URLRequest, _ value: [String : Any]) throws -> URLRequest {
        var returnRequest = request
        returnRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard value.isEmpty == false else {
            return request
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
            returnRequest.httpBody = data
            returnRequest.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
            return returnRequest
        } catch let error {
            throw APIError.encodingError(error)
        }
    }
    
    func encodeRequestParameters<T>(_ request: URLRequest, _ value: T) throws -> URLRequest where T : Encodable {
        
        var returnRequest = request
        returnRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let data = try encoder.encode(value)
            returnRequest.httpBody = data
            returnRequest.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
            return returnRequest
        } catch let error {
            throw APIError.encodingError(error)
        }
        
    }
}
