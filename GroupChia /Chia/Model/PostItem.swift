//
//  PostItem.swift
//  Chia
//
//  Created by Chen Yu on 2022/2/25.
//

import UIKit

struct PostItem: ProducesCardViewModel {
    var name: String?
    var description: String?
    var price: Int?
    var uid: String?
    var ownerUid: String?
    var ownerName: String?
    
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    
    init(dictionary: [String: Any]){
        
        self.price = dictionary["price"] as? Int
        self.name = dictionary["name"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.ownerName = dictionary["ownerName"] as? String ?? ""
        
        self.imageUrl1 = dictionary["imageUrl1"] as? String
        self.imageUrl2 = dictionary["imageUrl2"] as? String
        self.imageUrl3 = dictionary["imageUrl3"] as? String
    }
    
    
    func toCardViewModel() -> CardViewModel {
        let attributedText = NSMutableAttributedString(string: name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])

        let priceString = price != nil ? "\(price!)" : "N\\A"

        attributedText.append(NSAttributedString(string: "  \(priceString)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))

        let ownerName = ownerName != nil ? "\(ownerName!)" : "unkown user"

        attributedText.append(NSAttributedString(string: "\n\(ownerName)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        let discriptionString = NSAttributedString(string: description ?? "")

        var imageUrls = [String]()
        if let url = imageUrl1 {if url != "" {imageUrls.append(url)}}
        if let url = imageUrl2 {if url != "" {imageUrls.append(url)}}
        if let url = imageUrl3 {if url != "" {imageUrls.append(url)}}
        return CardViewModel(uid: self.uid ?? "", ownerUID: self.ownerUid ?? "" ,imageNames: imageUrls, attributedString: attributedText, textAlignment: .left, discriptionString: discriptionString)
    }
}
