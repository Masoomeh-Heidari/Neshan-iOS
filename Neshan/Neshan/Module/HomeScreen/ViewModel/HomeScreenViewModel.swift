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
    var contacts: [ContactViewModel] = []
    
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
    
    func getContacts() {
        contactsProvider.requestAccess { [weak self] granted in
            guard granted else {
                return
            }
            self?.contactsProvider.fetchContacts { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let contacts):
                        self?.contacts = contacts.map(ContactViewModel.init)
                        self?.onContactsUpdate?(true, nil)
                    case .failure(let error):
                        self?.onContactsUpdate?(false, error)
                    }
                    
                }
            }
        }
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
    
    func onSaveTripTap(title: String, address: String? = nil) -> Bool {
        guard let coordinate = lastLocationSelected else {
            return false
        }
        let model = TripModel(id: Int(Date.timeIntervalSinceReferenceDate),
                              title: title,
                              address: address,
                              contacts: [],
                              lat: coordinate.latitude,
                              lng: coordinate.longitude)
        storageService.save(model)
        return true
    }
   
    //MARK: - Contacts methods
    func didSelectContact(at index: Int) {
        guard index >= 0 && index < contacts.count else { return }
        
        let contact = contacts[index]
        contact.isSelected = true
        selectedContactNames.append(contact.contact.givenName)
    }
    
    func deselectContact(at index: Int) {
        guard index >= 0 && index < contacts.count else { return }
        
        let contact = contacts[index]
        contact.isSelected = false
        if let nameIndex = selectedContactNames.firstIndex(of: contact.contact.givenName) {
            selectedContactNames.remove(at: nameIndex) // Remove deselected contact name
        }
    }
    
    func getSelectedContactNames() -> [String] {
        return selectedContactNames
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
