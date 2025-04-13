//
//  SearchCoordinator.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Foundation
import RxSwift
import RxCocoa
import FittedSheets

class SearchCoordinator: BaseCoordinator<DoneCoordinatorResult> {
    
    private let rootViewController: UIViewController
    private let viewModel: SearchViewModel

    init(viewModel: SearchViewModel, rootViewController: UIViewController) {
        self.viewModel = viewModel
        self.rootViewController = rootViewController
    }
    
    override func start() -> Observable<DoneCoordinatorResult> {
        let vc = SearchScreen(viewModel: self.viewModel)
        
        let sheetController = SheetViewController(controller: vc, sizes: [.fullscreen])
        sheetController.gripColor = UIColor(white: 0.868, alpha: 0.1)
        sheetController.dismissOnPull = true
        self.rootViewController.present(sheetController, animated: false)
        
        let confirm = viewModel.selectedItem.map { CoordinationResult.done($0) }
        let cancel = viewModel.cancel.map { CoordinationResult.cancel }
                
        return Observable.merge(confirm, cancel)
            .take(1)
            .do(onNext: { _ in
                sheetController.dismiss()
            })
    }
}
