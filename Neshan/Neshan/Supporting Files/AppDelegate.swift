//
//  AppDelegate.swift
//  Neshan
//
//  Created by Fariba on 1/9/1404 AP.
//

import UIKit
import Combine
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private var cancellables = Set<AnyCancellable>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        IQKeyboardManager.shared.isEnabled = true
        
        AppCoordinator()
                  .start()
                  .sink { _ in }
                  .store(in: &cancellables)
      return true
    }

}

