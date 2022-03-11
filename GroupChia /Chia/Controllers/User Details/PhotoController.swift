//
//  PhotoController.swift
//  Chia
//
//  Created by Bohan Wu on 2/24/22.
//
import UIKit

//Photo inside the card
class PhotoController: UIViewController {
    
    let imageView = UIImageView(image: UIImage(named: "top_left_profile"))
    
    
    init(imageUrl: String){
        if let url = URL(string: imageUrl){
            imageView.sd_setImage(with: url)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

