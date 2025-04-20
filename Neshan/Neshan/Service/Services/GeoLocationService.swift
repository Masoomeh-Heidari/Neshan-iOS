//
//  GeoLocationService.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//
/*import CoreLocation

protocol GeoLocationService: AnyObject {
    
    func getReverseGeocoding(at: CLLocationCoordinate2D, completion: @escaping (Result<ReverseGeocodeToAddressResponse, APIError>) -> Void) throws
    func getDirection(from origin: CLLocationCoordinate2D,
                      to destination: CLLocationCoordinate2D,
                      type: String,
                      avoidTrafficZone: Bool,
                      avoidOddEvenZone: Bool,
                      alternative: Bool,
                      bearing: String?,
                      waypoints: [CLLocationCoordinate2D]?,
                      completion: @escaping (Result<DirectionResponse, APIError>) -> Void) throws

}


final class DefaultGeoLocationService: GeoLocationService {
    
    let apiService: ApiClient
    
    init(apiService: ApiClient) {
        self.apiService = apiService
    }
    
    func getReverseGeocoding(at coordinate: CLLocationCoordinate2D,
                             completion: @escaping (Result<ReverseGeocodeToAddressResponse, APIError>) -> Void) throws {
        
        let endpoint = AnyRequest(path: "reverse",
                                  method: .get,
                                  queryParameters: ["lat": coordinate.latitude, "lng": coordinate.longitude])
        try apiService.request(endpoint: endpoint) { (result: Result<ReverseGeocodeToAddressResponse, APIError>) in
            switch result {
            case .success(let response):
                print("success: \(response)")
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func getDirection(from origin: CLLocationCoordinate2D,
                      to destination: CLLocationCoordinate2D,
                      type: String = "car",
                      avoidTrafficZone: Bool = false,
                      avoidOddEvenZone: Bool = false,
                      alternative: Bool = false,
                      bearing: String? = nil,
                      waypoints: [CLLocationCoordinate2D]? = nil,
                      completion: @escaping (Result<DirectionResponse, APIError>) -> Void) throws {
        
        // Initialize query parameters
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
                                    
          
          try apiService.request(endpoint: endpoint) { (result: Result<DirectionResponse, APIError>) in
              switch result {
              case .success(let response):
                  print("Direction API success: \(response)")
                  completion(.success(response))
              case .failure(let error):
                  print("Direction API failed: \(error)")
                  completion(.failure(error))
              }
          }
      }
}*/


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
    
    // Refactored to use Combine's Future
    func getReverseGeocoding(at coordinate: CLLocationCoordinate2D) -> AnyPublisher<ReverseGeocodeToAddressResponse, APIError> {
        let endpoint = AnyRequest(path: "reverse",
                                  method: .get,
                                  queryParameters: ["lat": coordinate.latitude, "lng": coordinate.longitude])
        
//        return Future { [weak self] promise in
//            do {
//                try self?.apiService.request(endpoint: endpoint) { (result: Result<ReverseGeocodeToAddressResponse, APIError>) in
//                    switch result {
//                    case .success(let response):
//                        promise(.success(response))
//                    case .failure(let error):
//                        promise(.failure(error))
//                    }
//                }
//            } catch {
//                promise(.failure(APIError.unknown))
//            }
//        }.eraseToAnyPublisher()
        
           return Future<ReverseGeocodeToAddressResponse, APIError> { [weak self] promise in
                guard let self else { return }
                Task {
                    do {
                        let data = try await self.apiService.requestData(endpoint: endpoint)
                        let decoded = try JSONDecoder().decode(ReverseGeocodeToAddressResponse.self, from: data)
                        promise(.success(decoded))
                    } catch let error as APIError {
                        promise(.failure(error))
                    } catch {
                        promise(.failure(APIError.decodingError(error)))
                    }
                }
            }
            .eraseToAnyPublisher()

    }
    
    // Refactored to use Combine's Future
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
        
            return Future<DirectionResponse, APIError> { [weak self] promise in
                Task {
                    do {
                        guard let self else {
                            promise(.failure(.unknown))
                            return
                        }
                        
                        let response: DirectionResponse = try await self.apiService.request(endpoint: endpoint)
                        promise(.success(response))
                        
                    } catch let error as APIError {
                        promise(.failure(error))
                    } catch {
                        promise(.failure(.unknown))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
}

