//
//  MapViewModel.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Foundation
import RxSwift
import CoreLocation

class MapViewModel: BaseViewModel {
    
    //TODO: should integrate these properties to be reactive
    
    let locationService: LocationService
    let geolocationService: GeoLocationService
    
    let userLocation = PublishSubject<(x: Double,y: Double)>()
    //    let showExplore = PublishSubject<(x: Double,y: Double)>()
    let hideExplore = PublishSubject<Void>()
    let showSearch = PublishSubject<(x: Double,y: Double)>()
    let showSearchResult = PublishSubject<Bool>()
    let showSearchBox = PublishSubject<(term: String, selectedItem: SearchItemDto, result: [SearchItemDto])>()

    
    var onLocationMarkersUpdated: (([LocationMarkerViewModel]) -> Void)? = nil
    var onRoutesFetched: (([CLLocationCoordinate2D]) -> Void)?
    
    var locationMarkers: [LocationMarkerViewModel] = []
    var routes: [RouteViewModel] = []
    
    var currentUserLocation: CLLocationCoordinate2D? = nil
    var lastLocationSelected: CLLocationCoordinate2D? = nil
    var selectedContactNames: [String] = []
    
    init(locationService: LocationService,
         geoService: GeoLocationService) {
        
        self.locationService = locationService
        self.geolocationService = geoService
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
                                                                                         latitude: userLocation.latitude,
                                                                                         longitude: userLocation.longitude))
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

    
    func getDirectionToDestination(at destination: CLLocationCoordinate2D, completion: @escaping (Result<[RouteViewModel], APIError>) -> Void) {
        guard let currentUserLocation = self.currentUserLocation else {
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
    
    func getAddress(at coordinate: CLLocationCoordinate2D, completion: @escaping (Result<ReverseGeocodeToAddressResponse, APIError>) -> Void) {
        do {
            try geolocationService.getReverseGeocoding(at: coordinate) { address in
                completion(address)
            }
        } catch let error as NSError {
            print("Caught error: \(error.localizedDescription)")
            completion(.failure(APIError.decodingError(error)))
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

    fileprivate func getMarkers(by items: [SearchItemDto], hasAnimated: Bool = false) -> [NTMarker] {
        let builder = NTMarkerStyleCreator()
        
        if hasAnimated {
            var animSt = NTAnimationStyle()
            
            let animStB1 = NTAnimationStyleBuilder()
            animStB1?.setFade(NTAnimationType.ANIMATION_TYPE_SMOOTHSTEP)
            animStB1?.setSizeAnimationType(NTAnimationType.ANIMATION_TYPE_SPRING)
            animStB1?.setPhaseInDuration(0.5)
            animStB1?.setPhaseOutDuration(0.5)
            animSt = animStB1!.buildStyle()
            builder?.setAnimationStyle(animSt)
            
            let markStCr = NTMarkerStyleCreator()
            markStCr?.setSize(50)
            markStCr?.setBitmap(NTBitmapUtils.createBitmap(from: UIImage(named: "ic_marker")))
            markStCr?.setAnimationStyle(animSt)
            
            var markSt = NTMarkerStyle()
            markSt = markStCr!.buildStyle()
            
            let marker = NTMarker(pos: NTLngLat(x: items.first!.location.x, y: items.first!.location.y), style: markSt)
            return [marker!]
        } else {
            let pin = UIImage(named: "ic_marker")
            let bitmap = NTBitmapUtils.createBitmap(from: pin!)
            builder?.setBitmap(bitmap)
            builder?.setSize(30)
        }
        
        let style = (builder?.buildStyle())!
        
        return items.compactMap { NTMarker(pos: NTLngLat(x: $0.location.x, y: $0.location.y), style: style) }
    }
}

extension MapViewModel {
    
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

