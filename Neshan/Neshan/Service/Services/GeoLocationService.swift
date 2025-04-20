//
//  GeoLocationService.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//

import Foundation
import CoreLocation
import Combine

protocol GeoLocationService: AnyObject {
    
    func getReverseGeocoding(at coordinate: CLLocationCoordinate2D) -> AnyPublisher<ReverseGeocodeToAddressResponse, APIError>
    
    func getDirection(from origin: CLLocationCoordinate2D,
                      to destination: CLLocationCoordinate2D,
                      type: String,
                      avoidTrafficZone: Bool,
                      avoidOddEvenZone: Bool,
                      alternative: Bool,
                      bearing: String?,
                      waypoints: [CLLocationCoordinate2D]?) -> AnyPublisher<DirectionResponse, APIError>
}

final class DefaultGeoLocationService: GeoLocationService {
    
    let apiService: ApiClient
    
    init(apiService: ApiClient) {
        self.apiService = apiService
    }
    
    func getReverseGeocoding(at coordinate: CLLocationCoordinate2D) -> AnyPublisher<ReverseGeocodeToAddressResponse, APIError> {
        let endpoint = AnyRequest(path: "reverse",
                                  method: .get,
                                  queryParameters: ["lat": coordinate.latitude, "lng": coordinate.longitude])
        
        return Future { [weak self] promise in
            do {
                try self?.apiService.request(endpoint: endpoint) { (result: Result<ReverseGeocodeToAddressResponse, APIError>) in
                    switch result {
                    case .success(let response):
                        promise(.success(response))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            } catch {
                promise(.failure(APIError.unknown))
            }
        }
        .eraseToAnyPublisher()
    }
    
 
    func getDirection(from origin: CLLocationCoordinate2D,
                      to destination: CLLocationCoordinate2D,
                      type: String = "car",
                      avoidTrafficZone: Bool = false,
                      avoidOddEvenZone: Bool = false,
                      alternative: Bool = false,
                      bearing: String? = nil,
                      waypoints: [CLLocationCoordinate2D]? = nil) -> AnyPublisher<DirectionResponse, APIError> {
        
        var queryParameters: [String: Any] = [
            "type": type,
            "origin": "\(origin.latitude),\(origin.longitude)",
            "destination": "\(destination.latitude),\(destination.longitude)",
            "avoidTrafficZone": avoidTrafficZone ? "true" : "false",
            "avoidOddEvenZone": avoidOddEvenZone ? "true" : "false",
            "alternative": alternative ? "true" : "false"
        ]
        
        if let bearing = bearing {
            queryParameters["bearing"] = bearing
        }
        
        if let waypoints = waypoints {
            let waypointsString = waypoints.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
            queryParameters["waypoints"] = waypointsString
        }
        
        let endpoint = AnyRequest(path: "direction",
                                  method: .get,
                                  queryParameters: queryParameters)
        
        return Future { [weak self] promise in
            do {
                try self?.apiService.request(endpoint: endpoint) { (result: Result<DirectionResponse, APIError>) in
                    switch result {
                    case .success(let response):
                        promise(.success(response))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            } catch {
                promise(.failure(APIError.unknown))
            }
        }
        .eraseToAnyPublisher()
    }
}

