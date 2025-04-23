//
//  LocalStorageService.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//

protocol LocalStorageService: AnyObject {
    
    associatedtype StorageType: Codable
    
    func save(_ value: StorageType)
    
    func loadAll(completion: @escaping ([StorageType]) -> Void)
    
    func load(id: Int, completion: @escaping (StorageType?) -> Void)
    
}


class LocalStorageBaseService<T: Codable>: LocalStorageService {
    typealias StorageType = T
    
    func save(_ value: T) {
        fatalError("Override this method")
    }
    
    func loadAll(completion: @escaping ([T]) -> Void) {
        fatalError("Override this method")
    }
    
    func load(id: Int, completion: @escaping (T?) -> Void) {
        fatalError("Override this method")
    }
    
    
    
    
    
}
