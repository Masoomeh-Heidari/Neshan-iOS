//
//  AppDelegate.swift
//  Neshan
//
//  Created by Fariba on 1/9/1404 AP.
//

import UIKit
import RxSwift
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        IQKeyboardManager.shared.isEnabled = true
        AppCoordinator().start().subscribe().disposed(by: self.disposeBag)
      return true
    }


}

