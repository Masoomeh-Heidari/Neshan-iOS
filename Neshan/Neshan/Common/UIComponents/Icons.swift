//
//  Icons.swift
//  CustomMap
//
//  Created by Bahar on 9/27/1403 AP.
//

import Foundation
import UIKit

struct Icons {
    
    static let back = UIImage(named: "back")
    static let chevron =  UIImage(named: "chevron")
    static let close =  UIImage(named: "close")
 
 
    static func icon(named name: String) -> UIImage? {
        return UIImage(named: name)
    }
}
