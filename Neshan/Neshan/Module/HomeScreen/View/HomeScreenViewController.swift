//
//  HomeScreenViewController.swift
//  CustomMap
//
//  Created by Bahar on 12/5/1403 AP.
//

import UIKit
import Foundation
import CoreLocation

class HomeScreenViewController: BaseViewController<HomeScreenViewModel> {
    
    
    var mapView: NTMapView!
    var markerLayer: NTVectorElementLayer?
    var routeLayers: NTVectorElementLayer?
    var marker = NTMarker()
    var mapEventListener: MapEventListener!
    var selectedContactsNames: [String] = []
    
    var bottomView: DestinationInfosView!
    
    typealias OnTripTapCallback = () -> Void
    
    var onTripCollectionTap: OnTripTapCallback?
    
    var location: CLLocationCoordinate2D?
    var routes: [RouteViewModel] = []
    var duration: String = ""
    var labelLayer: NTVectorElementLayer?

    
    // MARK: -  LifeCycle Methods
    deinit {
        onTripCollectionTap = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupMapView()
        setupBottomView()
    }
    
    //MARK: - ViewSetup
    func setupMapView() {
        mapView = NTMapView(frame: .zero)
        view.addSubview(mapView)
        
        let mapBase = NTNeshanServices.createBaseMap(NTNeshanMapStyle.STANDARD_DAY)
        mapView?.getLayers().add(mapBase)
        let trafficLayer = NTNeshanServices.createTrafficLayer()
        mapView?.getLayers().add(trafficLayer)
        
        let poiLayer = NTNeshanServices.createPOILayer(true)
        mapView?.getLayers().add(poiLayer)
        
        markerLayer = NTNeshanServices.createVectorElementLayer()
        mapView?.getLayers().add(markerLayer)
        
        routeLayers = NTNeshanServices.createVectorElementLayer()
        mapView?.getLayers().add(routeLayers)
        
        mapView?.setZoom(17, durationSeconds: 0.4)
        
        mapEventListener = MapEventListener()
        mapView?.setMapEventListener(mapEventListener)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
    }
    
    func setupBottomView() {
        bottomView = DestinationInfosView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.dismissAction = { [weak self] in
            self?.hideBottomView()
        }
        bottomView.onMakeRouteTap = { [weak self] in
            self?.showRoutesOnMap()
        }
        view.addSubview(bottomView)
        
        bottomView.alpha = 0.0
        bottomView.isHidden = true
        
        NSLayoutConstraint.activate([
            bottomView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/3)
        ])
    }
    
    //MARK: - Methods
    
    func updateMapWithLocation(_ coordinate: CLLocationCoordinate2D) {
        let lngLat = NTLngLat(x: coordinate.longitude, y: coordinate.latitude)
        mapView?.setFocalPointPosition(lngLat, durationSeconds: 0.4)
        mapView?.setZoom(17, durationSeconds: 0.4)
        addMarkerToMap(location: coordinate,
                       icon: UIImage(resource: .currentLocation),
                       id: "userCurrentLocation")
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
    
    
    func handleError(_ error: Error) {
        presentAlert(with: error.localizedDescription)
    }
    
    override func bindViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.getMyCurrentLocation {[weak self] result in
            switch result {
            case .success(let location):
                print("current location: \(location)")
                self?.updateMapWithLocation(location)
            case .failure(let error):
                self?.handleError(error)
            }
        }
        
        viewModel.onLocationMarkersUpdated = {[weak self] infos in
            self?.markerLayer?.clear()
            for info in infos {
                self?.addMarkerToMap(location: info.coordinate,
                                     icon: info.icon,
                                     id: info.id)
            }
        }
        
        viewModel.onContactsUpdate = {[weak self] (_, error) in
            guard error == nil else {
                self?.presentAlert(with: error!.localizedDescription)
                return
            }
        }
        
        // input and output binding
//        mapEventListener.onMapTap = {[weak viewModel] location in
//            viewModel?.onMapTap(at: location)
//            viewModel?.getAddress(at: location) { [weak self] result in
//                self?.location = location
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let address):
//                        self?.bottomView.setDestinationName(address.routeName)
//                        self?.bottomView.setDestinationFullAddress(address.formattedAddress)
//                        self?.showBottomView()
//                    case .failure(let error):
//                        print("Error: \(error)")
//                    }
//                }
//            }
            
//            viewModel?.getDirectionToDestination(at: location, completion: { [weak self] result in
//                switch result {
//                case .success(let success):
//                    self?.routeLayers?.clear()
//                    self?.routes = success
//                    for route in success {
//                        DispatchQueue.main.async {
//                            let duration = route.route.legs?.first?.duration.text
//                            self?.duration = duration ?? ""
//                            let distance = route.route.legs?.first?.distance.text
//                            self?.bottomView.setDuration(duration: duration, distance: distance)
//                        }
//                    }
//                case.failure(let error):
//                    print("error \(error)")
//                }
//            })
//        }
        
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
        labelStyleCreator?.setBackgroundColor(NTARGB(r: 255, g: 0, b: 0, a: 255))

        let labelStyle = labelStyleCreator?.buildStyle()

        let label = NTLabel(
            pos: NTLngLat(x: coordinate.longitude, y: coordinate.latitude),
            style: labelStyle,
            text: "Duration: \(duration)"
        )

        labelLayer?.add(label)
    }

    
    @objc func handleCollectionListButtonTapped() {
        onTripCollectionTap?()
    }
    
    func showBottomView() {
        bottomView.isHidden = false
        UIView.animate(withDuration: 0.1) {
            self.bottomView.alpha = 1.0
        }
    }
    
    func hideBottomView() {
        routeLayers?.clear()
        UIView.animate(withDuration: 0.1, animations: {
            self.bottomView.alpha = 0.0
        }) { _ in
            self.bottomView.isHidden = true
        }
    }
    
}
