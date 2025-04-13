//
//  ViewController+Extension.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import Foundation
import UIKit

extension UIViewController {
    public func setRootViewController(hideBar: Bool = true) {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            window.backgroundColor = .white
            let nav = UINavigationController(rootViewController: self)
            nav.navigationBar.isHidden = hideBar
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
