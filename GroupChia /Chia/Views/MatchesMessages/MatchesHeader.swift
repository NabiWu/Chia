//
//  MatchesHeader.swift
//  Chia
//
//  Created by Bohan Wu on 2/26/22.
//

import UIKit

// MathesHeader is the header that shows all like items in the matches and message controller
// Currently, we only show the message cell for now.
class MatchesHeader: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
