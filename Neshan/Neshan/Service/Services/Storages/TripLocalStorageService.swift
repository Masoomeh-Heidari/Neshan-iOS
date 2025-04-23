//
//  TripLocalStorageService.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//


struct TripModel: Codable {
    var id: Int
    var title: String
    var address: String?
    var contacts: [TripContact]
    var lat: Double
    var lng: Double

}

struct TripContact: Codable {
    var name: String
    var phone: String
}

final class TripLocalStorageService: LocalStorageBaseService<TripModel> {
    
    typealias StorageType = TripModel
    
    
    override func save(_ value: TripModel) {
        loadAll { trips in
            var trips = trips
            trips.append(value)
            UserDefaults.standard.set(try? JSONEncoder().encode(trips), forKey: "trips")
            UserDefaults.standard.synchronize()
        }
    }
    
    override func loadAll(completion: @escaping ([TripModel]) -> Void) {
        guard let data = UserDefaults.standard.value(forKey: "trips") as? Data,
              let models = try? JSONDecoder().decode([TripModel].self, from: data) else {
            completion([])
            return
        }
        completion(models)
    }
    
    override func load(id: Int, completion: @escaping (TripModel?) -> Void) {
        loadAll { models in
            guard let model = models.first(where: { $0.id == id }) else {
                completion(nil)
                return
            }
            completion(model)
        }
    }
    
}
