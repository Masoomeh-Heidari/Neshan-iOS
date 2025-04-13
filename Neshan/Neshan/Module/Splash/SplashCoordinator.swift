//
//  File.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Foundation
import RxSwift


class SplashCoordinator: BaseCoordinator<Void> {
    
    override func start() -> Observable<Void> {
        let vm = SplashViewModel()
        let vc = SplashScreen(viewModel: vm)
                
        vm.goToTabbar.subscribe(onNext: {
            self.coordinate(to: TabbarCoordinator()).subscribe().disposed(by: self.disposeBag)
        }).disposed(by: self.disposeBag)
        
        vc.setRootViewController()
        return Observable.empty()
    }
}
