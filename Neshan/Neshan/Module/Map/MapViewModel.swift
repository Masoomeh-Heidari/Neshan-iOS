//
//  MapViewModel.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Foundation
import RxSwift

class MapViewModel: BaseViewModel {
    
    let userLocation = PublishSubject<(x: Double,y: Double)>()
//    let showExplore = PublishSubject<(x: Double,y: Double)>()
    let hideExplore = PublishSubject<Void>()
    let showSearch = PublishSubject<(x: Double,y: Double)>()
    let showSearchResult = PublishSubject<Bool>()
    let showSearchBox = PublishSubject<(term: String, selectedItem: SearchItemDto, result: [SearchItemDto])>()
    
}
