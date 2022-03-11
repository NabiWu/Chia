//
//  CardViewModel.swift
//  Chia
//
//  Created by Bohan Wu on 2/19/22.
//


import UIKit

// protocol for Model
protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {
    // we'll define the properties that are view will display/render out
    let uid: String
    let ownerUID: String
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let discriptionString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(uid: String, ownerUID: String, imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment, discriptionString: NSAttributedString) {
        self.uid = uid
        self.ownerUID = ownerUID
        self.imageUrls = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
        self.discriptionString = discriptionString
    }
    
    fileprivate var imageIndex = 0 {
        didSet{
            let imageUrl = imageUrls[imageIndex]
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }
    
    // reactive programming
    var imageIndexObserver: ((Int, String?) -> ())?
    
    // change the imageIndex by 1
    func advanceToNextPhoto(){
        imageIndex = min( imageIndex + 1, imageUrls.count - 1)
    }
    
    // change the imageIndex by -1
    func goToPreviousPhoto(){
        imageIndex = max(0, imageIndex - 1)
    }
    
}

