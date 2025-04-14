//
//  ContactViewModel.swift
//  CustomMap
//
//  Created by Bahar on 12/8/1403 AP.
//

import Contacts


class ContactViewModel {
    
    var image: UIImage? {
        let initials = "\(contact.givenName.first.map(String.init) ?? "")\(contact.familyName.first.map(String.init) ?? "")"
        guard let imageData = contact.thumbnailImageData else {
            return generatePlaceholderImage(with: initials, size: .init(width: 50, height: 50))
        }
        return UIImage(data: imageData)
    }
    
    var contact: CNContact
    var isSelected: Bool = false
    
    init(contact: CNContact) {
        self.contact = contact
    }
    
    func generatePlaceholderImage(with initials: String,
                                  size: CGSize = CGSize(width: 60, height: 60)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // Set a background color (optional)
        UIColor.lightGray.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 24)
        ]
        
        let textSize = initials.size(withAttributes: attributes)
        let rect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        initials.draw(in: rect, withAttributes: attributes)
        

        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }

}
