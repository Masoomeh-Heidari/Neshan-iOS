// LocationServices.swift
// CustomMap
//
// Created by Bahar on 12/5/1403 AP.
//

import CoreLocation

enum LocationServiceStatus: Int {
    case notDetermined
    case denied
    case authorized
}

protocol LocationService: AnyObject {
    
    func checkAuthorizationStatus() -> LocationServiceStatus
    func requestOnceLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void)
    func startUpdatingLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void)
    func stopUpdatingLocation()
}


class DefaultLocationService: NSObject, LocationService, CLLocationManagerDelegate {
   
    private let locationManager = CLLocationManager()
    
    var didUpdateLocation: ((CLLocation) -> Void)?
    var onceLocation: ((CLLocation) -> Void)?
    var didFailWithError: ((Error) -> Void)?
    var lastLocation: CLLocation? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    func checkAuthorizationStatus() -> LocationServiceStatus {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            return .authorized
        case .notDetermined:
            return .notDetermined
        default:
            return .denied
        }
    }
    
    func requestOnceLocation(completion: @escaping (Result<CLLocationCoordinate2D,Error>) -> Void) {
        if checkAuthorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        self.onceLocation = {[weak self] location in
            let coordinate = location.coordinate
            guard coordinate != kCLLocationCoordinate2DInvalid else {
                return
            }
            DispatchQueue.main.async {
                completion(.success(coordinate))
            }
            self?.onceLocation = nil
        }
        
        self.didFailWithError = { error in
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
        locationManager.requestLocation()
    }
    
    func startUpdatingLocation(completion: @escaping (Result<CLLocationCoordinate2D,Error>) -> Void) {
        if checkAuthorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.requestLocation()

        self.didUpdateLocation = { location in
            let coordinate = location.coordinate
            guard coordinate != kCLLocationCoordinate2DInvalid else {
                return
            }
            DispatchQueue.main.async {
                completion(.success(coordinate))
            }
        }
        
        self.didFailWithError = { error in
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    func stopUpdatingLocation() {
        self.didUpdateLocation = nil
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        onceLocation?(latestLocation)
        didUpdateLocation?(latestLocation)
        lastLocation = latestLocation
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        didFailWithError?(error)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
}

