//
//  TopNavigationStackView.swift
//  Chia
//
//  Created by Bohan Wu on 2/19/22.
//

import UIKit

// A StackView contains two buttons shown on the top of the home screen
// Users can navigate to other screen by clicking either of those buttons
class TopNavigationStackView: UIStackView {

    let settingsButton = UIButton(type: .system)
    let messageButton = UIButton(type: .system)
    let fireImageView = UIImageView(image: UIImage(named: "TopIcon"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        fireImageView.contentMode = .scaleAspectFit
        
        settingsButton.setImage(UIImage(systemName: "signature")!.withRenderingMode(.alwaysOriginal), for: .normal)
        messageButton.setImage(UIImage(systemName: "hare")!.withRenderingMode(.alwaysOriginal), for: .normal)
        
        [settingsButton, UIView(), fireImageView, UIView(), messageButton].forEach { (v) in
            addArrangedSubview(v)
        }
        
        distribution = .equalCentering
        
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }

}
