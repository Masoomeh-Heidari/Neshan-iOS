//
//  SplashScreen.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import UIKit

class SplashScreen: UIViewController {

    let viewModel: SplashViewModel
    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.goToTabbar.onNext(())
    }
}
