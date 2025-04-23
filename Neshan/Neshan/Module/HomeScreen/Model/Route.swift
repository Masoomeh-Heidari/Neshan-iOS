//
//  Route.swift
//  CustomMap
//
//  Created by Bahar on 1/19/1404 AP.
//

import Foundation

struct Route: Codable {
    let overview_polyline: Overview_polyline?
    let legs: [Leg]?
    
    // MARK: - OverviewPolyline
    struct Overview_polyline: Codable {
        let points: String
    }
    
    // MARK: - Leg
    struct Leg: Codable {
        let summary: String
        let distance: Distance
        let duration: Duration
        let steps: [Step]?
        
        // MARK: - Distance
        struct Distance: Codable {
            let value: Double
            let text: String
        }
        
        // MARK: - Duration
        struct Duration: Codable {
            let value: Double
            let text: String
        }
        
        // MARK: - Step
        struct Step: Codable {
            let name: String?
            let instruction: String?
            let bearingAfter: Int?
            let type: String?
            let modifier: String?
            let distance: Distance?
            let duration: Duration?
            let polyline: String?
            let startLocation: [Double]?
            let exit: Int?
        }
    }
}

