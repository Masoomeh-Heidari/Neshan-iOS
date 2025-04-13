//
//  ExploreCoordinator.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Foundation
import RxSwift
import FittedSheets

class ExploreCoordinator: BaseCoordinator<DoneCoordinatorResult> {
    private let rootViewController: UIViewController
    private let viewModel: ExploreViewModel

    init(viewModel: ExploreViewModel, rootViewController: UIViewController) {
        self.viewModel = viewModel
        self.rootViewController = rootViewController
    }
    
    override func start() -> Observable<DoneCoordinatorResult> {
        let vc = ExploreScreen(viewModel: self.viewModel)
        
        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(150), .marginFromTop(50)])
        sheetController.gripColor = UIColor(white: 0.868, alpha: 0.1)
        sheetController.overlayColor = .clear
        sheetController.dismissOnPull = false
        sheetController.dismissOnOverlayTap = false
        sheetController.allowGestureThroughOverlay = true
        sheetController.modalPresentationStyle = .overCurrentContext
        self.rootViewController.present(sheetController, animated: false)
        
        let confirm = self.viewModel.goToSearch.map { CoordinationResult.done($0) }
        let cancel = self.viewModel.cancel.map { CoordinationResult.cancel }
                
        return Observable.merge(confirm, cancel)
            .take(1)
            .do(onNext: { _ in
                sheetController.dismiss()
            })
    }
}
