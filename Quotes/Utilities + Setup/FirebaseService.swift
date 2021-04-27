//
//  FirebaseService.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/22/21.
//

import UIKit
import Firebase
import Contacts

struct FirebaseService {
    
    /// Fetches a user from the database with a given uid or personal identifier
    static func fetchUser(with uid: String, completion: @escaping (User?) -> ()) {
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print(error)
                return
            }
            if snapshot?.data() == nil {
                completion(nil)
            }
            guard let dictionary = snapshot?.data(), let uid = snapshot?.documentID else {return}
            
            completion(User(uid: uid, data: dictionary))
        }
    }
    
    /// Fetches a user associated with a given phone number -> returns a User object
    static func getUser(with_number phone_number: String, completion: @escaping (User?) -> ()) {
        Firestore.firestore().collection("users").whereField("phone_number", isEqualTo: phone_number).getDocuments { (snapshot, error) in
            if let error = error {
                // Error or user doesn't exist
                print(error)
                completion(nil)
            }
            
            guard let document = snapshot?.documents.first else {completion(nil); return}
            completion(User(uid: document.documentID, data: document.data()))
        }
    }
    
    /// Gets the current  user signed in from Auth
    static func getCurrentUser(completion: @escaping (User) -> ()) {
        guard let email = Auth.auth().currentUser?.email else {return}
        var number = ""
        for character in email {
            if character == "@" {break}
            number += String(character)
        }
        FirebaseService.getUser(with_number: number) { (user) in
            completion(user!)
        }
    }
    
    /// Creates a new user if one doesn't exist from a quote being created
    static func createUserFromContact(contact: CNContact, completion:  @escaping (User) -> ()) {
        var phone_number = (contact.phoneNumbers[0].value).value(forKey: "digits") as? String ?? ""
        
        if phone_number.contains("+1") {
            phone_number.removeFirst()
            phone_number.removeFirst()
        }
        
        
        let ref = Firestore.firestore().collection("users").document(phone_number)
        let user = User(uid: ref.documentID, name: "\(contact.givenName) \(contact.familyName)", phone_number: phone_number, profileImageUrl: "")
        ref.setData(user.toDictionary()) { (error) in
            if let error = error {
                print(error)
                return
            }
            completion(user)
        }
    }
}
