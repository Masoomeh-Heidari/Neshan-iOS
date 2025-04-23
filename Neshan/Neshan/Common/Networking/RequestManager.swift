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
    func callAPI(requestConvertible: Router, callback: @escaping ServiceCallBack)
    func uploadFile(using data: Data, to endpoint: String, progress: @escaping (Double) -> Void, completion: @escaping ServiceCallBack)
    func uploadMultipartFormData(files: [(String, URL)], parameters: [String: Any], to endpoint: String, progress: @escaping (Double) -> Void, completion: @escaping ServiceCallBack)
}

class RequestManager: RequestManagerProtocol {
    private let sessionManager: Session
    private let networkLogger: NetworkLogger
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        
        self.networkLogger = NetworkLogger()
        
        self.sessionManager = Session(configuration: configuration,
                                      eventMonitors: [networkLogger])
    }
    
    func callAPI(requestConvertible: Router, callback: @escaping ServiceCallBack) {
        do {
            let urlRequest = try requestConvertible.asURLRequest()
            
            sessionManager.request(urlRequest)
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        callback(.success(response.data))
                    case .failure(let error):
                        callback(.failure(AppError.invalidResponse))
                    }
                }
            
        } catch {
            callback(.failure(AppError.server(.genericError)))
        }
    }
    
    func uploadFile(using data: Data,
                   to endpoint: String,
                   progress: @escaping (Double) -> Void,
                   completion: @escaping (Result<Data?, AppError>) -> Void) {

        // Use HTTP since we've added an ATS exception
        let url = URL(string: "http://78.39.10.22:50040/".appending(endpoint))!

        let headers: HTTPHeaders = [
            "Content-Type" : "multipart/form-data;boundary=\(randomString(with: 32))"
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "file", fileName: "report.wav")
        },to: url, method: .post , headers: headers).uploadProgress(closure: { progress in
            print(" \(Float(progress.fractionCompleted))")
        }).response(completionHandler: {response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                print("Upload error: \(error.localizedDescription)")
                completion(.failure(AppError.generalError))
            }
        })
       
    }
    
    func uploadMultipartFormData(files: [(String, URL)], parameters: [String: Any], to endpoint: String, progress: @escaping (Double) -> Void, completion: @escaping ServiceCallBack) {
        let url = URL(string: Constant.API.baseUrl.appending(endpoint))!
        
        sessionManager.upload(multipartFormData: { multipartFormData in
            // Add files
            for (key, fileURL) in files {
                multipartFormData.append(fileURL, withName: key)
            }
            
            // Add parameters
            for (key, value) in parameters {
                if let stringValue = value as? String {
                    multipartFormData.append(Data(stringValue.utf8), withName: key)
                } else if let intValue = value as? Int {
                    multipartFormData.append(Data("\(intValue)".utf8), withName: key)
                } else if let doubleValue = value as? Double {
                    multipartFormData.append(Data("\(doubleValue)".utf8), withName: key)
                } else if let boolValue = value as? Bool {
                    multipartFormData.append(Data("\(boolValue)".utf8), withName: key)
                }
            }
        }, to: url)
        .uploadProgress { progressValue in
            progress(progressValue.fractionCompleted)
        }
        .validate()
        .response { response in
            switch response.result {
            case .success:
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(AppError.server(ServerError.genericError)))
            }
        }
    }
}
//    private func handleError(_ error: AFError) -> AppError {
//        switch error {
//        case .responseValidationFailed(let reason):
//            switch reason {
//            case .unacceptableStatusCode(let code):
//                return .httpError(code: code)
//            default:
//                return .networkError
//            }
//        case .responseSerializationFailed:
//            return .decodingError
//        case .requestAdaptationFailed:
//            return .invalidRequest
//        default:
//            return .networkError
//        }
//    }
//}

//enum AppError: LocalizedError {
//    case networkError
//    case decodingError
//    case invalidRequest
//    case httpError(code: Int)
//    case fileError
//    
//    var errorDescription: String? {
//        switch self {
//        case .networkError:
//            return "Network error occurred"
//        case .decodingError:
//            return "Failed to decode response"
//        case .invalidRequest:
//            return "Invalid request"
//        case .httpError(let code):
//            return "HTTP error with code: \(code)"
//        case .fileError:
//            return "File operation failed"
//        }
//    }
//}


func randomString(with lenght: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyz0123456789"
    
    let randomString : NSMutableString = NSMutableString(capacity: lenght)
    
    for _ in 1...lenght {
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    
    var returnString = String(randomString)
    
    returnString.insert("-", at: returnString.index(returnString.startIndex, offsetBy: +8))
    returnString.insert("-", at: returnString.index(returnString.startIndex, offsetBy: +13))
    returnString.insert("-", at: returnString.index(returnString.startIndex, offsetBy: +18))
    returnString.insert("-", at: returnString.index(returnString.startIndex, offsetBy: +23))
    
    return returnString
}
