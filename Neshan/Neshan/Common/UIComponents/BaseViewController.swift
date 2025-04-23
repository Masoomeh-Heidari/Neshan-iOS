//
//  BaseViewController.swift
//  CustomMap
//
//  Created by Bahar on 12/5/1403 AP.
//

import Foundation
import UIKit

//TODO: Consider using this BaseViewController for inheritance to promote consistency in the code and reduce repetition.

class BaseViewController<ViewModel>: UIViewController, ViewModelBindable {
        
    typealias ViewModelType = ViewModel

    var viewModel: ViewModel?
    
    deinit {
        viewModel = nil
    }
    
    required init(viewModel: ViewModel? = nil) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bindViewModel() {
        
    }
    
    func presentAlert(with message: String, title: String = "Error") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            alertController.dismiss(animated: true)
        }))
        present(alertController, animated: true)
    }
}

