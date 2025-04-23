//
//  MapScreen.swift
//  Neshan
//
//  Created by Fariba on 1/9/1404 AP.
//

import UIKit
import CoreLocation
import Combine
import AVFoundation

class MapScreen: UIViewController, UIGestureRecognizerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    let viewModel: MapViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var mapView:NTMapView!
    //    var locationManager:CLLocationManager!
    var infoBox: DestinationInfosView!
    
    // Audio vars
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var recordingSession : AVAudioSession!
    var isRecording: Bool = false
    var isPlaying: Bool = false
    
    var timer: Timer?
    var elapsedTime: TimeInterval = 0
    
    var lat: Double = 51.33855846247923
    var lng: Double = 35.69992585886045
    
    var azadiLat: Double = 51.33855846247923
    var azadiLng: Double = 35.69992585886045
    
    let searchLayer = NTNeshanServices.createVectorElementLayer()
    let userLocationLayer = NTNeshanServices.createVectorElementLayer()
    
    var searchTerm: String = ""
    
    var markerLayer: NTVectorElementLayer?
    var routeLayers: NTVectorElementLayer?
    var marker = NTMarker()
    var mapEventListener: MapEventListener!
    
    var location: CLLocationCoordinate2D?
    var routes: [RouteViewModel] = []
    var duration: String = ""
    var labelLayer: NTVectorElementLayer?
    let sheet = AudioBottomSheet()

    //MARK: - Lazy Vars
    
    lazy var currenLocalButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "current_target"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(goToCurrentLocation), for: .touchUpInside)
        return button
    }()
    
    lazy var recordButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "microphone"), for: .normal)
        
        button.tintColor = Colors.pageControllerColor
        button.backgroundColor = Colors.backgroundColor
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50),
        ])
        return button
    }()
    
    lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("جستجو در نشان  ", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = Fonts.iranSansMobile(size: 13).font
        button.contentHorizontalAlignment = .right
        button.semanticContentAttribute = .forceRightToLeft
        button.backgroundColor = Colors.backgroundColor
        button.addTarget(self, action: #selector(goToSearch), for: .touchUpInside)
        return button
    }()
    
    lazy var searchFieldContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [recordButton, searchButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fill
        stack.backgroundColor = Colors.backgroundColor
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var searchContainerView : UIView = {
        let view = UIView()
        view.backgroundColor = Colors.backgroundColor
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - init
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        print("ViewModel deallocated")
    }
    
    //MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
        binding()
        setupRecorder()
        setupInfoBox()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    //MARK: - Binging
    fileprivate func binding() {
        self.viewModel.showSearchBox.receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] items in
                
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
            }).store(in: &cancellables)
        
        viewModel.locationMarkersUpdated.receive(on: RunLoop.main)
            .sink { [weak self] infos in
                guard let self else { return }
                
                self.markerLayer?.clear()
                for info in infos {
                    self.addMarkerToMap(location: info.coordinate,
                                        icon: info.icon,
                                        id: info.id)
                }
            }
            .store(in: &cancellables)
        
        mapEventListener.onMapTap = { [weak self] location in
            guard let self else { return }
            self.viewModel.onMapTap(at: location)
            self.lat = location.longitude
            self.lng = location.latitude
            self.fetchAddressAndUpdateInfoBox(for: location)
            self.showBottomView()
        }
        
        self.viewModel.userLocationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.lat = location.latitude
                self?.lng = location.longitude
                self?.updateMapWithLocation(location)
            }
            .store(in: &cancellables)
        
        //record binding
        sheet.playTappedPublisher.sink { [weak self] in
            guard let self else { return }
            self.playAudio()
        } .store(in: &cancellables)
        
        sheet.stopTappedPublisher.sink { [weak self] in
            guard let self else { return }
            self.stopRecording()
            self.stopTimer()
        } .store(in: &cancellables)
        
        sheet.uploadTappedPublisher.sink {[weak self] _ in
            guard let self else { return }
            self.uploadAudioFile()
        }.store(in: &cancellables)
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
        self.goToCurrentLocation()
        setupBottomView()
    }
    
    //MARK: - Setup View
    func setupBottomView() {
        configureSearchView()
        setUpCurrentLocationButton()
    }
    
    
    private func configureSearchView() {
        mapView.addSubview(searchContainerView)
        searchContainerView.addSubview(searchFieldContainer)
        NSLayoutConstraint.activate([
            searchContainerView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 8),
            searchContainerView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -8),
            searchContainerView.bottomAnchor.constraint(equalTo: mapView!.bottomAnchor, constant: -8),
            searchContainerView.heightAnchor.constraint(equalToConstant: 40),
            
            searchFieldContainer.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 16),
            searchFieldContainer.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -16),
            searchFieldContainer.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: -8),
            searchFieldContainer.topAnchor.constraint(equalTo: searchContainerView.topAnchor, constant: 8),
            
        ])
    }
    
    private func setUpCurrentLocationButton() {
        
        currenLocalButton.translatesAutoresizingMaskIntoConstraints = false
        mapView?.addSubview(currenLocalButton)
        NSLayoutConstraint.activate([
            currenLocalButton.trailingAnchor.constraint(equalTo: mapView!.trailingAnchor, constant: -16),
            currenLocalButton.bottomAnchor.constraint(equalTo: searchContainerView.topAnchor, constant: -16),
            currenLocalButton.widthAnchor.constraint(equalToConstant: 30),
            currenLocalButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    @objc func goToSearch() {
        self.viewModel.showSearch.send((x: self.lat, y: self.lng))
    }
    
    func setupInfoBox() {
        infoBox = DestinationInfosView()
        infoBox.translatesAutoresizingMaskIntoConstraints = false
        infoBox.dismissAction = { [weak self] in
            guard let self else { return }
            
            self.hideBottomView()
        }
        infoBox.onMakeRouteTap = { [weak self] in
            guard let self else { return }
            
            self.showRoutesOnMap()
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
    
    func fetchAddressAndUpdateInfoBox(for location: CLLocationCoordinate2D) {
        self.viewModel.getAddress(at: location).receive(on: RunLoop.main)
            .sink { _ in
                print("sink getAddress")
            } receiveValue: { [weak self] address in
                guard let self else { return }
                self.location = location
                self.infoBox.setDestinationName(address.routeName)
                self.infoBox.setDestinationFullAddress(address.formattedAddress)
            }.store(in: &cancellables)
        
        
        
        self.viewModel.getDirectionToDestination(at: location).receive(on: RunLoop.main)
            .sink { _ in
                print("sink getDirectionToDestination")
            } receiveValue: { [weak self] result in
                guard let self else { return }
                
                self.routeLayers?.clear()
                self.routes = result
                for route in result {
                    let duration = route.route.legs?.first?.duration.text
                    self.duration = duration ?? ""
                    let distance = route.route.legs?.first?.distance.text
                    self.infoBox.setDuration(duration: duration, distance: distance)
                }
            } .store(in: &cancellables)
        
    }
    
    func updateMapWithLocation(_ coordinate: CLLocationCoordinate2D) {
        let lngLat = NTLngLat(x: coordinate.longitude, y: coordinate.latitude)
        mapView?.setFocalPointPosition(lngLat, durationSeconds: 0.4)
        mapView?.setZoom(17, durationSeconds: 0.4)
        addMarkerToMap(location: coordinate,
                       icon: UIImage(resource: .currentLocation),
                       id: "userCurrentLocation")
    }
    
    
    func uploadAudioFile() {
        let helper = AudioUploadHelper()
        helper.uploadFile(using: self.getAudioURL(), to: "process") {[weak self] counter in
            guard let self else { return }
            let hours = Int(counter / 3600)
            let minutes = Int((counter.truncatingRemainder(dividingBy: 3600)) / 60)
            let seconds = Int(counter.truncatingRemainder(dividingBy: 60))
            
            let time = String(format: "%02d:%02d", minutes, seconds)
            sheet.updateTimerLabel(with: time)
        } completion: {[weak self] result in
            guard let self else { return }
            switch result {
            case .success(let term):
                guard let term else { return }
                sheet.updateTimerLabel(with: term)
            case .failure(let error):
                print("Upload failed: \(error)")
            }
        }
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
        getCurrentLocation()
    }
    
    func getCurrentLocation() {
        self.markerLayer?.clear()
        self.viewModel.getMyCurrentLocation()
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
    //MARK: - Recording Methods
    
    @objc func recordButtonTapped() {
        showAudioBottomSheet()
    }
    
    func setupRecorder() {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { [weak self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    try? session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                    try? session.setActive(true)
                } else {
                    print("Microphone permission denied")
                }
            }
        }
    }
    
    func configureRecorder() {
        let url = self.getAudioURL()
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: 44100,
            AVNumberOfChannelsKey: 1
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
        } catch {
            print("Failed to initialize recorder: \(error.localizedDescription)")
        }
    }
    
    func startTimer(update: @escaping (String) -> Void) {
        elapsedTime = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1
            let min = Int(self.elapsedTime) / 60
            let sec = Int(self.elapsedTime) % 60
            update(String(format: "%02d:%02d", min, sec))
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func showAudioBottomSheet() {
        sheet.modalPresentationStyle = .pageSheet
        if let sheetController = sheet.sheetPresentationController {
            sheetController.detents = [.medium()]
        }

        configureRecorder()
        audioRecorder?.record()
        isRecording = true
        startTimer { [weak sheet] time in
            sheet?.updateTimerLabel(with: time)
        }
        
        present(sheet, animated: true)
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Finished recording: \(flag)")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }
    
    func playAudio() {
        let url = self.getAudioURL()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.play()
            isPlaying = true
        } catch {
            print("Playback failed: \(error.localizedDescription)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func getAudioURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("audioFile.wav")
    }
}


