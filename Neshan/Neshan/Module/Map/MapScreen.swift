//
//  MapScreen.swift
//  Neshan
//
//  Created by Fariba on 1/9/1404 AP.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class MapScreen: UIViewController {
    let viewModel: MapViewModel

    @IBOutlet weak var currentLocationButton: UIButton!
    private let disposeBag = DisposeBag()

    var mapview:NTMapView?
    var locationManager:CLLocationManager!
    
    var lat: Double = 51.33855846247923
    var lng: Double = 35.69992585886045
    
    var azadiLat: Double = 51.33855846247923
    var azadiLng: Double = 35.69992585886045
    
    let searchLayer = NTNeshanServices.createVectorElementLayer()
    let userLocationLayer = NTNeshanServices.createVectorElementLayer()
    
    var searchTerm: String = ""

    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.viewModel.hideExplore.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initMap()
//        self.setUserCurrentLocation(using: (x: self.azadiLat, y: self.azadiLng))
        self.initUserLocation()
        self.binding()
        self.setupUI()
    }
    
    fileprivate func setupUI() {
       
    }
    
    fileprivate func binding() {
        self.viewModel.showSearchBox.subscribe(on: MainScheduler.instance).subscribe(onNext: {[weak self] items in
            guard let self else { return }
            self.searchLayer?.clear()
            self.searchTerm = items.term
            
            let resultMarkers = self.getMarkers(by: items.result)
            for item in resultMarkers {
                searchLayer?.add(item)
            }
            
            let selectedItemMarker = self.getMarkers(by:[items.selectedItem], hasAnimated: true).first!
            searchLayer?.add(selectedItemMarker)
                        
            mapview?.setFocalPointPosition(NTLngLat(x: items.selectedItem.location.x, y: items.selectedItem.location.y), durationSeconds: 0.4)
            mapview?.setZoom(16, durationSeconds: 0.4)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.userLocation.subscribe(onNext: {[weak self] loc in
            guard let self else { return }
            self.viewModel.showExplore.onNext((x: loc.x, y: loc.y))
            self.userLocationLayer?.clear()
            self.setUserCurrentLocation(using: loc)
        }).disposed(by: self.disposeBag)
    }

    fileprivate func initUserLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .other
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.checkLocationAuthorization(using: self.locationManager)
    }
    
    fileprivate func initMap() {
        mapview = NTMapView();
        let neshan = NTNeshanServices.createBaseMap(NTNeshanMapStyle.NESHAN)
        mapview?.getLayers().add(neshan)
        
        let neshan2 = NTNeshanServices.createTrafficLayer()
        mapview?.getLayers().add(neshan2)
        
        let neshan3 = NTNeshanServices.createPOILayer(false)
        mapview?.getLayers().add(neshan3)
        
        mapview?.setFocalPointPosition(NTLngLat(x: self.lat, y: self.lng), durationSeconds: 0.4)
        mapview?.setZoom(13, durationSeconds: 0.4)
        
        mapview?.getLayers().add(userLocationLayer)
        mapview?.getLayers().add(searchLayer)

        view = mapview
        self.mapview?.bringSubviewToFront(self.currentLocationButton)
        
        setupBottomView()
    }
    
    func setupBottomView() {
        let button = UIButton()
        button.setImage(UIImage(named: "current_target"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.addTarget(self, action: #selector(goToCurrentLocation), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30)
        ])
        self.mapview?.addSubview(button)
        
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30)
        ])
        self.mapview?.addSubview(button)
        
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.mapview?.addSubview(view)
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            view.widthAnchor.constraint(equalToConstant: 30),
            view.heightAnchor.constraint(equalToConstant: 30)
        ])
        self.mapview?.addSubview(button)
        
        
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
        }else {
            let pin = UIImage(named: "ic_marker")
            let bitmap = NTBitmapUtils.createBitmap(from: pin!)
            builder?.setBitmap(bitmap)
            builder?.setSize(30)
        }
        
        let style = (builder?.buildStyle())!
        
        return items.compactMap { NTMarker(pos: NTLngLat(x: $0.location.x, y: $0.location.y), style: style) }
    }
    
    @objc func goToCurrentLocation() {
        let userLocation = self.locationManager.location
        self.lat = userLocation?.coordinate.longitude ?? self.azadiLat
        self.lng = userLocation?.coordinate.latitude ?? self.azadiLng
        self.setUserCurrentLocation(using: (x: self.lat, y: self.lng))
    }
    
    fileprivate func setUserCurrentLocation(using loc: (x: Double, y: Double)) {
        let builder = NTMarkerStyleCreator()

        let pin = UIImage(named: "current_location")
        let bitmap = NTBitmapUtils.createBitmap(from: pin!)
        builder?.setBitmap(bitmap)
        builder?.setSize(21)
        let style = (builder?.buildStyle())!

        let marker = NTMarker(pos: NTLngLat(x: loc.x, y: loc.y), style: style)
        userLocationLayer?.add(marker)
        
        mapview?.setFocalPointPosition(NTLngLat(x: loc.x, y: loc.y), durationSeconds: 0.4)
        mapview?.setZoom(16, durationSeconds: 0.4)
    }
    
    @IBAction func currentLocationButtonAction(_ sender: Any) {
        let userLocation = self.locationManager.location
        self.lat = userLocation?.coordinate.longitude ?? self.azadiLat
        self.lng = userLocation?.coordinate.latitude ?? self.azadiLng
        
        self.viewModel.userLocation.onNext((x: self.lat, y: self.lng))
    }
    
}

extension MapScreen: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.checkLocationAuthorization(using: manager)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        self.lat = userLocation.coordinate.longitude
        self.lng = userLocation.coordinate.latitude
        
        self.viewModel.userLocation.onNext((x: userLocation.coordinate.longitude, y: userLocation.coordinate.latitude))
    }
    
    fileprivate func checkLocationAuthorization(using manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
                break
            case .denied, .notDetermined, .restricted:
                self.setUserCurrentLocation(using: (x: self.azadiLat, y: self.azadiLng))
        @unknown default:
            break
        }
    }
}


