//
//  Fonts.swift
//  CustomMap
//
//  Created by Bahar on 9/27/1403 AP.
//

import Foundation
import UIKit


enum Fonts {
    case robotoBlack(size: CGFloat)
    case robotoBlackItalic(size: CGFloat)
    case robotoBold(size: CGFloat)
    case robotoBoldItalic(size: CGFloat)
    case robotoItalic(size: CGFloat)
    case robotoLight(size: CGFloat)
    case robotoLightItalic(size: CGFloat)
    case robotoMedium(size: CGFloat)
    case robotoMediumItalic(size: CGFloat)
    case robotoRegular(size: CGFloat)
    case iranSansMobile(size: CGFloat)
    case iranSansMobileBold(size: CGFloat)
    
    var fontName: String {
        switch self {
        case .robotoBlack:
            return "Roboto-Black"
        case .robotoBlackItalic:
            return "Roboto-BlackItalic"
        case .robotoBold:
            return "Roboto-Bold"
        case .robotoBoldItalic:
            return "Roboto-BoldItalic"
        case .robotoItalic:
            return "Roboto-Italic"
        case .robotoLight:
            return "Roboto-Light"
        case .robotoLightItalic:
            return "Roboto-LightItalic"
        case .robotoMedium:
            return "Roboto-Medium"
        case .robotoMediumItalic:
            return "Roboto-MediumItalic"
        case .robotoRegular:
            return "Roboto-Regular"
        case.iranSansMobile:
            return "IRANSansMobile"
        case.iranSansMobileBold:
            return "IRANSansMobile-Bold"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .robotoBlack(let size),
             .robotoBlackItalic(let size),
             .robotoBold(let size),
             .robotoBoldItalic(let size),
             .robotoItalic(let size),
             .robotoLight(let size),
             .robotoLightItalic(let size),
             .robotoMedium(let size),
             .robotoMediumItalic(let size),
             .robotoRegular(let size),
            .iranSansMobile(let size),
            .iranSansMobileBold(let size):
            return size
        }
    }
    
    var font: UIFont? {
        return UIFont(name: self.fontName, size: self.size)
    }
}
