//
//  PostItemCollectionCell.swift
//  Chia
//
//  Created by Chen Yu on 2022/2/28.
//

import UIKit

// UserProfilePhotoCell is the cell in the PostitemCollectionViewController.
// Each cell contains the image of this item.
class UserProfilePhotoCell: UICollectionViewCell {
    
    var postItem: PostItem? {
        didSet {
            
            guard let imageUrl = postItem?.imageUrl1 else { return }
            
            guard let url = URL(string: imageUrl) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                if let err = err {
                    print("Failed to fetch post image:", err)
                    return
                }
                guard let imageData = data else { return }
                
                let photoImage = UIImage(data: imageData)
                
                // async load the image
                DispatchQueue.main.async {
                    self.photoImageView.sd_setImage(with: URL(string: imageUrl))
                }
                
            }.resume()
            
        }
    }
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 0), size: .init(width: 0, height: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
