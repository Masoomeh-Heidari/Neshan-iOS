//
//  ExploreScreen.swift
//  Neshan
//
//  Created by Fariba on 1/17/1404 AP.
//

import UIKit

class ExploreScreen: UIViewController {
    let viewModel: ExploreViewModel
    
    @IBOutlet weak var searchView: UIView!
    
    init(viewModel: ExploreViewModel) {
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

    fileprivate func setupUI() {
        self.searchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.goToSearch)))
    }
    
    @objc func goToSearch() {
        self.viewModel.goToSearch.onNext((x: self.viewModel.lat, y: self.viewModel.lng))
    }
}
