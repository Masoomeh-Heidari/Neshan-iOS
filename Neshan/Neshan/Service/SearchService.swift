//
//  SearchService.swift
//  Neshan
//
//  Created by Fariba on 1/18/1404 AP.
//

import Foundation

protocol SearchServiceProtocol {
    typealias SearchCallBack = (Result<[SearchItemDto], AppError>) -> Void
    typealias SendVoiceCallBack = (Result<String, AppError>) -> Void
    
    func search(by term: String, lat: Double, lng: Double, callback: @escaping SearchCallBack)
    func sendVoice(by data: Data, callback: @escaping SendVoiceCallBack)
}

class SearchService: BaseService { }

extension SearchService: SearchServiceProtocol {
    func search(by term: String, lat: Double, lng: Double, callback: @escaping SearchCallBack) {
        self.requestManager.callAPI(requestConvertible: SearchRouter.search(term, lat, lng)) { result in
            switch result {
                case .success(let data):
                    if let data = data {
                        do {
                            let item = try self.decoder.decode(SearchResponseDto.self, from: data)
                            callback(.success(item.items))
                        } catch {
                            callback(.failure(AppError.invalidResponse))
                        }
                    }else {
                        callback(.failure(AppError.invalidResponse))
                    }
                case .failure(let error):
                    callback(.failure(error))
            }
        }
    }
    
    func sendVoice(by data: Data, callback: @escaping SendVoiceCallBack) {
        
    }
}
