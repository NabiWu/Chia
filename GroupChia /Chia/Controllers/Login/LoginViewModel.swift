//
//  LoginViewModel.swift
//  Chia
//
//  Created by Bohan Wu on 2/22/22.
//

import Foundation
import Firebase

// The loginViewModel respsonsible for performing login process and check the validity of login form
class LoginViewModel {
    
    var isLoggingIn = Bindable<Bool>()
    var isFormValid = Bindable<Bool>()
    
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    // check if user input all needed information for logining in
    fileprivate func checkFormValidity() {
        let isValid = email?.isEmpty == false && password?.isEmpty == false
        isFormValid.value = isValid
    }
    
    // perform login process by contacting with firestore
    func performLogin(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        isLoggingIn.value = true
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            completion(err)
        }
    }
}
