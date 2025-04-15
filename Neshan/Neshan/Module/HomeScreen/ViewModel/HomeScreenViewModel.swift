//
//  HomeScreenViewModel.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//
import UIKit
import CoreLocation

let UserLocationID = "userCurrentLocation"


class HomeScreenViewModel { 
    
    let locationService: LocationService
    let geolocationService: GeoLocationService
    
    let storageService: LocalStorageBaseService<TripModel>
    let contactsProvider = ContactsProvider()
    
    var locationMarkers: [LocationMarkerViewModel] = []
    var routes: [RouteViewModel] = []
    
    var onLocationMarkersUpdated: (([LocationMarkerViewModel]) -> Void)? = nil
    var onContactsUpdate: ((_ updated: Bool, _ error: Error?) -> Void)?
    var lastLocationSelected: CLLocationCoordinate2D? = nil
    
    var selectedContactNames: [String] = []
    var currentUserLocation: CLLocationCoordinate2D? = nil
    var onRoutesFetched: (([CLLocationCoordinate2D]) -> Void)?
    
    deinit {
        onLocationMarkersUpdated = nil
        onContactsUpdate = nil
    }
    
    init(locationService: LocationService, geoService: GeoLocationService,
         tripStorageService: LocalStorageBaseService<TripModel>) {
        self.locationService = locationService
        self.geolocationService = geoService
        self.storageService = tripStorageService
    }
    
    
    func getMyCurrentLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        guard locationService.checkAuthorizationStatus() != .denied else {
            completion(.failure(HomeScreenError.locationServicesDisabled))
            return
        }
        locationService.startUpdatingLocation {[weak self] result in
            switch result {
            case .success(let userLocation):
                self?.locationMarkers.removeAll(where: { marker in
                    marker.id == UserLocationID
                })
                self?.locationMarkers.append(LocationMarkerViewModel(id: UserLocationID,
                                                                     icon: UIImage(resource: .currentLocation),
                                                                     latitude: userLocation.latitude, longitude: userLocation.longitude))
                completion(.success(userLocation))
                self?.currentUserLocation = userLocation
                if let locationMarkers = self?.locationMarkers {
                    self?.onLocationMarkersUpdated?(locationMarkers)
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func onMapTap(at coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async {[self] in
            let newMarker = LocationMarkerViewModel(id: "tripLocation",
                                                    icon: UIImage(resource: .icMarker),
                                                    latitude: coordinate.latitude, longitude: coordinate.longitude)
            locationMarkers = locationMarkers.filter { $0.id !=  "tripLocation" }
            locationMarkers.append(newMarker)
            lastLocationSelected = coordinate
            onLocationMarkersUpdated?(locationMarkers)
        }
    }
    
    func getAddress(at coordinate: CLLocationCoordinate2D, completion: @escaping (Result<ReverseGeocodeToAddressResponse, APIError>) -> Void) {
        do {
            try geolocationService.getReverseGeocoding(at: coordinate) { address in
                print("Address: \(String(describing: address))")
                completion(address)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    func getDirectionToDestination(at destination: CLLocationCoordinate2D, completion: @escaping (Result<[RouteViewModel], APIError>) -> Void) {
        guard let currentUserLocation = currentUserLocation else {
            print("throw an appropriate error")
            return
        }
        
        do {
            try geolocationService.getDirection(from: currentUserLocation,
                                                to: destination,
                                                type: "car",
                                                avoidTrafficZone: true,
                                                avoidOddEvenZone: true,
                                                alternative: true,
                                                bearing: nil,
                                                waypoints: nil) { result in
                switch result {
                case .success(let response):
                    
                    let routesViewModels = response.routes.compactMap { route in
                        RouteViewModel(route: route)
                    }
                    let allCoordinates = routesViewModels.flatMap { $0.coordinates }
                    DispatchQueue.main.async {
                        self.onRoutesFetched?(allCoordinates)
                    }
                    completion(.success(routesViewModels))
                    
                case .failure(let error):
                    print("Error: \(error)")
                    completion(.failure(error))
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

extension HomeScreenViewModel {
    
    enum HomeScreenError: LocalizedError {
        case locationServicesDisabled
        
        var errorDescription: String? {
            switch self {
            case .locationServicesDisabled:
                return "Location services are disabled or has no permission."
            }
        }
    }
    
    struct LocationMarkerViewModel {
        let id: String
        let icon: UIImage
        let latitude: Double
        let longitude: Double
        
        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
}
