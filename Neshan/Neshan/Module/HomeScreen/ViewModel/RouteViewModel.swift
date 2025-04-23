//
//  RouteViewModel.swift
//  CustomMap
//
//  Created by Bahar on 1/19/1404 AP.
//
import UIKit
import Foundation
import CoreLocation

struct RouteViewModel {
    
    var coordinates: [CLLocationCoordinate2D] = []
    var route : Route
    var color = UIColor.getRandomRGBColor()
    
    init(route: Route) {
        self.route = route
        convertPolylinesToCoordinates()
    }
    
    private mutating func convertPolylinesToCoordinates() {
        
        let steps = route.legs?.flatMap { leg in
            leg.steps
        }.flatMap { $0 }
        
        guard let allSteps = steps else { return }
        
        let allDecodedCoordinates: [CLLocationCoordinate2D] = allSteps.compactMap { step in
            if let polyline = step.polyline {
                let decodedPolylines = Polyline(encodedPolyline: polyline)
                
                return decodedPolylines.coordinates?.compactMap {$0}
            } else {
                print("No polyline available for this step")
                return nil
            }
        }.flatMap { $0 }
        
        self.coordinates = allDecodedCoordinates
    }
}
