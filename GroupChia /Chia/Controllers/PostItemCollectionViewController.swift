//
//  PostItemCollectionViewController.swift
//  Chia
//
//  Created by Chen Yu on 2022/2/28.
//

import UIKit
import Firebase
import JGProgressHUD


class PostItemCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PostItemEditControllerDelegate {
    let cellId = "cellId"
    var postItems = [PostItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        print("collectionView did load")
        setupNavigationItems()
        
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        fetchMyPostItems()

    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Edit my items"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
//        navigationItem.rightBarButtonItems = [
//            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
//            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
//        ]
    }
    
    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }
    fileprivate func fetchMyPostItems() {
        let query = Firestore.firestore().collection("items")
        let hud = JGProgressHUD(style: .dark)
        self.postItems = [PostItem]()
        hud.textLabel.text = "Fetching Items"
        hud.show(in: view)
        
        query.getDocuments { (snapshot, err) in
            hud.dismiss()
            if let err = err {
                print("Failed to fetch users:", err)
                return
            }
            
            
            snapshot?.documents.forEach({ (documentSnapchot) in
                let itemDictionary = documentSnapchot.data()
                let item = PostItem(dictionary: itemDictionary)
                
//                self.users[item.ownerUid ?? ""] = item
            
                let isCurrentUser =  item.ownerUid == Auth.auth().currentUser?.uid
//                let hasSwipedBefore = self.swipes[user.uid!] == nil
                if isCurrentUser {
                    self.postItems.append(item)
                }
            })
            self.collectionView!.reloadData()
        }
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return postItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
        
        cell.postItem = postItems[indexPath.row]
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(postItems[indexPath.row].name!)
        let postItemEditController = PostItemEditController()
        postItemEditController.delegate = self
        postItemEditController.postItem = postItems[indexPath.row]
        let navController = UINavigationController(rootViewController: postItemEditController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 15) / 2
        return CGSize(width: width, height: width*1.5)
    }
    
    func didEditItem() {
//      TODO: optimize don't need to refetch
        fetchMyPostItems()
    }
}
