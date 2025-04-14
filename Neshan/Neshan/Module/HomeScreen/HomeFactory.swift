//
//  HomeFactory.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//
import UIKit

protocol HomeFactory {
    
    func makeHomeViewController() -> HomeScreenViewController
    
    func makeHomeViewModel() -> HomeScreenViewModel
    
    func makeHomeCoordinator(with root: UINavigationController) -> HomeCoordinator
    
}
