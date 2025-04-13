//
//  AppCoordinator.swift
//  WePod
//
//  Created by Amin Jalalian on 3/28/1402 AP.
//

import Foundation
import UIKit
import RxSwift

class AppCoordinator: BaseCoordinator<Void> {
    
    override func start() -> Observable<Void> {
        self.coordinate(to: SplashCoordinator()).subscribe().disposed(by: self.disposeBag)
        return Observable.empty()
    }
}
