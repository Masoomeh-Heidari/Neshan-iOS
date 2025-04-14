//
//  String + Extensions.swift
//  CustomMap
//
//  Created by Bahar on 12/5/1403 AP.
//
import UIKit

extension String {

    func localized(withComment comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? "")
    }
}
