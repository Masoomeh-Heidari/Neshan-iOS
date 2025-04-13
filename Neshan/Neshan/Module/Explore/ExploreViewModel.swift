//
//  ExploreViewModel.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Foundation
import RxSwift

class ExploreViewModel: BaseViewModel {
    
    let goToSearch = PublishSubject<(x: Double,y: Double)>()
    let cancel = PublishSubject<Void>()
    
    let lat: Double
    let lng: Double
    
    init(using x: Double, y: Double) {
        self.lat = x
        self.lng = y
        super.init()
        self.binding()
    }
    
    fileprivate func binding() {
        
    }
}
