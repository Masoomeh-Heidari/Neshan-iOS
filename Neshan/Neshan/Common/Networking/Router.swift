//
//  Router.swift
//  WePod
//
//  Created by Fariba on 5/8/1401 AP.
//  Copyright © 1401 AP Dotin. All rights reserved.
//


import Foundation
import FAlamofire

public typealias Body = [String: Any]

protocol Router: URLRequestConvertible {
  var baseUrl :String? { get }
  var method: HTTPMethod? { get }
  var path: String {get }
  var headers: HTTPHeaders? { get }
  var encoding: ParameterEncoding? { get }
  var params: Parameters? { get }
  var body: Body? { get }
  func asURLRequest() throws -> URLRequest
}

extension Router {
  var baseUrl: String? {
        Constant.API.baseUrl
  }
  
  var headers: HTTPHeaders? {
      return [ "Api-Key": Constant.API.api_key]
  }
  
  var body: Body? {
    return nil
  }
  
  var params: Parameters? {
    return nil
  }
  
  var encoding: ParameterEncoding? {
    return URLEncoding.queryString
  }
  
  // MARK: URLRequestConvertible
  func asURLRequest() throws -> URLRequest {
    let url = URL(string: self.baseUrl!.appending(path))
    
    let urlRequest = URLRequest(url: url!)
    var encodedURLRequest = try URLEncodedFormParameterEncoder.default.encode((params as? [String:String]) ,into: urlRequest)
    
    if self.method == .post || self.method == .put , let data = self.body {
      encodedURLRequest.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
    }
    
    encodedURLRequest.httpMethod = method?.rawValue
    encodedURLRequest.allHTTPHeaderFields = headers?.dictionary
    
    return encodedURLRequest
  }
}
