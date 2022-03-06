//
//  MatchView.swift
//  Chia
//
//  Created by Bohan Wu on 2/24/22.
//

import UIKit
import grpc
import Firebase

class MatchView: UIView {
    weak var rootMatchesController: MatchesMessagesController?
    
    var currentUser: User!{
        didSet {
            
        }
    }
    
    var cardUID: String! {
        didSet {
            
            
            let query = Firestore.firestore().collection("users")
            query.document(cardUID).getDocument { snapshot, err in
                if let err = err {
                    print("Failed to fetch card user:", err)
                    return
                }
                
                guard let dictionary = snapshot?.data() else {return}
                let user = User(dictionary: dictionary)
                guard let url = URL(string: user.imageUrl1 ?? "") else {return}
                self.cardUserImageView.sd_setImage(with: url)
                
                guard let currentUserImageUrl = URL(string: self.currentUser.imageUrl1 ?? "") else {return}
                self.currentUserImageView.sd_setImage(with: currentUserImageUrl) { _, _, _, _ in
                    self.setupAnimation()
                }
            }
            
        }
    }
    
    
    
    fileprivate let itsAMatchImageView : UIImageView = {
       let iv = UIImageView(image: UIImage(named: "itsamatch"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Congrats, an intererested message has been sent"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate let currentUserImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "jane1"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    fileprivate let cardUserImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "jane2"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.alpha = 0
        return imageView
    }()
    
//    fileprivate let sendMessageButton: UIButton = {
//        let button = SendMessageButton(type: .system)
//        button.setTitle("CONTINUE CHAT", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.addTarget(self, action: #selector(handleChat), for: .touchUpInside)
//        return button
//    }()
    
    fileprivate let keepSwipingButton: UIButton = {
        let button = KeepSwipingButton(type: .system)
        button.setTitle("Keep Swiping", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleTapDismiss), for: .touchUpInside)
        return button
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlurView()
        setupLayout()
//        setupAnimation()
    }
    
    fileprivate func setupAnimation(){
        views.forEach({$0.alpha = 1})
        
        let angle = 30 * CGFloat.pi / 180
        
        currentUserImageView.transform = CGAffineTransform(rotationAngle:       -angle).concatenating(CGAffineTransform(translationX: 200, y: 0))
        
        cardUserImageView.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: -200, y: 0))
        
//        sendMessageButton.transform = CGAffineTransform(translationX: -500, y: 0)
        keepSwipingButton.transform = CGAffineTransform(translationX: 500, y: 0)
        
        UIView.animateKeyframes(withDuration: 1.3, delay: 0, options: .calculationModeCubic) {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45) {
                self.currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
                self.cardUserImageView.transform = CGAffineTransform(rotationAngle: angle)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                self.currentUserImageView.transform = .identity
                self.cardUserImageView.transform = .identity
      
            }
        } completion: { _ in
        }

        UIView.animate(withDuration: 0.75, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut) {
//            self.sendMessageButton.transform = .identity
            self.keepSwipingButton.transform = .identity
        } completion: { _ in
        }

    }
    
    lazy var views = [
        itsAMatchImageView,
        descriptionLabel,
        currentUserImageView,
        cardUserImageView,
//        sendMessageButton,
        self.keepSwipingButton,
    ]
    
    fileprivate func setupLayout(){

        views.forEach { v in
            addSubview(v)
            v.alpha = 0
        }
        
        
        let imageWidth: CGFloat = 140
        
        itsAMatchImageView.anchor(top: nil, leading: nil, bottom: descriptionLabel.topAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .init(width: 300, height: 80))
        itsAMatchImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        descriptionLabel.anchor(top: nil, leading: self.leadingAnchor, bottom: currentUserImageView.topAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0), size: .init(width: 0, height: 50))
        
        currentUserImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: imageWidth, height: imageWidth))
        currentUserImageView.layer.cornerRadius = imageWidth/2
        currentUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        cardUserImageView.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: imageWidth, height: imageWidth))
        cardUserImageView.layer.cornerRadius = imageWidth/2
        cardUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
//        sendMessageButton.anchor(top: currentUserImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 32, left: 48, bottom: 0, right: 48), size: .init(width: 0, height: 60))

        keepSwipingButton.anchor(top: currentUserImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 16, left: 40, bottom: 0, right: 40), size: .init(width: 0, height: 60))
        
        
        
    }
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    fileprivate func setupBlurView(){
        
        
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        
        addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        visualEffectView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.visualEffectView.alpha = 1
        } completion: { _ in
    
        }
    }
    
    @objc fileprivate func handleTapDismiss(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
        
        
    }
    
    @objc fileprivate func handleChat(){
        Firestore.firestore().collection("matches_messages").document(currentUser.uid!).collection("matches").document(cardUID).getDocument { (snapshot, err) in
            if err != nil {
                return
            }
            
            // fetched our user here
            guard let dictionary = snapshot?.data() else { return }
            let match = Match(dictionary: dictionary)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
