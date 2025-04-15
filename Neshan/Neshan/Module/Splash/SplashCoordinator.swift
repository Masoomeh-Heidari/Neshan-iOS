//
//  File.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Foundation
import Combine

class SplashCoordinator: BaseCoordinator<Void> {
    
    override func start() -> AnyPublisher<Void, Never> {
        let vm = SplashViewModel()
        let vc = SplashScreen(viewModel: vm)
        
        vm.goToTabbar
            .sink(receiveCompletion: { result in
                self.coordinate(to: TabbarCoordinator()).sink { _ in }.store(in: &self.cancellables)
            }, receiveValue: { result in
                self.coordinate(to: TabbarCoordinator()).sink { _ in }.store(in: &self.cancellables)
            })
            .store(in: &cancellables)

        
        vc.setRootViewController()
        return Empty(completeImmediately: true)
            .eraseToAnyPublisher() // Return a publisher that completes immediately
    }
}
