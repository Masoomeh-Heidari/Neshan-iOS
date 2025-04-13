//
//  SignupBaseViewModel.swift
//  WePod
//
//  Created by Fariba on 5/8/1401 AP.
//  Copyright © 1401 AP Dotin. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

typealias SimpleCallBack = () -> Void

enum ViewState {
  case loading
  case ready(String? = nil)
  case error(AppError)
  case warning(String? = nil)
}

extension ViewState: Equatable {
    public static func ==(lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case let (.ready(left), .ready(right)):
                return left == right
            case let (.error(left), .error(right)):
                return left.status == right.status
            case let (.warning(left), .warning(right)):
                return left == right
            default: return false
        }
    }
}

enum DropDownToastMode: Int {
    case success = 1
    case error = 2
    case info = 3
    case notification = 4
}

class BaseViewModel {
    
    let disposeBag = DisposeBag()
    
    // MARK: - View State Handler
    public var state: ViewState = .loading {
        didSet {
            switch state {
                case .ready(let message):
                    self.showToast(with: message, and: .success)
                case .error(let error):
                    self.handleError(error: error)
                case .warning(let message):
                    self.showToast(with: message, and: .info)
                case .loading:
                    self.showLoading()
            }
        }
    }
    
    fileprivate func showLoading() {
       //show loading
    }
    
    fileprivate func showToast(with message: String?, and mode: DropDownToastMode) {
        self.hideLoading()
        if let message = message {
            //show toast
        }
    }
    
    fileprivate func handleError(error: AppError) {
        self.state = .ready()
        switch error {
            case .server(let model):
                //handle server error
            break
            default:
                self.showToast(with: error.errorDescription, and: .error)
        }
    }
    
    fileprivate func hideLoading() {
        //stop loading
    }
}
