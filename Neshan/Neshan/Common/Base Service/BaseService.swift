//
//  BaseService.swift
//  WePod
//
//  Created by Fariba on 5/8/1401 AP.
//  Copyright © 1401 AP Dotin. All rights reserved.
//

import Foundation

class BaseService {
    let requestManager:RequestManagerProtocol
    let decoder = JSONDecoder()
    
    init(requestManager: RequestManagerProtocol = RequestManager()) {
        self.requestManager = requestManager
    }
}
