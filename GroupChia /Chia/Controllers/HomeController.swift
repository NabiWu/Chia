//
//  ViewController.swift
//  Chia
//
//  Created by Bohan Wu on 2/19/22.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate{


    

    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomControls = HomeBottomControlsStackView()
    
    
    var cardViewModels = [CardViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        topStackView.messageButton.addTarget(self, action: #selector(handleMessage), for: .touchUpInside)
        
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        setupLayout()
        
        fetchCurrentUser()
    }
    
    @objc fileprivate func handleMessage(){
        let vc = MatchesMessagesController()
        navigationController?.pushViewController(vc, animated: true)
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("HomeController did appear")
        if Auth.auth().currentUser == nil {
            let registrationController = RegistrationController()
            registrationController.delegate = self
            let navController = UINavigationController(rootViewController: registrationController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
 
    }
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    fileprivate let hud = JGProgressHUD(style: .dark)
    fileprivate var user: User?
    
    fileprivate func fetchCurrentUser(){
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        Firestore.firestore().fetchCurrentUser { (user, err) in
            if let err = err {
                print("Failed to fetch user:", err)
                return
            }
            self.hud.dismiss()
            self.user = user
            
            self.fetchSwipes()
            
        }
    }
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("swipes").document(uid).getDocument { snapchot, err  in
            if let err = err {
                print("Failed to fetch swipes info for currently logged in user:", err)
                return
            }
            
            print("Swipes:", snapchot?.data() ?? "")
            guard let data = snapchot?.data() as? [String: Int] else {return}
            self.swipes = data
            self.fetchUsersFromFirestore()
        }
    }
    
    @objc fileprivate func handleRefresh(){
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchUsersFromFirestore()

    }
    
    var lastFetchedUser: User?
    
    fileprivate func fetchUsersFromFirestore() {
        
        let minPrice = user?.minSeekingPrice ?? SettingsController.defaultMinSeekingPrice
        let maxPrice = user?.maxSeekingPrice ?? SettingsController.defaultMaxSeekingPrice
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching Users"
        hud.show(in: view)
        
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minPrice).whereField("age", isLessThanOrEqualTo: maxPrice).limit(to: 10)
        topCardView = nil
        query.getDocuments { (snapshot, err) in
            hud.dismiss()
            if let err = err {
                print("Failed to fetch users:", err)
                return
            }
            
            //linked list
            var previousCardView: CardView?
            
            snapshot?.documents.forEach({ (documentSnapchot) in
                let userDictionary = documentSnapchot.data()
                let user = User(dictionary: userDictionary)
                
                self.users[user.uid ?? ""] = user
            
                let isNotCurrentUser =  user.uid != Auth.auth().currentUser?.uid
//                let hasSwipedBefore = self.swipes[user.uid!] == nil
                
                let hasSwipedBefore = true
                
                if isNotCurrentUser && hasSwipedBefore {
                    let cardView = self.setupCardFromUser(user: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
        }
    }
    
    var users = [String: User]()
    
    var topCardView: CardView?
    
    @objc func handleLike() {
        saveSwipeToFirestore(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
    
    }
    
    fileprivate func saveSwipeToFirestore(didLike: Int) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let cardUID = topCardView?.cardViewModel.uid else {return}


        let documentData = [
            cardUID: didLike
        ]
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { snapshot, err in
            if let err = err {
                print("fail to fetch swipe document:", err)
                return
            }
            
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { err in
                    if let err = err{
                        print("Fail to save swipe data:", err)
                        return
                    }
                    print("Successfully update swipe...")
                    if didLike == 1{
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { err in
                    if let err = err{
                        print("Fail to save swipe data:", err)
                        return
                    }
                    print("Successfully saved swipe...")
                    if didLike == 1{
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            }
        }
 
    }
    
    
    // TO DO: Go to private message
    fileprivate func checkIfMatchExists(cardUID: String){
        print("Detecting match")
        
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { snapshot, err in
            if let err = err {
                print("Fail to fetch document for card user:", err)
                return
            }
            
            guard let data = snapshot?.data() else {return}
            print(data)
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                self.presesntMatchView(cardUID: cardUID)
                
                guard let cardUser = self.users[cardUID] else {return}
                
                let data = [
                    "name": cardUser.name ?? "",
                    "profileImageUrl": cardUser.imageUrl1 ?? "",
                    "uid": cardUID,
                    "timestamp": Timestamp(date: Date())
                ] as [String : Any]
                
                Firestore.firestore().collection("matches_messages").document(uid).collection("matches").document(cardUID).setData(data) { err in
                    if let err = err {
                        print("Failed to save match info:", err)
                        return
                    }
                }
                
                guard let currentUser = self.user else {return}
                
                let otherMatchData = [
                    "name": currentUser.name ?? "",
                    "profileImageUrl": currentUser.imageUrl1 ?? "",
                    "uid": currentUser.uid ?? "",
                    "timestamp": Timestamp(date: Date())
                ] as [String : Any]
                
                Firestore.firestore().collection("matches_messages").document(cardUID).collection("matches").document(uid).setData(otherMatchData) { err in
                    if let err = err {
                        print("Failed to save match info:", err)
                        return
                    }
                }
            }
        }
    }
    
    fileprivate func presesntMatchView(cardUID: String){
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        view.addSubview(matchView)
        matchView.fillSuperview()
    }
    
    @objc func handleDislike(){
        saveSwipeToFirestore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
    }
    
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.3
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    //TODO: fetch my items
    
    //TODO: edit my items
    
    //TODO: delete my items
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
    func didTapMoreInfo(cardViewModel:CardViewModel) {
        print("Home controller:",cardViewModel.attributedString)
        let userDetailsController = UserDetailsController()
        userDetailsController.modalPresentationStyle = .fullScreen
        userDetailsController.cardViewModel = cardViewModel
        present(userDetailsController, animated: true)
    }
    
    @objc func handleSettings(){
        
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    func didSaveSettings() {
        print("Notified of dismissal from settingscontroller in homecontroller")
        fetchCurrentUser()
    }

    fileprivate func setupFirestoreUserCards(){
        cardViewModels.forEach { cardVM in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardVM
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }

}

