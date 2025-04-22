//
//  MapCoordinator.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Combine
import UIKit

class MapCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    let vm = MapViewModel()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> AnyPublisher<Void, Never> {
        let vc = MapScreen(viewModel: vm)
        
        vm.showSearch
            .flatMap { [weak self] location -> AnyPublisher<(term: String, selectedItem: SearchItemDto, result: [SearchItemDto])?, Never> in
                guard let self = self else {
                    return Just(nil).eraseToAnyPublisher()
                }
                return self.goToSearchScreen(using: location, rootViewController: vc).eraseToAnyPublisher()
            }
            .compactMap { $0 }
            .sink {[weak self] result in
                guard let self = self else { return }
                self.vm.showSearchBox.send(result)
            }
            .store(in: &cancellables)
        
        navigationController.setViewControllers([vc], animated: false)
        
        return Empty().eraseToAnyPublisher()
    }
}

extension MapCoordinator {
    
    fileprivate func goToSearchScreen(
        using location: (x: Double, y: Double),
        rootViewController: UIViewController
    ) -> AnyPublisher<(term: String, selectedItem: SearchItemDto, result: [SearchItemDto])?, Never> {
        
        let viewModel = SearchViewModel(using: location.x, y: location.y)
        let searchCoordinator = SearchCoordinator(viewModel: viewModel, rootViewController: rootViewController)
        
        return coordinate(to: searchCoordinator)
            .map { result in
                switch result {
                case .done(let item):
                    return item as? (term: String, selectedItem: SearchItemDto, result: [SearchItemDto])
                case .cancel, .error:
                    //TODO: Handle errors 
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
}

