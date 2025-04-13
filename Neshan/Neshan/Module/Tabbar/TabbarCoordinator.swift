//
//  TabbarCoordinator.swift
//  WePod
//
//  Created by Fariba on 6/12/1401 AP.
//  Copyright © 1401 AP Dotin. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class TabbarCoordinator: BaseCoordinator<Void> {
    
    private let viewControllers: [UINavigationController]
    private let selectedIndex: Int
    
    init(using selectedIndex: Int = 4) {
        self.selectedIndex = selectedIndex
        self.viewControllers = TabbarItem.items
            .map({ (items) -> UINavigationController in
                let navigation = UINavigationController()
                navigation.tabBarItem.image = items.icon
                navigation.tabBarItem.selectedImage = items.selectedImage
                navigation.tabBarItem.title = items.title
                return navigation
            })
    }
    
    override func start() -> Observable<Void> {
        let viewModel = TabbarViewModel()
        let viewController = TabbarViewController(viewModel: viewModel)
        viewController.tabBar.isTranslucent = false
        viewController.viewControllers = viewControllers
        viewController.selectedIndex = self.selectedIndex
        let coordinates = viewControllers.enumerated()
            .map { (offset, element) -> Observable<Void> in
                guard let items = TabbarItem(rawValue: offset) else { return Observable.just(() )}
                switch items {
                case .other:
                    return coordinate(to: DemoCoordinator(navigationController: element))
                case .business:
                    return coordinate(to: DemoCoordinator(navigationController: element))
                case .experience:
                    return coordinate(to: DemoCoordinator(navigationController: element))
                case .pin:
                    return coordinate(to: DemoCoordinator(navigationController: element))
                case .map:
                    return coordinate(to: MapCoordinator(navigationController: element))
                }
            }
                                    
        Observable.merge(coordinates)
            .subscribe()
            .disposed(by: disposeBag)
        
        viewController.setRootViewController()
        return Observable.never()
    }
}

enum TabbarItem: Int {
    case other
    case business
    case experience
    case pin
    case map

    
    var icon: UIImage? {
        switch self {
        case .other:
            return UIImage(systemName: "line.3.horizontal")
        case .business:
            return UIImage(systemName: "house")
        case .experience:
            return UIImage(systemName: "bubble.right")
        case .pin:
            return UIImage(systemName: "bookmark")
        case .map:
            return UIImage(systemName: "map")
        }
    }
    
    var selectedImage: UIImage? {
        switch self {
        case .other:
            return UIImage(systemName: "line.3.horizontal")
        case .business:
            return UIImage(systemName: "house")
        case .experience:
            return UIImage(systemName: "bubble.right")
        case .pin:
            return UIImage(systemName: "bookmark")
        case .map:
            return UIImage(systemName: "map")
        }
    }
    
    var title: String {
        switch self {
        case .other:
            return "سایر"
        case .business:
            return "کسب‌وکار"
        case .experience:
            return "تجربه‌ها"
        case .pin:
            return "ذخیره‌ها"
        case .map:
            return "نقشه"
        }
    }
    
    func pageOrderNumber() -> Int {
        switch self {
        case .other:
            return 0
        case .business:
            return 1
        case .experience:
            return 2
        case .pin:
            return 3
        case .map:
             return 4
        }
    }
}


extension RawRepresentable where RawValue == Int {
    
    static var itemCount: Int {
        var index = 0
        while Self(rawValue: index) != nil {
            index += 1
        }
        
        return index
    }
    
    static var items: [Self] {
        var items = [Self]()
        var index = 0
        while let item = Self(rawValue: index) {
            items.append(item)
            index += 1
        }
        
        return items
    }
}
