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
    
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    
    func toCardViewModel() -> CardViewModel {
        let attributedString = NSMutableAttributedString(string: description ?? "", attributes: [.font: UIFont.systemFont(ofSize: 34, weight: .heavy)])
        
        attributedString.append(NSAttributedString(string: "\n" + String(price ?? 0), attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .bold)]))
        let discriptionString = NSAttributedString(string: "")
        
        return CardViewModel(uid: "", imageNames: ["name"], attributedString: attributedString, textAlignment: .center, discriptionString: discriptionString)
    }
}
