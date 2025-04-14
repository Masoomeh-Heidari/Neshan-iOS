//
//  MapEventListener.swift
//  CustomMap
//
//  Created by Bahar on 12/7/1403 AP.
//

import CoreLocation

class MapEventListener: NTMapEventListener {
    
    var onMapTap: ((CLLocationCoordinate2D) -> Void)?
    var onMapMoved: (() -> Void)?
    
    
    override func onMapClicked(_ tapInfo: NTClickData!) {
        guard let position = tapInfo.getClickPos() else {
            return
        }
        switch tapInfo.getClickType() {
        case .CLICK_TYPE_SINGLE:
            onMapTap?(CLLocationCoordinate2D(latitude: position.getY(), longitude: position.getX()))
        default:
            break
        }
    }
    
    func onMapMove() {
        onMapMoved?()
    }
}
