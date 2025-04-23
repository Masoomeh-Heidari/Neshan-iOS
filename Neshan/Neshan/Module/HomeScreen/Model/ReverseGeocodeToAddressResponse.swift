//
//  ReverseGeocodeToAddressResponse.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//
import UIKit

struct ReverseGeocodeToAddressResponse: Codable {
    let status: String
    let formattedAddress: String
    let routeName: String
    let routeType: String
    let neighbourhood: String
    let city: String
    let state: String
    let place: String?
    let municipalityZone: String
    let inTrafficZone: Bool
    let inOddEvenZone: Bool
    let village: String?
    let county: String
    let district: String

    enum CodingKeys: String, CodingKey {
        case status
        case formattedAddress = "formatted_address"
        case routeName = "route_name"
        case routeType = "route_type"
        case neighbourhood
        case city
        case state
        case place
        case municipalityZone = "municipality_zone"
        case inTrafficZone = "in_traffic_zone"
        case inOddEvenZone = "in_odd_even_zone"
        case village
        case county
        case district
    }
}

