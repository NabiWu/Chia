//
//  PostItemEditController.swift
//  Chia
//
//  Created by Chen Yu on 2022/3/2.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage
protocol PostItemEditControllerDelegate {
    func didEditItem()
}

class PostItemEditController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var delegate: PostItemEditControllerDelegate?


    // instance properties
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    
    @objc func handleSelectPhoto(button: UIButton) {
        print("Select photo with button:", button)
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        // how do i set the image on my buttons when I select a photo?
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else { return }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image..."
        hud.show(in: view)
        ref.putData(uploadData, metadata: nil) { (nil, err) in
            if let err = err {
                hud.dismiss()
                print("Failed to upload image to storage:", err)
                return
            }
            
            print("Finished uploading image")
            ref.downloadURL(completion: { (url, err) in
                
                hud.dismiss()
                
                if let err = err {
                    print("Failed to retrieve download URL:", err)
                    return
                }
                
                print("Finished getting download url:", url?.absoluteString ?? "")
                
                if imageButton == self.image1Button {
                    self.postItem?.imageUrl1 = url?.absoluteString
                } else if imageButton == self.image2Button {
                    self.postItem?.imageUrl2 = url?.absoluteString
                } else {
                    self.postItem?.imageUrl3 = url?.absoluteString
                }
            })
        }
    }
    
    func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        loadCurrentItem()
        fetchCurrentUser()
//        item = PostItem(dictionary: [:])
    }
    
    var user: User?
    var postItem : PostItem?
    fileprivate func loadCurrentItem() {
        loadItemPhotos()
    }
    
    fileprivate func fetchCurrentUser() {
        Firestore.firestore().fetchCurrentUser { (user, err) in
            if let err = err {
                print("Failed to fetch user:", err)
                return
            }
            self.user = user
            self.tableView.reloadData()
        }
    }

    fileprivate func loadItemPhotos() {
        if let imageUrl = postItem?.imageUrl1, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let imageUrl = postItem?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let imageUrl = postItem?.imageUrl3, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    lazy var header: UIView = {
        let header = UIView()
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
    
    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        let headerLabel = HeaderLabel()
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Description"
        default:
            headerLabel.text = "Price"
        }
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        return headerLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        return 40
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = postItem?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
        case 2:
            cell.textField.placeholder = "Enter Description"
            cell.textField.text = postItem?.description
            cell.textField.addTarget(self, action: #selector(handleDescriptionChange), for: .editingChanged)
        default:
            cell.textField.placeholder = "Enter Price"
            cell.textField.text = "\(postItem?.price ?? 0)"
            cell.textField.addTarget(self, action: #selector(handlePriceChange), for: .editingChanged)
        }
        
        return cell
    }
    
    @objc fileprivate func handleNameChange(textField: UITextField) {
        self.postItem?.name = textField.text
    }
    
    @objc fileprivate func handleDescriptionChange(textField: UITextField) {
        self.postItem?.description = textField.text
    }
    
    @objc fileprivate func handlePriceChange(textField: UITextField) {
        self.postItem?.price = Int(textField.text ?? "")
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Post my item"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDelete))
        ]
    }
    
    @objc fileprivate func handleDelete() {
        if let id = postItem?.uid {
            Firestore.firestore().collection("items").document(id).delete()
            print("delete it!")
            self.delegate?.didEditItem()
            dismiss(animated: true)
        }
    }
    
    @objc fileprivate func handleSave() {
        print("Saving our settings data into Firestore")
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let itemUid = postItem?.uid
        let docData: [String: Any] = [
            "name": postItem?.name ?? "",
            "description": postItem?.description ?? "",
            "price": postItem?.price as Any,
            "uid": itemUid as Any,
            "ownerUid": user?.uid as Any,
            "ownerName": user?.name ?? "",
            
            "imageUrl1": postItem?.imageUrl1 ?? "",
            "imageUrl2": postItem?.imageUrl2 ?? "",
            "imageUrl3": postItem?.imageUrl3 ?? "",
            
        ]
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving settings"
        hud.show(in: view)
        Firestore.firestore().collection("items").document(itemUid!).updateData(docData) { (err) in
            hud.dismiss()
            if let err = err {
                print("Failed to save user settings:", err)
                return
            }
            
            print("Finished saving user info")
            self.dismiss(animated: true) {
                print("Dismissal complete")
                self.delegate?.didEditItem()
            }
            
        }
        }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }


}
