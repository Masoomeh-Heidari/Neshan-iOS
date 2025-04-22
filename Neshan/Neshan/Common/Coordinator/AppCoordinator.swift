import Combine

class AppCoordinator: BaseCoordinator<Void> {
        
    override func start() -> AnyPublisher<Void, Never> {
        coordinate(to: SplashCoordinator())
            .sink { _ in }
            .store(in: &cancellables)
        
        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }
}
