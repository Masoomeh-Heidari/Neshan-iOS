//
//  DoneCoordinatorResult.swift
//  WePod
//
//  Created by Rojin on 10/11/22.
//

import Combine

enum DoneCoordinatorResult {
    case done(Any)
    case cancel
    case error(Any)
}

typealias DoneCoordinatorResultPublisher = AnyPublisher<DoneCoordinatorResult, Never>
