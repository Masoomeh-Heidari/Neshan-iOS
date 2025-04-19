//
//  DemoCoordinator.swift
//  Neshan
//
//  Created by Fariba on 1/16/1404 AP.
//

import Foundation
import Combine

class DemoCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
        
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> AnyPublisher<Void, Never> {
        let vc = DemoViewController()
        navigationController.setViewControllers([vc], animated: false)
        
        return Empty(completeImmediately: true)
            .eraseToAnyPublisher()
    }
}
