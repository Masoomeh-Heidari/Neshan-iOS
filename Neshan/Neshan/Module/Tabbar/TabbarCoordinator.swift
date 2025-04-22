import Foundation
import Combine
import UIKit

struct AppConfig {
    static let baseURL = URL(string: "https://api.neshan.org/v5/")!
    static let apiKey = "service.39681e0622cc4184a1141787b0508dbb"
}

class TabbarCoordinator: BaseCoordinator<Void> {
    
    private let viewControllers: [UINavigationController]
    private let selectedIndex: Int
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    init(using selectedIndex: Int = 4) {
        self.selectedIndex = selectedIndex
        self.viewControllers = TabbarItem.items
            .map({ (items) -> UINavigationController in
                let navigation = UINavigationController()
                navigation.tabBarItem.image = items.icon
                navigation.tabBarItem.selectedImage = items.selectedImage
                navigation.tabBarItem.title = items.title
                let attributes = [NSAttributedString.Key.font:Fonts.iranSansMobile(size: 11).font]
                navigation.tabBarItem.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
                navigation.tabBarItem.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .selected)

                return navigation
            })
    }
    
    override func start() -> AnyPublisher<Void, Never> {
        let viewModel = TabbarViewModel()
        let viewController = TabbarViewController(viewModel: viewModel)
        viewController.tabBar.isTranslucent = false
        viewController.viewControllers = viewControllers
        viewController.selectedIndex = self.selectedIndex
        
        let coordinates: [AnyPublisher<Void, Never>] = viewControllers.enumerated().compactMap { (offset, navController) in
               guard let item = TabbarItem(rawValue: offset) else { return nil }
               
               let coordinator: BaseCoordinator<Void>
               
               switch item {
               case .other, .business, .experience, .pin:
                   coordinator = DemoCoordinator(navigationController: navController)
               case .map:
                   coordinator = MapCoordinator(navigationController: navController)
               }
               
               return coordinate(to: coordinator)
        }
        // Merge all the coordinate publishers and subscribe
        Publishers.MergeMany(coordinates)
            .sink { _ in }
            .store(in: &cancellables)
        
        viewController.setRootViewController()
        
        return Just(()).eraseToAnyPublisher()
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
        return icon
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
