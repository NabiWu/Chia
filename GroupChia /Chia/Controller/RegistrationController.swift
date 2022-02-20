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
    
    class CustomTextField: UITextField {
        
        let padding: CGFloat
        
        init(padding: CGFloat) {
            self.padding = padding
            super.init(frame: .zero)
        }
        
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: padding, dy: 0)
        }
        
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: padding, dy: 0)
        }
        
        override var intrinsicContentSize: CGSize {
            return .init(width: 0, height: 50)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
    


}
