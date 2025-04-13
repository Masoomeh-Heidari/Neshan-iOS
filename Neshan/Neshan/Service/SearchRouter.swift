//
//  SearchRouter.swift
//  Neshan
//
//  Created by Fariba on 1/18/1404 AP.
//

import Foundation
import FAlamofire


enum SearchRouter {
    case search(_ term: String, _ lat: Double, _ lng: Double)
}

extension SearchRouter: Router {
    var baseUrl: String? {
        return Constant.API.baseUrl.appending(Constant.API.v1)
    }
    
    var path: String {
        return "search"
    }
    
    var method: HTTPMethod? {
        return .get
    }
    
    var body: Body? {
        return nil
    }
    
    var params: Parameters? {
        switch self {
        case .search(let term, let lat, let lng):
            return ["term": term, "lat": "\(lat)", "lng": "\(lng)"]
        }
    }
    
}
