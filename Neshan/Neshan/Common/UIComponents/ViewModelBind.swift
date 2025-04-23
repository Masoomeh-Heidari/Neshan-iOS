//
//  ViewModelBind.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//
import UIKit

protocol ViewModelBindable: AnyObject {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType? { get set }
    
    func bindViewModel()
}

extension ViewModelBindable where Self: UIViewController {
    func bind(to model: Self.ViewModelType) {
        viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}
extension ViewModelBindable where Self: UIView {
    func bind(to model: Self.ViewModelType) {
        viewModel = model
        bindViewModel()
    }
}
extension ViewModelBindable where Self: UITableViewCell {
    func bind(to model: Self.ViewModelType) {
        viewModel = model
        bindViewModel()
    }
}
extension ViewModelBindable where Self: UICollectionViewCell {
    func bind(to model: Self.ViewModelType) {
        viewModel = model
        bindViewModel()
    }
}
