//
//  OnboardingService.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/21/21.
//

import UIKit
import Firebase

/// Service layer that connects all onboarding database calls to firebase
struct OnboardingService {
    
    ///Enum that handles the response object from sign in call
    enum SignInResult {
        case success
        case userDoesntExist
        case failure(Error?)
    }
    
    /// Function that handles the sign in of a user using an AuthCredential
    static func signInUser(number: String, password: String, completion: @escaping (SignInResult) -> ()) {
        Auth.auth().signIn(withEmail: "\(number)@quotesapp.com", password: password) { (result, error) in
            if let error = error {
                print(error)
                completion(.userDoesntExist)
                return
            }
            completion(.success)
        }
    }
    
    ///Function that creates a user and stores it in the Firestore database
    static func createUser(number: String, password: String, completion: @escaping (Bool) -> ()) {
        // custom auth mask to allow for phone number sign in with password
        Auth.auth().createUser(withEmail: "\(number)@quotesapp.com", password: password) { (result, error) in
            if let error = error {
                print(error)
                completion(false)
            }
            completion(true)
        }
    }
    
    /// Function  that saves the user's information after successfully signing up
    static func setUserProperties(number: String, name: String, image: UIImage, completion: @escaping(Bool)->()) {
        var img = image
        if image == UIImage(named: "PhotoChooser") || image == nil {
            img = LetterImageGenerator().imageWith(name: name) ?? UIImage()
        }
        
        saveUserPhoto(image: img) { (url) in
            guard let url = url else {completion(false); return}
            Firestore.firestore().collection("users").document(number).setData(User(uid: number, name: name, phone_number: number, profileImageUrl: url).toDictionary()) { (error) in
                if let error = error {
                    print(error)
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    /// Function  that handles the saving of  a user's photo in the database and then returns the URL in string form
    static private func saveUserPhoto(image: UIImage, completion: @escaping (String?) -> ()) {
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
        let fileName = NSUUID().uuidString
        
        // save user profile image
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            // handle error
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            
            storageRef.downloadURL { (url, url_error) in
                if let error = url_error {
                    print(error)
                    completion(nil)
                }
                
                guard let profileImageUrl = url?.absoluteString else {return}
                
                completion(profileImageUrl)
            }
        }
    }
    
    
    
}
