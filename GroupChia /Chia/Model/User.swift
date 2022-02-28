//
//  User.swift
//  Chia
//
//  Created by Bohan Wu on 2/19/22.
//

import UIKit

struct User: ProducesCardViewModel{
    var name: String?
    var age: Int?
    var profession: String?
//    let imageNames: [String]
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    var uid: String?
    var bio: String?
    
    var minSeekingPrice: Int?
    var maxSeekingPrice: Int?

    init(dictionary: [String: Any]){
        
        self.age = dictionary["age"] as? Int
        self.profession = dictionary["profession"] as? String
        self.name = dictionary["fullName"] as? String ?? ""
        self.imageUrl1 = dictionary["imageUrl1"] as? String
        self.imageUrl2 = dictionary["imageUrl2"] as? String
        self.imageUrl3 = dictionary["imageUrl3"] as? String
        self.uid = dictionary["uid"] as? String ?? ""
        self.minSeekingPrice = dictionary["minSeekingPrice"] as? Int
        self.maxSeekingPrice = dictionary["maxSeekingPrice"] as? Int
        self.bio = dictionary["bio"] as? String ?? ""
    }
    
    func toCardViewModel() -> CardViewModel {
        let attributedText = NSMutableAttributedString(string: name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        
        let ageString = age != nil ? "\(age!)" : "N\\A"
        
        attributedText.append(NSAttributedString(string: "  \(ageString)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        
        let professionString = profession != nil ? "\(profession!)" : "Not available"
        
        attributedText.append(NSAttributedString(string: "\n\(professionString)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        let discriptionString = NSAttributedString(string: bio ?? "")
        
        var imageUrls = [String]()
        if let url = imageUrl1 {if url != "" {imageUrls.append(url)}}
        if let url = imageUrl2 {if url != "" {imageUrls.append(url)}}
        if let url = imageUrl3 {if url != "" {imageUrls.append(url)}}
        return CardViewModel(uid: self.uid ?? "",imageNames: imageUrls, attributedString: attributedText, textAlignment: .left, discriptionString: discriptionString)
    }
}

