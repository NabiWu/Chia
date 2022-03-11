//
//  ViewController.swift
//  Chia
//
//  Created by Bohan Wu on 2/19/22.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate, PostItemControllerDelegate{
    

    

    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomControls = HomeBottomControlsStackView()
    
    
    var cardViewModels = [CardViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        topStackView.messageButton.addTarget(self, action: #selector(handleMessage), for: .touchUpInside)
        
        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomControls.postButton.addTarget(self, action: #selector(handlePostItem), for: .touchUpInside)
        bottomControls.specialButton.addTarget(self, action: #selector(handleManagePostItem), for: .touchUpInside)
        setupLayout()
        
        fetchCurrentUser()
        fetchUsersFromFirestore()
//        fetchItemsFromFirestore()
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
            self.fetchItemsFromFirestore()
        }
    }
    
    @objc fileprivate func handleRefresh(){
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchItemsFromFirestore()
    }
    
    var lastFetchedUser: User?
    
    

    
    fileprivate func fetchItemsFromFirestore() {
        
        let minPrice = user?.minSeekingPrice ?? SettingsController.defaultMinSeekingPrice
        let maxPrice = user?.maxSeekingPrice ?? SettingsController.defaultMaxSeekingPrice
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching Items"
        hud.show(in: view)

        let query = Firestore.firestore().collection("items").whereField("price", isGreaterThanOrEqualTo: minPrice).whereField("price", isLessThanOrEqualTo: maxPrice)
        
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
                let itemDictionary = documentSnapchot.data()
                let item = PostItem(dictionary: itemDictionary)
                
                self.items[item.uid ?? ""] = item
            
                let isNotCurrentUser =  item.ownerUid != Auth.auth().currentUser?.uid
//                let hasSwipedBefore = self.swipes[user.uid!] == nil
                
                let hasSwipedBefore = true
                
                if isNotCurrentUser && hasSwipedBefore {
                    let cardView = self.setupItemsFromUser(item: item)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
        }
    }
    
    var items = [String: PostItem]()
    
    var topCardView: CardView?
    @objc func handleLike() {
        saveSwipeToFirestore(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
    
    }
    
    fileprivate func saveSwipeToFirestore(didLike: Int) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let cardUID = topCardView?.cardViewModel.uid else {return}
        guard let cardOwnerID = topCardView?.cardViewModel.ownerUID else {return}
        guard let cardOwnerImage = topCardView?.cardViewModel.imageUrls[0] else {return}

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
                        self.checkIfMatchExists(cardUID: cardUID, cardOwnerID: cardOwnerID, cardOwnerImage: cardOwnerImage)
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
                        self.checkIfMatchExists(cardUID: cardUID, cardOwnerID: cardOwnerID, cardOwnerImage: cardOwnerImage)
                    }
                }
            }
        }
 
    }
    
    var users = [String: User]()
    fileprivate func fetchUsersFromFirestore() {

        let query = Firestore.firestore().collection("users")
        topCardView = nil
        query.getDocuments { (snapshot, err) in
            if let err = err {
                print("Failed to fetch users:", err)
                return
            }
            snapshot?.documents.forEach({ (documentSnapchot) in
            let userDictionary = documentSnapchot.data()
            let user = User(dictionary: userDictionary)
            self.users[user.uid ?? ""] = user

            })
        }
    }
    
    // TO DO: Go to private message
    fileprivate func checkIfMatchExists(cardUID: String, cardOwnerID: String, cardOwnerImage: String){
        print("Detecting match")
        
        let cardOwner = users[cardOwnerID]
        

        guard let uid = Auth.auth().currentUser?.uid else {return}
        let currentUser = users[uid]

        self.presesntMatchView(cardUID: cardOwnerID)

        guard let postItem = self.items[cardUID] else {return}

            let data = [
                "name": postItem.name ?? "",
                "profileImageUrl": postItem.imageUrl1 ?? "",
                "uid": cardUID,
                "ownerUid": cardOwnerID,
                "timestamp": Timestamp(date: Date())
            ] as [String : Any]

            Firestore.firestore().collection("matches_messages").document(uid).collection("likedItems").document(cardUID).setData(data) { err in
                if let err = err {
                    print("Failed to save match info:", err)
                    return
                }
            }
        
        
        let collection = Firestore.firestore().collection("matches_messages").document(uid).collection(cardOwnerID)
        
        let messageData = ["text": "I am intereted in your \(postItem.name!)!", "fromId": uid, "toId": cardOwnerID, "timestamp": Timestamp(date: Date())] as [String : Any]
        
        collection.addDocument(data: messageData) { err in
            if let err = err {
                print("Failed to save message:", err)
                return
            }
             print("Successfully saved msg into Firestore")
            
        }
        
        let toCollection = Firestore.firestore().collection("matches_messages").document(cardOwnerID).collection(uid)
        
        toCollection.addDocument(data: messageData) { err in
            if let err = err {
                print("Failed to save message:", err)
                return
            }
             print("Successfully saved msg into Firestore")
        }
        
        
        let recentMessageData = ["text": "I am intereted in your \(postItem.name!)!",
                                 "name": cardOwner?.name ?? "",
                                 "profileImageUrl": cardOwner?.imageUrl1 ?? "",
                                 "timestamp": Timestamp(date: Date()),
                                 "uid": cardOwnerID
        ] as [String : Any]

        Firestore.firestore().collection("matches_messages").document(uid).collection("recent_messages").document(cardOwnerID).setData(recentMessageData) { err in
            if let err = err {
                print("Failed to save recent messages", err)
                return
            }
            print("saved recent message")
        }
        

        let toData = ["text": "I am intereted in your \(postItem.name!)!",
                      "name": currentUser?.name ?? "",
                      "profileImageUrl": currentUser?.imageUrl1 ?? "",
                    "timestamp": Timestamp(date: Date()),
                    "uid": uid
        ] as [String : Any]

        Firestore.firestore().collection("matches_messages").document(cardOwnerID).collection("recent_messages").document(uid).setData(toData)

    }
    
    
    
    @objc func handlePostItem() {
        let postItemController = PostItemController()
        postItemController.delegate = self
        let navController = UINavigationController(rootViewController: postItemController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
//        addItem()
    }
    
    @objc func handleManagePostItem() {
        let layout = UICollectionViewFlowLayout()
        let postItemCollectionViewController = PostItemCollectionViewController(collectionViewLayout: layout)
//        postItemCollectionViewController.delegate = self
        let navController = UINavigationController(rootViewController: postItemCollectionViewController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    func didSaveItems() {
        fetchCurrentUser()
    }
    
    func addItem() {
        Firestore.firestore().collection("items").document(UUID().uuidString).setData([
            "description":"",
            "imageUrl1":"",
            "price":"1",
            "uid": self.user?.uid! ?? ""
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
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
    
//    fileprivate func setupCardFromUser(user: User) -> CardView {
//        let cardView = CardView(frame: .zero)
//        cardView.delegate = self
//        cardView.cardViewModel = user.toCardViewModel()
//        cardsDeckView.addSubview(cardView)
//        cardsDeckView.sendSubviewToBack(cardView)
//        cardView.fillSuperview()
//        return cardView
//    }
    
    fileprivate func setupItemsFromUser(item: PostItem) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = item.toCardViewModel()
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

