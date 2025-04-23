//
//  MapViewModel.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//


import Foundation
import CoreLocation
import Combine

let UserLocationID = "userCurrentLocation"

class MapViewModel: BaseViewModel {
    
    var locationMarkersUpdated = PassthroughSubject<[LocationMarkerViewModel], Never>()
    
    var userLocation           = PassthroughSubject<(x: Double, y: Double), Never>()
    var showSearch             = PassthroughSubject<(x: Double, y: Double), Never>()
    var showSearchResult       = PassthroughSubject<Bool, Never>()
    var showSearchBox          = PassthroughSubject<(term: String, selectedItem: SearchItemDto, result: [SearchItemDto]), Never>()

    
    @Published private var locationMarkers: [LocationMarkerViewModel] = []
    @Published private var routes: [RouteViewModel] = []
    
    
    @Published var currentUserLocation: CLLocationCoordinate2D? = nil
    
    var userLocationPublisher: AnyPublisher<CLLocationCoordinate2D, Never> {
           $currentUserLocation
               .compactMap { $0 }
               .eraseToAnyPublisher()
       }
    
    @Published var lastLocationSelected: CLLocationCoordinate2D? = nil
    
    let locationService: LocationService =  DefaultLocationService()
    var geolocationService: GeoLocationService!
    
    lazy var apiClient: ApiClient = {
        let client = DefaultAPIClient.init(baseURL: AppConfig.baseURL,
                                           configuration: .default,
                                           apiKey: AppConfig.apiKey)
        return client
    }()
    
    override init() {
        super.init()
        self.geolocationService = DefaultGeoLocationService(apiService: self.apiClient)
    }


    func getMyCurrentLocation() {
        guard locationService.checkAuthorizationStatus() != .denied else {
            print("Location services are disabled")
            return
        }
        
        locationService.requestOnceLocation { [weak self] result in
            switch result {
            case .success(let userLocation):
                self?.currentUserLocation = userLocation
                self?.locationMarkers.removeAll(where: { marker in
                    marker.id == UserLocationID
                })
                self?.locationMarkers.append(LocationMarkerViewModel(id: UserLocationID,
                                                                     icon: UIImage(resource: .currentLocation),
                                                                     latitude: userLocation.latitude,
                                                                     longitude: userLocation.longitude))
            case .failure(let error):
                print("Failed to get location: \(error)")
            }
        }
        
        locationService.startUpdatingLocation { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userLocation):
                self.currentUserLocation = userLocation
                self.locationMarkers.removeAll(where: { marker in
                    marker.id == UserLocationID
                })
                self.locationMarkers.append(LocationMarkerViewModel(id: UserLocationID,
                                                                     icon: UIImage(resource: .currentLocation),
                                                                     latitude: userLocation.latitude,
                                                                     longitude: userLocation.longitude))
            case .failure(let error):
                print("Failed to get location: \(error)")
            }
        }
    }

    
    func getDirectionToDestination(at destination: CLLocationCoordinate2D) -> AnyPublisher<[RouteViewModel], APIError> {
        guard let currentUserLocation = self.currentUserLocation else {
            return Fail(error: APIError.invalidRequest)
                .eraseToAnyPublisher()
        }
       //TODO: Replace hardcoded with variables or a more scalable resource management system.
        return geolocationService.getDirection(from: currentUserLocation,
                                               to: destination,
                                               type: "car",
                                               avoidTrafficZone: true,
                                               avoidOddEvenZone: true,
                                               alternative: true,
                                               bearing: nil,
                                               waypoints: nil)
              .map { response in
                let routeViewModels = response.routes.compactMap { RouteViewModel(route: $0) }
                                
                return routeViewModels
            }
            .eraseToAnyPublisher()
    }

    
    
    func getAddress(at coordinate: CLLocationCoordinate2D) -> AnyPublisher<ReverseGeocodeToAddressResponse, APIError> {
        
        return geolocationService.getReverseGeocoding(at: coordinate)
            .mapError { error in
                APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }

    
    func onMapTap(at coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async { [self] in
            let newMarker = LocationMarkerViewModel(id: "tripLocation",
                                                     icon: UIImage(resource: .icMarker),
                                                     latitude: coordinate.latitude,
                                                     longitude: coordinate.longitude)
            self.locationMarkers = self.locationMarkers.filter { $0.id != "tripLocation" }
            self.locationMarkers.append(newMarker)
            self.lastLocationSelected = coordinate
            self.locationMarkersUpdated.send(self.locationMarkers)
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



