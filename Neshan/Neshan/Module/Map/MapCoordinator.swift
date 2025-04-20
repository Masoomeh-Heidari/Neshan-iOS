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
    let apiClient: ApiClient

    init(navigationController: UINavigationController, apiClient: ApiClient) {
        self.navigationController = navigationController
        self.apiClient = apiClient
    }
    
    override func start() -> AnyPublisher<Void, Never> {
        //TODO: Consider using dependency injection or a service locator to manage ViewModel instances, rather than directly creating them, to promote testability and flexibility.
        let vm = MapViewModel(geoService: DefaultGeoLocationService(apiService: apiClient))
    
        let vc = MapScreen(viewModel: vm)
        
        vm.showSearch.receive(on: RunLoop.main)
            .flatMap { [weak self] location -> AnyPublisher<(term: String, selectedItem: SearchItemDto, result: [SearchItemDto])?, Never> in
                guard let self = self else {
                    return Just(nil).eraseToAnyPublisher()
                }
                return self.goToSearchScreen(using: location, rootViewController: vc).eraseToAnyPublisher()
            }
            .compactMap { $0 }
            .sink { result in
                vm.showSearchBox.send(result)
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

