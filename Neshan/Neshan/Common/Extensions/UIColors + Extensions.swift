//
//  Colors + Extensions.swift
//  CustomMap
//
//  Created by Bahar on 12/5/1403 AP.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 {
            self.init(white: 0.5, alpha: 1.0)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    
    static func getRandomRGBColor() -> UIColor {
        // Generate random values for Red, Green, Blue components
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        
        // Return the color using the generated RGB values
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func getRGBValues() -> (red: UInt8, green: UInt8, blue: UInt8) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Use the getRed method to extract the color components
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (UInt8(red * 255),
                    UInt8(green * 255),
                    UInt8(blue * 255)) // Return RGB values
        } else {
            return (0,0,0) // If the color can't be converted to RGB, return nil
        }
    }
}
