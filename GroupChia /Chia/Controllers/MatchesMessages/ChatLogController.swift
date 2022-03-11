//
//  ChatLogController.swift
//  Chia
//
//  Created by Bohan Wu on 2/26/22.
//

import LBTATools
import Firebase
import UIKit



// ChatLogContrller controls the messages sending and receiving from/to firestore
class ChatLogController: LBTAListController<MessageCell,Message>, UICollectionViewDelegateFlowLayout {

    deinit{
        print("ChatlogController is destroying itself properly, no retain cycles or any other memory issues")
    }
    
    fileprivate let match: Match
    fileprivate lazy var customNavBar = MessagesNavBar(match: match)
    fileprivate let navBarHeight: CGFloat = 120

    init(match: Match){
        self.match = match
        super.init()
    }
    
    lazy var customInputView: CustomInputAccessoryView = {
        let civ =  CustomInputAccessoryView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 50))
        civ.sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return civ
    }()
    
    @objc fileprivate func handleSend() {
        print(customInputView.textView.text ?? "")
        saveToFromMessages()
        saveToFromRecentMessage()
    }
    
    
    // catch text from textView and save to recentmessages
    fileprivate func saveToFromRecentMessage(){
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        
        let data = ["text": customInputView.textView.text ?? "",
                    "name": match.name,
                    "profileImageUrl": match.profileImageUrl,
                    "timestamp": Timestamp(date: Date()),
                    "uid": match.uid
        ] as [String : Any]
        
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("recent_messages").document(match.uid).setData(data) { err in
            if let err = err {
                print("Failed to save recent messages", err)
                return
            }
            print("saved recent message")
        }
        
        guard let currentUser = self.currentUser else {return}
        
        let toData = ["text": customInputView.textView.text ?? "",
                    "name": currentUser.name ?? "",
                    "profileImageUrl": currentUser.imageUrl1 ?? "",
                    "timestamp": Timestamp(date: Date()),
                    "uid": currentUserId
        ] as [String : Any]
        
        Firestore.firestore().collection("matches_messages").document(match.uid).collection("recent_messages").document(currentUserId).setData(toData)
        
    }
    
    
    // catch text from textView and save to the message collections
    fileprivate func saveToFromMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        let collection = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid)
        
        let data = ["text": customInputView.textView.text ?? "", "fromId": currentUserId, "toId": match.uid, "timestamp": Timestamp(date: Date())] as [String : Any]
        
        collection.addDocument(data: data) { err in
            if let err = err {
                print("Failed to save message:", err)
                return
            }
             print("Successfully saved msg into Firestore")
            self.customInputView.textView.text = nil
            self.customInputView.placeholderLabel.isHidden = false
        }
        
        let toCollection = Firestore.firestore().collection("matches_messages").document(match.uid).collection(currentUserId)
        
        toCollection.addDocument(data: data) { err in
            if let err = err {
                print("Failed to save message:", err)
                return
            }
             print("Successfully saved msg into Firestore")
            self.customInputView.textView.text = nil
            self.customInputView.placeholderLabel.isHidden = false
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return customInputView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    var listener: ListenerRegistration?
    
    // Fetch all messages
    fileprivate func fetchMessages(){
        print("fetch messages")
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}

        let query = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid).order(by: "timestamp")
        
        listener = query.addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Failed to fetch messages:", err)
                return
            }
            
            querySnapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let dictionary = change.document.data()
                    self.items.append(.init(dictionary: dictionary))
                    
                }
            })
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: [0, self.items.count - 1], at: .bottom, animated: true)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            listener?.remove()
        }
    }
    
    var currentUser: User?
    
    // fetch for current user
    fileprivate func fetchCurrentUser(){
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapshot, err in
            let data = snapshot?.data() ?? [:]
            self.currentUser = User(dictionary: data)
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        fetchCurrentUser()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        collectionView.keyboardDismissMode = .interactive
        
        fetchMessages()
        
        setupUI()
    }
    
    @objc fileprivate func handleKeyboardShow(){
        self.collectionView.scrollToItem(at: [0, items.count - 1], at: .bottom, animated: true)
    }
    
    fileprivate func setupUI() {
        collectionView.alwaysBounceVertical = true
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        
        collectionView.contentInset.top = navBarHeight
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    
    
    @objc fileprivate func handleBack(){
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let estimatedSizeCell = MessageCell(frame: .init(x: 0, y: 0, width: view.frame.width, height: 1000))
        
        estimatedSizeCell.item = self.items[indexPath.item]
        estimatedSizeCell.layoutIfNeeded()
        
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(.init(width: view.frame.width, height: 1000))
        
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
