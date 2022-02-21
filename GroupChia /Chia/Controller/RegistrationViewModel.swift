//
//  RegistrationViewModel.swift
//  Chia
//
//  Created by Bohan Wu on 2/20/22.
//

import Foundation

class RegistrationViewModel {
    var fullName: String? {
        didSet{
            checkFormValidity()
        }
    }
    var email: String? {
        didSet{
            checkFormValidity()
        }
    }
    var password: String? {
        didSet{
            checkFormValidity()
        }
    }
    
    fileprivate func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        isFormValidObserver?(isFormValid)
        
    }
    
    var isFormValidObserver: ((Bool) -> ())?
}
