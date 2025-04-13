//
//  SearchResponseDto.swift
//  Neshan
//
//  Created by Fariba on 1/18/1404 AP.
//

import Foundation

struct SearchResponseDto: Decodable {
    let count: Int
    let items: [SearchItemDto]
}

struct SearchItemDto: Decodable {
    let title: String
    let address: String
    let neighbourhood: String?
    let region: String
    let type: String
    let category: String
    let location: LocationDto
   
}

struct LocationDto: Decodable {
    let x: Double
    let y: Double
}

extension SearchItemDto: Equatable {
    static func == (lhs: SearchItemDto, rhs: SearchItemDto) -> Bool {
        return lhs.title == rhs.title && (lhs.location.x == rhs.location.x && lhs.location.y == rhs.location.y)
    }
}
