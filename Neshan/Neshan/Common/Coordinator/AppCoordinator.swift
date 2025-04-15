//
//  AppCoordinator.swift
//  WePod
//
//  Created by Amin Jalalian on 3/28/1402 AP.
//

import Combine

class AppCoordinator: BaseCoordinator<Void> {
        
    override func start() -> AnyPublisher<Void, Never> {
        coordinate(to: SplashCoordinator())
            .sink { _ in }
            .store(in: &cancellables)
        
        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }
}
