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
    let viewModel: MapViewModel?
    
    private let disposeBag = DisposeBag()
    
    var mapView:NTMapView!
    var locationManager:CLLocationManager!
    var infoBox: DestinationInfosView!
    
    
    var lat: Double = 51.33855846247923
    var lng: Double = 35.69992585886045
    
    var azadiLat: Double = 51.33855846247923
    var azadiLng: Double = 35.69992585886045
    
    let searchLayer = NTNeshanServices.createVectorElementLayer()
    let userLocationLayer = NTNeshanServices.createVectorElementLayer()
    
    var searchTerm: String = ""
    
    lazy var currenLocalButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "current_target"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(goToCurrentLocation), for: .touchUpInside)
        return button
    }()

    lazy var searchViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToSearch)))
        return view
    }()

    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "جستجو در نشان"
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(white: 6.0, alpha: 8.0)
        textField.semanticContentAttribute = .forceRightToLeft
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.textAlignment = .right
        textField.isEnabled = false
        return textField
    }()
    
    var markerLayer: NTVectorElementLayer?
    var routeLayers: NTVectorElementLayer?
    var marker = NTMarker()
    var mapEventListener: MapEventListener!
    
    var location: CLLocationCoordinate2D?
    var routes: [RouteViewModel] = []
    var duration: String = ""
    var labelLayer: NTVectorElementLayer?
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.viewModel?.hideExplore.onNext(())
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
        self.bindViewModel()
        self.setupInfoBox()
    }
    
    
    
    fileprivate func binding() {
        self.viewModel?.showSearchBox.subscribe(on: MainScheduler.instance).subscribe(onNext: {[weak self] items in
            guard let self else { return }
           
            self.searchLayer?.clear()
            self.markerLayer?.clear()
            self.searchTerm = items.term
            
            let resultMarkers = self.getMarkers(by: items.result)
            for item in resultMarkers {
                searchLayer?.add(item)
            }
            
            let selectedItemMarker = self.getMarkers(by:[items.selectedItem], hasAnimated: true).first!
            searchLayer?.add(selectedItemMarker)
            
            self.fetchAddressAndUpdateInfoBox(for: items.selectedItem.location.toCLLocationCoordinate2D)
            self.showBottomView()
            
            
            mapView?.setFocalPointPosition(NTLngLat(x: items.selectedItem.location.x, y: items.selectedItem.location.y), durationSeconds: 0.4)
            mapView?.setZoom(16, durationSeconds: 0.4)
        }).disposed(by: self.disposeBag)
        
        
        
        //        self.viewModel.userLocation.subscribe(onNext: {[weak self] loc in
        //            guard let self else { return }
        //            self.userLocationLayer?.clear()
        //            self.setUserCurrentLocation(using: loc)
        //        }).disposed(by: self.disposeBag)
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
        mapView = NTMapView(frame: .zero)
        view.addSubview(mapView)
        
        let neshan = NTNeshanServices.createBaseMap(NTNeshanMapStyle.NESHAN)
        mapView?.getLayers().add(neshan)
        
        let neshan2 = NTNeshanServices.createTrafficLayer()
        mapView?.getLayers().add(neshan2)
        
        let neshan3 = NTNeshanServices.createPOILayer(false)
        mapView?.getLayers().add(neshan3)
        
        markerLayer = NTNeshanServices.createVectorElementLayer()
        mapView?.getLayers().add(markerLayer)
        
        mapView?.setFocalPointPosition(NTLngLat(x: self.lat, y: self.lng), durationSeconds: 0.4)
        mapView?.setZoom(13, durationSeconds: 0.4)
        
        routeLayers = NTNeshanServices.createVectorElementLayer()
        mapView?.getLayers().add(routeLayers)
        
        mapEventListener = MapEventListener()
        mapView?.setMapEventListener(mapEventListener)
        
        mapView?.getLayers().add(userLocationLayer)
        mapView?.getLayers().add(searchLayer)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
        setupBottomView()
        
    }
    
    //MARK: - ViewSetup
    func setupBottomView() {
        configureSearchView()
        setUpCurrentLocationButton()
    }
    
    
    private func configureSearchView() {
        searchViewContainer.backgroundColor = .white
        searchViewContainer.translatesAutoresizingMaskIntoConstraints = false
        searchViewContainer.isUserInteractionEnabled = true
        searchViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToSearch)))
        mapView?.addSubview(searchViewContainer)
        NSLayoutConstraint.activate([
            searchViewContainer.trailingAnchor.constraint(equalTo: mapView!.trailingAnchor),
            searchViewContainer.leadingAnchor.constraint(equalTo: mapView!.leadingAnchor),
            searchViewContainer.bottomAnchor.constraint(equalTo: mapView!.bottomAnchor, constant: -8),
            searchViewContainer.heightAnchor.constraint(equalToConstant: 60)
        ])
        addSearchTextField()
    }

    private func addSearchTextField() {
      
        searchViewContainer.addSubview(searchTextField)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchTextField.trailingAnchor.constraint(equalTo: searchViewContainer.trailingAnchor, constant: -8),
            searchTextField.leadingAnchor.constraint(equalTo: searchViewContainer.leadingAnchor, constant: 8),
            searchTextField.bottomAnchor.constraint(equalTo: searchViewContainer.bottomAnchor, constant: -8),
            searchTextField.topAnchor.constraint(equalTo: searchViewContainer.topAnchor, constant: 8)
        ])
    }

    private func setUpCurrentLocationButton() {
        
        currenLocalButton.translatesAutoresizingMaskIntoConstraints = false
        mapView?.addSubview(currenLocalButton)
        currenLocalButton.addTarget(self, action: #selector(goToCurrentLocation), for: .touchUpInside)
        NSLayoutConstraint.activate([
            currenLocalButton.trailingAnchor.constraint(equalTo: mapView!.trailingAnchor, constant: -16),
            currenLocalButton.bottomAnchor.constraint(equalTo: searchViewContainer.topAnchor, constant: -16),
            currenLocalButton.widthAnchor.constraint(equalToConstant: 30),
            currenLocalButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc func goToSearch() {
        let userLocation = self.locationManager.location
        self.lat = userLocation?.coordinate.longitude ?? self.azadiLat
        self.lng = userLocation?.coordinate.latitude ?? self.azadiLng
        self.viewModel?.showSearch.onNext((x: self.lat, y: self.lng))
    }
    
    func setupInfoBox() {
        infoBox = DestinationInfosView()
        infoBox.translatesAutoresizingMaskIntoConstraints = false
        infoBox.dismissAction = { [weak self] in
            self?.hideBottomView()
        }
        infoBox.onMakeRouteTap = { [weak self] in
            self?.showRoutesOnMap()
        }
        self.view.addSubview(infoBox)
        
        infoBox.alpha = 0.0
        infoBox.isHidden = true
        
        NSLayoutConstraint.activate([
            infoBox.leftAnchor.constraint(equalTo: mapView.leftAnchor),
            infoBox.rightAnchor.constraint(equalTo: mapView.rightAnchor),
            infoBox.bottomAnchor.constraint(equalTo: mapView.bottomAnchor),
            infoBox.heightAnchor.constraint(equalTo: mapView.heightAnchor, multiplier: 1/3),
        ])
    }
    
    func showRoutesOnMap() {
        guard !routes.isEmpty else {
            print("No routes available to show.")
            return
        }
        
        for route in routes {
            drawPolylineOnMap(coordinates: route.coordinates, color: route.color)
        }
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        getCurrentLocation()
        viewModel.onLocationMarkersUpdated = {[weak self] infos in
            self?.markerLayer?.clear()
            for info in infos {
                self?.addMarkerToMap(location: info.coordinate,
                                     icon: info.icon,
                                     id: info.id)
            }
        }
        
        
        mapEventListener.onMapTap = {[weak viewModel] location in
            viewModel?.onMapTap(at: location)
            self.fetchAddressAndUpdateInfoBox(for: location)
            self.showBottomView()
        }
    }
    
    func fetchAddressAndUpdateInfoBox(for location: CLLocationCoordinate2D) {
        self.viewModel?.getAddress(at: location) { [weak self] result in
            guard let self = self else { return }
            self.location = location
            DispatchQueue.main.async {
                switch result {
                case .success(let address):
                    self.infoBox.setDestinationName(address.routeName)
                    self.infoBox.setDestinationFullAddress(address.formattedAddress)
                case .failure(let error):
                    print("Error fetching address: \(error)")
                }
            }
        }
        
        self.viewModel?.getDirectionToDestination(at: location, completion: { [weak self] result in
            switch result {
            case .success(let success):
                self?.routeLayers?.clear()
                self?.routes = success
                for route in success {
                    DispatchQueue.main.async {
                        let duration = route.route.legs?.first?.duration.text
                        self?.duration = duration ?? ""
                        let distance = route.route.legs?.first?.distance.text
                        self?.infoBox.setDuration(duration: duration, distance: distance)
                    }
                }
            case.failure(let error):
                print("error \(error)")
            }
        })
    }

    func updateMapWithLocation(_ coordinate: CLLocationCoordinate2D) {
        let lngLat = NTLngLat(x: coordinate.longitude, y: coordinate.latitude)
        mapView?.setFocalPointPosition(lngLat, durationSeconds: 0.4)
        mapView?.setZoom(17, durationSeconds: 0.4)
        addMarkerToMap(location: coordinate,
                       icon: UIImage(resource: .currentLocation),
                       id: "userCurrentLocation")
        self.viewModel?.currentUserLocation = coordinate
    }
    
    func addMarkerToMap(location: CLLocationCoordinate2D, icon: UIImage, id: String) {
        
        let animationStyleBuilder = NTAnimationStyleBuilder()
        animationStyleBuilder?.setFade(.ANIMATION_TYPE_SMOOTHSTEP)
        animationStyleBuilder?.setSizeAnimationType(.ANIMATION_TYPE_SPRING)
        animationStyleBuilder?.setPhaseInDuration(0.5)
        animationStyleBuilder?.setPhaseOutDuration(0.5)
        let animSt = animationStyleBuilder?.buildStyle()
        
        let markStCr = NTMarkerStyleCreator()
        markStCr?.setSize(50)
        
        let bitmap = NTBitmapUtils.createBitmap(from: icon)
        markStCr?.setBitmap(bitmap)
        
        markStCr?.setAnimationStyle(animSt)
        let markSt = markStCr?.buildStyle()
        
        let lngLatMarker = NTLngLat(x: location.longitude, y: location.latitude)
        let marker = NTMarker(pos: lngLatMarker, style: markSt)
        let metadata = NTVariant(string: id)
        marker?.setMetaData("id", element: metadata)
        
        markerLayer?.add(marker)
        
    }
    
    func drawPolylineOnMap(coordinates: [CLLocationCoordinate2D], color: UIColor) {
        labelLayer?.clear()
        
        if labelLayer == nil {
            labelLayer = NTNeshanServices.createVectorElementLayer()
            mapView?.getLayers().add(labelLayer!)
        }
        
        let lngLatVector = NTLngLatVector()
        for coordinate in coordinates {
            let lngLat = NTLngLat(x: coordinate.longitude, y: coordinate.latitude)
            lngLatVector?.add(lngLat)
        }
        
        let lineGeom = NTLineGeom(poses: lngLatVector)
        
        let line = NTLine(geometry: lineGeom, style: getLineStyle(color: color))
        
        routeLayers?.add(line)
        
        
        if let firstCoordinate = coordinates.first {
            mapView?.setFocalPointPosition(NTLngLat(x: firstCoordinate.longitude, y: firstCoordinate.latitude), durationSeconds: 0.25)
            mapView?.setZoom(17, durationSeconds: 0)
            addRouteLabel(at: firstCoordinate, duration: self.duration)
            
        }
        
    }
    
    func getLineStyle(color: UIColor) -> NTLineStyle? {
        if let lineStCr = NTLineStyleCreator()  {
            let rgb = color.getRGBValues()
            lineStCr.setColor(NTARGB(r: rgb.red , g: rgb.green, b: rgb.blue, a: 190))
            lineStCr.setWidth(8)
            lineStCr.setStretchFactor(1)
            
            return lineStCr.buildStyle()
        } else {
            print("Failed to initialize NTLineStyleCreator")
            return nil
        }
    }
    
    func addRouteLabel(at coordinate: CLLocationCoordinate2D, duration: String) {
        let labelStyleCreator = NTLabelStyleCreator()
        labelStyleCreator?.setFontSize(15)
        labelStyleCreator?.setBackgroundColor(NTARGB(r: 167, g: 172, b: 184, a: 255))
        labelStyleCreator?.setBorderColor(NTARGB(r: 0, g: 0, b: 0, a: 255))
        labelStyleCreator?.setBorderWidth(5)
        labelStyleCreator?.setTextMargins(.init(left: 3, top: 3, right: 3, bottom: 3))
        
        let labelStyle = labelStyleCreator?.buildStyle()
        
        let label = NTLabel(
            pos: NTLngLat(x: coordinate.longitude, y: coordinate.latitude),
            style: labelStyle,
            text: duration
        )
        
        labelLayer?.add(label)
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
        //        let userLocation = self.locationManager.location
        //        self.lat = userLocation?.coordinate.longitude ?? self.azadiLat
        //        self.lng = userLocation?.coordinate.latitude ?? self.azadiLng
        //        self.setUserCurrentLocation(using: (x: self.lat, y: self.lng))
        getCurrentLocation()
    }
    
    func getCurrentLocation() {
        self.markerLayer?.clear()
        self.viewModel?.getMyCurrentLocation {[weak self] result in
            switch result {
            case .success(let location):
                print("current location: \(location)")
                self?.updateMapWithLocation(location)
            case .failure(let error):
                print(error)
            }
        }
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
        
        mapView?.setFocalPointPosition(NTLngLat(x: loc.x, y: loc.y), durationSeconds: 0.4)
        mapView?.setZoom(16, durationSeconds: 0.4)
    }
    
    func showBottomView() {
        DispatchQueue.main.async {
            self.infoBox.isHidden = false
            UIView.animate(withDuration: 0.1) {
                self.infoBox.alpha = 1.0
            }
        }
    }
    
    func hideBottomView() {
        routeLayers?.clear()
        searchLayer?.clear()
        UIView.animate(withDuration: 0.1, animations: {
            self.infoBox.alpha = 0.0
        }) { _ in
            self.infoBox.isHidden = true
        }
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
        
        self.viewModel?.userLocation.onNext((x: userLocation.coordinate.longitude, y: userLocation.coordinate.latitude))
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


