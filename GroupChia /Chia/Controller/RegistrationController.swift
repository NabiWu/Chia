//
//  RegistrationController.swift
//  Chia
//
//  Created by Bohan Wu on 2/20/22.
//

import UIKit

class RegistrationController: UIViewController {
    
    //UI Components
    
    let selectedPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 275).isActive = true
        button.layer.cornerRadius = 16
        return button
    }()
    
    let fullNameTextField: CustomTextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter full name"
        tf.backgroundColor = .white
        return tf
    }()
    
    let emailTextField: CustomTextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter email"
        tf.backgroundColor = .white
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    let passwordTextField: CustomTextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter password"
        tf.backgroundColor = .white
        tf.isSecureTextEntry = true
        return tf
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientLayer()
        view.backgroundColor = .red
        
        let stackView = UIStackView(arrangedSubviews: [
            selectedPhotoButton,
            fullNameTextField,
            emailTextField,
            passwordTextField])
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    fileprivate func setupGradientLayer(){
        let gradientLayer = CAGradientLayer()
        
        let topColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0,1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
    


}
