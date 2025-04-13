//
//  DemoCoordinator.swift
//  Neshan
//
//  Created by Fariba on 1/16/1404 AP.
//

import Foundation
import RxSwift

class DemoCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
        
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let vc = DemoViewController()
        navigationController.setViewControllers([vc], animated: false)
        
        return Observable.empty()
    }
}
