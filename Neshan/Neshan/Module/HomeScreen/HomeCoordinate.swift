//
//  HomeCoordinate.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//
import RxSwift

class HomeCoordinator: BaseCoordinator<Void> {
    
    var childCoordinators: [BaseCoordinator<Void>] = []
    
    let factory: HomeFactory
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController, factory: HomeFactory) {
        self.factory = factory
        self.navigationController = navigationController
    }
    
    
    override func start() -> Observable<Void> {
        let homeViewController = factory.makeHomeViewController()
        homeViewController.bind(to: factory.makeHomeViewModel())
        navigationController.pushViewController(homeViewController, animated: true)
        return Observable.empty()
    }
}
