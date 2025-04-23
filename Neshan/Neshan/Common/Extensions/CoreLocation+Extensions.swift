//
//  CoreLocation+Extensions.swift
//  CustomMap
//
//  Created by Bahar on 12/6/1403 AP.
//

import CoreLocation

extension CLLocationCoordinate2D {
    
    static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    static func != (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return !(lhs == rhs)
    }
}
