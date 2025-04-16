//
//  SearchViewModel.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Foundation
import RxSwift


class SearchViewModel: BaseViewModel {
    let service = SearchService()
    
    let searchTerm = PublishSubject<String>()
    let searchResult = PublishSubject<[SearchItemDto]?>()
    let selectedItem = PublishSubject<(term: String, selectedItem: SearchItemDto, result: [SearchItemDto])>()
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
        searchTerm.subscribe(onNext: { [weak self] term in
            guard let self = self else { return }
            guard !(term.isEmpty) else {
                self.searchResult.onNext(nil)
                return
            }
            self.service.search(by: term, lat: self.lng, lng: self.lat) {[weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let list):
                    self.searchResult.onNext(list)
                case .failure(let error):
                    self.state = .error(error)
                }
            }
        }).disposed(by: self.disposeBag)
    }
}
