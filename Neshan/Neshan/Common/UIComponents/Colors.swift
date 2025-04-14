//
//  Colors.swift
//  CustomMap
//
//  Created by Bahar on 9/27/1403 AP.
//

import UIKit

struct Colors {
    private static func dynamicColor(light: String, dark: String) -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        }
    }
    
    static let primaryColor         = dynamicColor(light: "#3498db", dark: "#2980b9")
    static let secondaryColor       = dynamicColor(light: "#2ecc71", dark: "#27ae60")
    static let backgroundColor      = dynamicColor(light: "#F7F7F7", dark: "#1E1E1E")
    static let surfaceColor         = dynamicColor(light: "#FFFFFF", dark: "#2C2C2C")
    static let textColor            = dynamicColor(light: "#2c3e50", dark: "#ECF0F1")
    static let lineColor            = dynamicColor(light: "#CFD8DC", dark: "#4A4A4A")
    static let placeholderColor     = dynamicColor(light: "#78909C", dark: "#90A4AE")
    static let successColor         = dynamicColor(light: "#00B88D", dark: "#00A478")
    static let errorColor           = dynamicColor(light: "#FF3B30", dark: "#E53935")
    static let warningColor         = dynamicColor(light: "#FF9800", dark: "#F57C00")
    static let darkBackgroundColor  = dynamicColor(light: "#323232", dark: "#121212")
    static let actionColor          = dynamicColor(light: "#0096EB", dark: "#1B82C3")
    static let pageControllerColor  = dynamicColor(light: "#65676a", dark: "#808080")
    

    static func color(from hex: String) -> UIColor {
        return UIColor(hex: hex)
    }
}
