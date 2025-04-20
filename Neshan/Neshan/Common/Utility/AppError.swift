//
//  AppError.swift
//  WePod
//
//  Created by Fariba on 5/8/1401 AP.
//  Copyright © 1401 AP Dotin. All rights reserved.
//

import Foundation

enum AppError: Error {
    case server(ServerError)
    case statusCode(Int, String)
    case isOffline
    case custom
    case invalidResponse
    case generalError
}

extension AppError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .invalidResponse:
        return "دریافت پاسخ نامعتبر از سرور"
    case .server(let error):
        return error.description
    default:
      return "خطایی رخ داده چند لحظه دیگر مجدد تلاش کنید"
    }
  }
    
    var status: Int? {
      switch self {
      case .statusCode(let code,_):
        return code
      case .server(let error):
        return error.statusCode
      default:
        return nil
      }
    }
}

extension AppError: Equatable {
  public static func ==(lhs: AppError, rhs: AppError) -> Bool {
      switch (lhs, rhs) {
      case let (.server(left), .server(right)):
          return left.statusCode == right.statusCode
      case let (.statusCode(leftstatus, leftService), .statusCode(rightstatus, rightService)):
          return (leftstatus == rightstatus && leftService == rightService)
      default:
          return true
      }
  }
}

enum ServerError {
    case coordinateParseError
    case keyNotFound
    case limitExceeded
    case rateExceeded
    case apiKeyTypeError
    case apiWhiteListError
    case apiServiceListError
    case genericError
    
    init?(rawValue: Int) {
        switch rawValue {
        case 470:
            self = .coordinateParseError
        case 480:
            self = .keyNotFound
        case 481:
            self = .limitExceeded
        case 482:
            self = .rateExceeded
        case 483:
            self = .apiKeyTypeError
        case 484:
            self = .apiWhiteListError
        case 485:
            self = .apiServiceListError
        case 500:
            self = .genericError
        default:
            self = .genericError
        }
    }
    
    var description: String? {
        switch self {
        case .coordinateParseError:
            return "مختصات نامعتبر"
        case .keyNotFound:
            return "کلید نامعتبر"
        case .limitExceeded:
            return "سقف درخواست مجاز"
        case .rateExceeded:
            return "سقف درخواست مجاز"
        case .apiKeyTypeError:
            return "کلید نامعتبر"
        case .apiWhiteListError:
            return "درخواست غیرمجاز"
        case .apiServiceListError:
            return "درخواست غیرمجاز"
        case .genericError:
            return "خطای نامشخص"
        }
    }
    
    var statusCode: Int? {
        switch self {
        case .coordinateParseError:
            return 470
        case .keyNotFound:
            return 480
        case .limitExceeded:
            return 481
        case .rateExceeded:
            return 482
        case .apiKeyTypeError:
            return 483
        case .apiWhiteListError:
            return 484
        case .apiServiceListError:
            return 485
        case .genericError:
            return 500
        }
    }
}
