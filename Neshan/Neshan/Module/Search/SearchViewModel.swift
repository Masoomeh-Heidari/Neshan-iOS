//
//  SearchViewModel.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Foundation
import Combine

class SearchViewModel: BaseViewModel {
    let service = SearchService()

    // Replaced PublishSubject with PassthroughSubject for Combine
    let searchTerm = PassthroughSubject<String, Never>()
    let searchResult = PassthroughSubject<[SearchItemDto]?, Never>()
    let selectedItem = PassthroughSubject<(term: String, selectedItem: SearchItemDto, result: [SearchItemDto]), Never>()
    let cancel = PassthroughSubject<Void, Never>()
    let isLoading = PassthroughSubject<Bool, Never>()

    // Properties for location
    let lat: Double
    let lng: Double
    
    // Use Set<AnyCancellable> instead of DisposeBag to manage subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init(using x: Double, y: Double) {
        self.lat = x
        self.lng = y
        super.init()
        self.binding()
    }
    
    fileprivate func binding() {
        // Replacing subscribe(onNext:) with sink in Combine
        searchTerm
            .sink { [weak self] term in
                guard !(term.isEmpty) else {
                    self?.searchResult.send(nil)
                    self?.isLoading.send(false)
                    return
                }
                self?.isLoading.send(true)
                
                // Performing search operation
                self?.service.search(by: term, lat: self?.lng ?? 0, lng: self?.lat ?? 0) { result in
                    self?.isLoading.send(false)
                    switch result {
                    case .success(let list):
                        self?.searchResult.send(list)
                    case .failure(let error):
                        self?.state = .error(error)
                    }
                }
            }
            .store(in: &cancellables) // Store the cancellable in the cancellables set
    }
}
