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
    let imageNames: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.imageNames = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    fileprivate var imageIndex = 0 {
        didSet{
            let imageUrl = imageNames[imageIndex]
//            let image = UIImage(named: imageNmae)
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }
    
    // reactive programming
    var imageIndexObserver: ((Int, String?) -> ())?
    
    func advanceToNextPhoto(){
        imageIndex = min( imageIndex + 1, imageNames.count - 1)
    }
    
    func goToPreviousPhoto(){
        imageIndex = max(0, imageIndex - 1)
    }
    
}

