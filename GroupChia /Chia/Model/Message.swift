//
//  Message.swift
//  Chia
//
//  Created by Bohan Wu on 2/26/22.
//

import Firebase

// the message object contains all need information
struct Message{
    let text, fromId, toId: String
    let timestamp: Timestamp
    let isFromCurrentLoggedUser: Bool
    
    init(dictionary: [String:Any]){
        self.text = dictionary["text"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.toId = dictionary["toId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
        self.isFromCurrentLoggedUser = Auth.auth().currentUser?.uid == self.fromId
    }
}
