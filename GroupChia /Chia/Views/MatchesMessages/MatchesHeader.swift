//
//  MatchesHeader.swift
//  Chia
//
//  Created by Bohan Wu on 2/26/22.
//

import UIKit

class MatchesHeader: UICollectionReusableView {
    
//    let newMatchesLabel = UILabel(text: "Interested Items", font: .boldSystemFont(ofSize: 18), textColor: #colorLiteral(red: 0.9826375842, green: 0.3476698399, blue: 0.447683692, alpha: 1))

//    let matchesHorizontalController = MatchesHorizontalController()
    
//    let messagesLabel = UILabel(text: "Messages", font: .boldSystemFont(ofSize: 18), textColor: #colorLiteral(red: 0.9826375842, green: 0.3476698399, blue: 0.447683692, alpha: 1))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//
//        stack(
////            stack(newMatchesLabel).padLeft(20),
////              matchesHorizontalController.view,
//              stack(messagesLabel).padLeft(50),
//              spacing: 0).withMargins(.init(top: 10, left: 0, bottom: 5, right: 0))
        
        
//            stack(newMatchesLabel).padLeft(20),
//              matchesHorizontalController.view,
//              stack(messagesLabel).padLeft(50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
