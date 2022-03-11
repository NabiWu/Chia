//
//  RegistrationViewModel.swift
//  Chia
//
//  Created by Bohan Wu on 2/20/22.
//

import UIKit
import Firebase

// the registrationViewModel responsible for contacting with firebase to save user profile image and adding new user to our database
class RegistrationViewModel {
    
    var bindableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    
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
    
    // perform regsitration by using Auth to create new users
    func performRegistration(completion: @escaping (Error?) -> ()){
        guard let email = email else {
            return
        }
        guard let password = password else {
            return
        }
        bindableIsRegistering.value = true
        
        Auth.auth().createUser(withEmail: email, password: password) {
            (res, err) in
            if let err = err {
                completion(err)
                return
            }
            print("Successfully register user:", res?.user.uid ?? "")
            self.saveImageToFirebase(completion: completion)
        
        }
    }
    
    // catch the uploaded user image and store it into firebase store
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) ->()){
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil) { (_, err) in
            if let err = err{
                completion(err)
                return
            }
            
            print("Finished uploading image to storage")
            ref.downloadURL { (url, err) in
                if let err = err {
                    completion(err)
                    return
                }
                
                self.bindableIsRegistering.value = false
                print("Download url of our image is:", url?.absoluteString ?? "")
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            }
        }
    }
    
    // save the corresponding information to firestore including uid age and max/min seeking prices
    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) ->()){
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String: Any] = [
            "fullName": fullName ?? "",
            "uid": uid,
            "imageUrl1": imageUrl,
            "age": 18,
            "minSeekingPrice": SettingsController.defaultMinSeekingPrice,
            "maxSeekingPrice": SettingsController.defaultMaxSeekingPrice
        ]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
    func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
        
    }
}
