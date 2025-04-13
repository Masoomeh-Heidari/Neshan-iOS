//
//  TabbarViewController.swift
//  WePod
//
//  Created by Fariba on 6/12/1401 AP.
//  Copyright © 1401 AP Dotin. All rights reserved.
//

import UIKit

class TabbarViewController: UITabBarController {
    typealias ViewModelType = TabbarViewModel

    var viewModel: TabbarViewModel!
    
    init(viewModel: ViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        self.tabBar.tintColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        self.tabBar.backgroundColor = .white
    }
}

