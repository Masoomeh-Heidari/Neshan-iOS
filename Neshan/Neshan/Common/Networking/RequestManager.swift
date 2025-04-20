//
//  RequestManager.swift
//  WePod
//
//  Created by Fariba on 5/8/1401 AP.
//  Copyright © 1401 AP Dotin. All rights reserved.
//


import Foundation
import FAlamofire

// TODO: Decide where to use Alamofire or URLSession based on complexity
typealias ServiceCallBack = (Result<Data?, AppError>) -> Void

protocol RequestManagerProtocol {
    func callAPI(requestConvertible: URLRequestConvertible, callback: @escaping ServiceCallBack)
}

class RequestManager: SessionDelegate {
    private var sessionManager: Session!
    private let networkLogger = NetworkLogger()
    private let networkReachability: NetworkReachabilityManager? = NetworkReachabilityManager()
    
    init() {
        super.init()
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.waitsForConnectivity = true
        sessionManager = Session(configuration: configuration, eventMonitors: [networkLogger])
    }
}

extension RequestManager: RequestManagerProtocol {
    func callAPI(requestConvertible: URLRequestConvertible, callback: @escaping ServiceCallBack) {
        if networkReachability?.isReachable ?? false {
            sessionManager.request(requestConvertible).validate(statusCode: 200..<300).response { response in
                let statusCode = response.response?.statusCode

                switch response.result {
                case .success:
                    callback(.success(response.data))
                case .failure(let error):
                    if let statusCode = response.response?.statusCode, let serverError = ServerError(rawValue: statusCode) {
                        callback(.failure(AppError.server(serverError)))
                    }else {
                        callback(.failure(AppError.statusCode(statusCode ?? 0, response.request?.url?.pathComponents.last ?? ""))) //handle generic errors
                    }
                }
            }
        } else {
            callback(.failure(AppError.isOffline))
        }
    }
}
