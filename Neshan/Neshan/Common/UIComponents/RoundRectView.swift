//
//  RoundRectView.swift
//  CustomMap
//
//  Created by Bahar on 9/28/1403 AP.
//

import Foundation
import UIKit

@IBDesignable
public class RoundRectView: UIView {
    
    public override var frame: CGRect {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var _backgroundColor: UIColor?
    
    public override var backgroundColor: UIColor? {
        get {
            self._backgroundColor
        }
        
        set {
            super.backgroundColor = .clear
            self._backgroundColor = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var roundingCorners: UIRectCorner = .allCorners {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        let pathRect = rect
        let path = UIBezierPath(roundedRect: pathRect, byRoundingCorners: roundingCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        backgroundColor?.setFill()
        path.fill()
    }
    
    public override func didMoveToSuperview() {
        self.setNeedsDisplay()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
}
