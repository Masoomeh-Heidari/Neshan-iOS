//
//  SearchCoordinator.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Foundation
import Combine
import FittedSheets

class SearchCoordinator: BaseCoordinator<DoneCoordinatorResult> {
    
    private let rootViewController: UIViewController
    private let viewModel: SearchViewModel

    init(viewModel: SearchViewModel, rootViewController: UIViewController) {
        self.viewModel = viewModel
        self.rootViewController = rootViewController
    }
    
    override func start() -> AnyPublisher<DoneCoordinatorResult, Never> {
        let vc = SearchScreen(viewModel: self.viewModel)
        
        let sheetController = SheetViewController(controller: vc, sizes: [.marginFromTop(24.0)])
        sheetController.gripColor = UIColor(white: 0.868, alpha: 0.1)
        sheetController.dismissOnPull = true
        sheetController.dismissOnOverlayTap = true
        self.rootViewController.present(sheetController, animated: false)
        
        let confirm = viewModel.selectedItem.map { CoordinationResult.done($0) }
        let cancel = viewModel.cancel.map { CoordinationResult.cancel }
        
        return Publishers.Merge(confirm, cancel).dropFirst(1)
            .handleEvents(receiveOutput: { _ in
                sheetController.dismiss()
            })
            .eraseToAnyPublisher()
    }
}

