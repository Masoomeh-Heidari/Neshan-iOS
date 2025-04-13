//
//  MapCoordinator.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Foundation
import RxSwift
import RxCocoa

class MapCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
        
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let vm = MapViewModel()
        let vc = MapScreen(viewModel: vm)
        
//        vm.hideExplore.subscribe(onNext: {[weak self] _ in
//            guard let self else { return }
//            vc.navigationController?.viewControllers.first?.dismiss()
//        }).disposed(by: disposeBag)
//        
//        vm.showExplore.flatMap { [weak self] loc -> Observable<(x: Double,y: Double)?> in
//            guard let self else { return .empty() }
//            return self.showExploreBottomSheet(using: loc, rootViewController: vc)
//        }.filter { $0 != nil }
//         .map { $0! }
//         .flatMap { item -> Observable<(term: String, selectedItem: SearchItemDto, result: [SearchItemDto])?> in
//             return self.goToSearchScreen(using: item, rootViewController: vc)
//         }.filter { $0 != nil }
//            .map { $0! }
//        .bind(to: vm.showSearchBox)
//        .disposed(by: disposeBag)
        
        navigationController.setViewControllers([vc], animated: false)
        
        return Observable.empty()
    }
}

extension MapCoordinator {
    fileprivate func showExploreBottomSheet(using location: (x: Double,y: Double), rootViewController: UIViewController) -> Observable<(x: Double,y: Double)?> {
        let viewModel = ExploreViewModel(using: location.x, y: location.y)
        let exploreCoordinator = ExploreCoordinator(viewModel: viewModel, rootViewController: rootViewController)
        return coordinate(to: exploreCoordinator).map { result in
            switch result {
            case .done(let item): return item as? (x: Double, y: Double)
            case .cancel, .error:
                return nil
            }
        }
    }
    
    fileprivate func goToSearchScreen(using location: (x: Double, y: Double), rootViewController: UIViewController) -> Observable<(term: String, selectedItem: SearchItemDto, result: [SearchItemDto])?> {
        let viewModel = SearchViewModel(using: location.x, y: location.y)
        let searchCoordinator = SearchCoordinator(viewModel: viewModel, rootViewController: rootViewController)
        return coordinate(to: searchCoordinator).map { result in
            switch result {
            case .done(let item): return item as? (term: String, selectedItem: SearchItemDto, result: [SearchItemDto])
            case .cancel, .error:
                return nil
            }
        }
    }
    
}
