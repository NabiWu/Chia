//
//  MatchesNowBar.swift
//  Chia
//
//  Created by Bohan Wu on 2/25/22.
//

import UIKit
import LBTATools


// MatchesNavBar setup the ui for messageView
class MatchesNavBar: UIView {
    
    let backButton = UIButton(image: UIImage(named: "TopIcon")!, tintColor: .lightGray)
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let iconImageView = UIImageView(image: UIImage(systemName: "hare")!.withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        iconImageView.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        let messagesLable = UILabel(text: "Messages", font: .boldSystemFont(ofSize: 20), textColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), textAlignment: .center)
        let feedLable = UILabel(text: "Feed", font: .boldSystemFont(ofSize: 20), textColor: .gray, textAlignment: .center)
        
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        stack(iconImageView.withHeight(40), hstack(messagesLable, feedLable, distribution: .fillEqually)).padTop(10)
        
        
        addSubview(backButton)
        backButton.anchor(top: safeAreaLayoutGuide.topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 12, bottom: 0, right: 0), size: .init(width: 34, height: 34))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
