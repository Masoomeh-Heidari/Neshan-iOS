//
//  UIImageView + Extensions.swift
//  CustomMap
//
//  Created by Bahar on 12/5/1403 AP.
//

import Foundation
import UIKit

extension UIImageView {
    convenience init(icon: UIImage?) {
        self.init(image: icon)
        self.contentMode = .scaleAspectFit
    }
}
