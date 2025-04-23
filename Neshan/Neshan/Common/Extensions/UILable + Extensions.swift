//
//  UILable + Extensions.swift
//  CustomMap
//
//  Created by Bahar on 12/5/1403 AP.
//
import Foundation
import UIKit

extension UILabel {
    convenience init(text: String, font: UIFont?) {
        self.init()
        self.text = text
        self.font = font
        self.numberOfLines = 0
    }
}
