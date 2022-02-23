//
//  SwipingPhotosController.swift
//  Chia
//
//  Created by Bohan Wu on 2/23/22.
//

import UIKit

class SwipingPhotosController: UIPageViewController, UIPageViewControllerDataSource {
    
    var cardViewModel: CardViewModel! {
        didSet {
            print(cardViewModel.attributedString)
            controllers = cardViewModel.imageUrls.map({ (imageUrl) -> UIViewController in
                let photoController = PhotoController(imageUrl: imageUrl)
                return photoController
            })
            
            setViewControllers([controllers.first!], direction: .forward, animated: false)
        }
    }
    
    var controllers = [UIViewController]()
    
//    let controllers = [
//        PhotoController(image: UIImage(named: "jane1")!),
//        PhotoController(image: UIImage(named: "jane2")!),
//        PhotoController(image: UIImage(named: "jane3")!),
//        PhotoController(image: UIImage(named: "kelly1")!),
//        PhotoController(image: UIImage(named: "kelly2")!)
//    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        view.backgroundColor = .white
        
//        setViewControllers([controllers.first!], direction: .forward, animated: false)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == controllers.count - 1 {return nil}
        return controllers[index + 1]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == 0 {return nil}
        return controllers[index - 1]
    }
}

class PhotoController: UIViewController {
    
    let imageView = UIImageView(image: UIImage(named: "jane1"))
    
    
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
