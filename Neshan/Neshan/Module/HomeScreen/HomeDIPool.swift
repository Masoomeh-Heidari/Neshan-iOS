//
//  HomeDIPool.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//

class HomeDIPool: HomeFactory {
    
    let apiClient: ApiClient
    
    lazy var tripStorage: LocalStorageBaseService<TripModel> = {
        TripLocalStorageService()
    }()
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func makeHomeViewController() -> HomeScreenViewController {
        HomeScreenViewController()
    }
    
    func makeHomeViewModel() -> HomeScreenViewModel {
        HomeScreenViewModel(locationService: DefaultLocationService(),
                            geoService: DefaultGeoLocationService(apiService: apiClient),
                            tripStorageService: tripStorage)
    }
     
    func makeHomeCoordinator(with root: UINavigationController) -> HomeCoordinator {
        HomeCoordinator(navigationController: root, factory: self)
    }
}

