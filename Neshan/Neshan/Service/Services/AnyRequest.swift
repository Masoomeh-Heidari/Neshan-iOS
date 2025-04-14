//
//  AnyRequest.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//

import Foundation

struct AnyRequest: ApiRequestable {
    
    let path: String
    let isFullPath: Bool
    let method: HTTPMethod
    let headerParameters: [String: String]
    let queryParametersEncodable: Encodable?
    let queryParameters: [String: Any]
    let bodyParametersEncodable: Encodable?
    let bodyParameters: [String: Any]?
    let paramsEncoder: APIParamEncoder?
    let requiresAuthentication: Bool
    
    init(path: String, isFullPath: Bool = false,
         method: HTTPMethod = .get,
         headerParameters: [String : String] = [:],
         queryParametersEncodable: Encodable? = nil,
         queryParameters: [String : Any] =  [:],
         bodyParametersEncodable: (any Encodable)? = nil,
         bodyParameters: [String : Any]? = nil,
         paramsEncoder: APIParamEncoder? = JSONAPIParamEncoder(encoder: JSONEncoder()),
         requiresAuthentication: Bool = true) {
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
        self.paramsEncoder = paramsEncoder
        self.requiresAuthentication = requiresAuthentication
    }
}
