//
//  MessageCell.swift
//  Chia
//
//  Created by Bohan Wu on 2/26/22.
//

import LBTATools

// MessageCell cutomized the how the message looks like while chatting
class MessageCell: LBTAListCell<Message> {
    
    let textView : UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 20)
        tv.isScrollEnabled = false
        tv.isEditable = false
        return tv
    }()
    
    let bubbleContainer = UIView(backgroundColor: .lightGray)
    
    override var item: Message!{
        didSet{
            
            textView.text = item.text
            
            if item.isFromCurrentLoggedUser {
                anchoredContraints.trailing?.isActive = true
                anchoredContraints.leading?.isActive = false
                bubbleContainer.backgroundColor = #colorLiteral(red: 0.5845660567, green: 0.9253023863, blue: 0.4112785161, alpha: 1)
            }else {
                anchoredContraints.trailing?.isActive = false
                anchoredContraints.leading?.isActive = true
                bubbleContainer.backgroundColor = #colorLiteral(red: 0.9008977413, green: 0.9008975625, blue: 0.9008976221, alpha: 1)

            }
        }
    }
    
    var anchoredContraints: AnchoredConstraints!
    
    // set up how the message buble looks like
    override func setupViews() {
        super.setupViews()
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        
        anchoredContraints = bubbleContainer.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        anchoredContraints.leading?.constant = 20
        anchoredContraints.trailing?.isActive = false
        anchoredContraints.trailing?.constant = -20
        
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        textView.fillSuperview(padding: .init(top: 4, left: 12, bottom: 4, right: 12))
    }
}
