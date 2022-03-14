//
//  splashScreenControllerViewController.swift
//  Chia
//
//  Created by Chen Yu on 2022/3/13.
//

import UIKit
import LBTATools
import grpc
// SplashScreenViewController is to display splash screen about app and authors information in 1 seconds. User can also click background to dismiss this screen.
class SplashScreenViewController: UIViewController {
    var navController : UINavigationController?
    override func viewDidLoad() {
        super.viewDidLoad()
        let homeController = HomeController()
        navController = UINavigationController(rootViewController: homeController)
        navController?.modalPresentationStyle = .fullScreen
        setupBlurView()
        setupLayout()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.handleTapDismiss), userInfo: nil, repeats: false)
    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let companyName = UILabel()
        companyName.text = "DuoX"
        companyName.textAlignment = .center
        companyName.textColor = .black
        companyName.font = UIFont.systemFont(ofSize: 20)
        companyName.numberOfLines = 0
        companyName.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        companyName.center = .init(x: view.center.x, y: view.center.y)
        view.addSubview(companyName)
        let authors = UILabel()
        authors.text = "Bohan Wu, Chen Yu and Jiangnan Chen"
        authors.textAlignment = .center
        authors.textColor = .black
        authors.font = UIFont.systemFont(ofSize: 15)
        authors.numberOfLines = 0
        authors.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        view.addSubview(authors)
        authors.anchor(top: companyName.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: UIScreen.main.bounds.width, height: 50))
        
    }

    
    fileprivate func setupBlurView(){
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        
        view.addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        visualEffectView.alpha = 1
    
    }

    @objc fileprivate func handleTapDismiss(){
        print("navigate to the homecontroller")
        present(navController!, animated: true)
    }

}
