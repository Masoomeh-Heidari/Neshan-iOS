//
//  NetworkLogger.swift
//  WePod
//
//  Created by Fariba on 5/8/1401 AP.
//  Copyright © 1401 AP Dotin. All rights reserved.
//

import Foundation
import FAlamofire

class NetworkLogger: EventMonitor, @unchecked Sendable {
    func requestDidFinish(_ request: Request) {
      print("AF: 😻 Request URL: \n \(String(describing: request.request?.url?.absoluteString ?? ""))\n")
      print("AF: 🐷 Status Code: \n \(String(describing: request.response?.statusCode ?? 0)) \n")
        
      if let body = request.request?.httpBody {
        print("AF: 🤡 Request Body: \n \(String(describing: NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? ""))\n")
      }
    }
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        NSLog("⚡️⚡️⚡️⚡️⚡️ Response Received: \(response.debugDescription)")
    }
    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        print("⚡️⚡️⚡️⚡️⚡️ Response Received: \(response.debugDescription)")
    }
}

