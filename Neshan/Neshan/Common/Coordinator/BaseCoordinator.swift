import Combine
import Foundation

protocol BaseCoordinatorProtocol {
    associatedtype ResultType
}

class BaseCoordinator<ResultType>: BaseCoordinatorProtocol {
    
    typealias CoordinationResult = ResultType
    
    var cancellables = Set<AnyCancellable>()

    private let _identifier = UUID()
    var identifier: UUID { _identifier }
    
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
        fatalError("Subclasses must override this")
    }
}
