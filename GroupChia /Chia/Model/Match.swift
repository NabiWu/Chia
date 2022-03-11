//
//  Match.swift
//  Chia
//
//  Created by Bohan Wu on 2/26/22.
//

import Foundation

// Data model that will be stored on the firebase
struct Match {
    let name, profileImageUrl, uid: String
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
