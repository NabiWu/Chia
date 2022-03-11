//
//  MessagesNavBar.swift
//  Chia
//
//  Created by Bohan Wu on 2/26/22.
//

import LBTATools

// MessagesNavBar contains the navigation bar in realtime message view
class MessagesNavBar: UIView {
    
    let userProfileImageView = CircularImageView(width: 44, image: UIImage(named: "jane1"))
    let nameLabel = UILabel(text: "username", font: .systemFont(ofSize: 16))
    let backButton = UIButton(image: UIImage(named: "back")!, tintColor: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
    let flagButton = UIButton(image: UIImage(named: "flag")!, tintColor: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
    
    fileprivate let match: Match
    
    init(match: Match){
        self.match = match
        
        nameLabel.text = match.name
        userProfileImageView.sd_setImage(with: URL(string: match.profileImageUrl))
        
        super.init(frame: .zero)
        backgroundColor = .white
        
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))

        let middleStack = hstack(
            stack(
                userProfileImageView,
                nameLabel,
                spacing: 8,
                alignment: .center),
            alignment: .center
        )
        
        hstack(
            backButton.withWidth(50),
            middleStack,
            flagButton
        ).withMargins(.init(top: 0, left: 4, bottom: 0, right: 12))
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
