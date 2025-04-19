import Combine
import Foundation

protocol BaseCoordinatorProtocol {
    associatedtype ResultType
}

class BaseCoordinator<ResultType>: BaseCoordinatorProtocol {
    
    typealias CoordinationResult = ResultType
    
    // Use a Set of Cancellable to store Combine subscriptions
    var cancellables = Set<AnyCancellable>()
    
    private let identifier = UUID()
    private var childCoordinators = [UUID: Any]()
    
    private func store<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }
    
    private func free<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }
    
    func coordinate<T>(to coordinator: BaseCoordinator<T>) -> AnyPublisher<T, Never> {
        store(coordinator: coordinator)
        return coordinator.start()
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.free(coordinator: coordinator)
            })
            .eraseToAnyPublisher()
    }
    
    func start() -> AnyPublisher<ResultType, Never> {
        fatalError("Start method should be implemented.")
    }
}
