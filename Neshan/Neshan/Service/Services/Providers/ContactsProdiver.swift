//
//  ContactsProdiver.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//

import Foundation
import Contacts


final class ContactsProvider {
    
    
    func requestAccess(_ requestGranted: @escaping (Bool) -> Void) {
        CNContactStore().requestAccess(for: .contacts) { (granted, error) in
            requestGranted(granted)
        }
    }
    
    func authorizationStatus(_ requestStatus: @escaping (CNAuthorizationStatus) -> Void) {
        requestStatus(CNContactStore.authorizationStatus(for: .contacts))
    }
    
    func fetchContacts(completionHandler : @escaping (_ result : Result<[CNContact], Error>) -> Void){
        
        DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey] as [Any]
            let fetchRequest = CNContactFetchRequest( keysToFetch: keysToFetch as! [CNKeyDescriptor])
            var contacts = [CNContact]()
            CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone)
            if #available(iOS 10.0, *) {
                fetchRequest.mutableObjects = false
            } else {
                // Fallback on earlier versions
            }
            fetchRequest.unifyResults = true
            fetchRequest.sortOrder = .userDefault
            do {
                try CNContactStore().enumerateContacts(with: fetchRequest) { (contact, stop) -> Void in
                    contacts.append(contact)
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    completionHandler(.success(contacts))
                })
            } catch let error as NSError {
                completionHandler(.failure(error))
            }
            
        })
        
    }
    
}
