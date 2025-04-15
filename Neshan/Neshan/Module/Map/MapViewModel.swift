
import Foundation
import Combine

class MapViewModel: ObservableObject {
    let userLocation = PassthroughSubject<(x: Double, y: Double), Never>()
    let hideExplore = PassthroughSubject<Void, Never>()
    let showSearch = PassthroughSubject<(x: Double, y: Double), Never>()
    let showSearchResult = PassthroughSubject<Bool, Never>()
    let showSearchBox = PassthroughSubject<(term: String, selectedItem: SearchItemDto, result: [SearchItemDto]), Never>()
}
