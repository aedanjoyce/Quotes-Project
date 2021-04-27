//
//  User.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/22/21.
//

import UIKit
import Firebase

/// Class that represents a user in the quotes app
class User: NSObject {
    let uid: String // identifier associated with this user
    let name: String // name of user
    let profileImageUrl: String // url to profile image
    let phone_number: String // user's phone number
    
    /// Memberwise initializer
    init(uid: String, name: String, phone_number: String, profileImageUrl: String) {
        self.uid = uid
        self.name = name
        self.phone_number = phone_number
        self.profileImageUrl = profileImageUrl
    }
    
    /// Initializer to be used when fetching data from database
    init(uid: String, data: [String: Any]) {
        self.uid = uid
        self.name = data["name"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.phone_number = data["phone_number"] as? String ?? ""
    }
    
    /// Helper function to convert user class properties to a dictionary, so it can cleanly be stored in database
    func toDictionary() -> [String: Any] {
        return ["name": self.name, "profileImageUrl": self.profileImageUrl, "phone_number": self.phone_number]
    }
    
    
    
    
    
}
