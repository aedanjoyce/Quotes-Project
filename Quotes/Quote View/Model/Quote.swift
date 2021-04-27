//
//  Quote.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/22/21.
//

import UIKit
import Firebase

/// Class that represents a quote object
class Quote: NSObject {

    var user: User? // user who made this quote
    let text: String // the quote's text
    let saidBy: String // phone_number_identifier
    let heardBy: [String] // array of phone_numbers that heard the quote
    let creationDate: Date // the creation date of the quote
    let heardByString: String // string to calculate the size of each cell and for querying
    
    // Memberwise initializer
    init(text: String, saidBy: String, heardBy: [String], creationDate: Date, heardByString: String) {
        self.text = text
        self.saidBy = saidBy
        self.heardBy = heardBy
        self.creationDate = creationDate
        self.heardByString = heardByString
    }
    
    // Initializer that sets properties based on a snapshot passed from the database
    init(data: [String: Any]) {
        self.text = data["text"] as? String ?? ""
        self.saidBy = data["saidBy"] as? String ?? ""
        let secondsFrom1970 = data["creationDate"] as? Double ??  0.0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.heardBy = data["heardBy"] as? [String] ?? []
        self.heardByString = data["heardByString"] as? String ?? ""
    }
    
    // Helper function that converts the properties to a dictionary
    func toDictionary() -> [String: Any] {
        return ["text": self.text, "saidBy": self.saidBy, "creationDate": self.creationDate.timeIntervalSince1970, "heardBy": self.heardBy, "heardByString": self.heardByString.lowercased()]
    }
    
    /// Retrieves the users from each phone number in the heardBy property
    func getHeardByUsers(completion: @escaping ([User]) -> ()) {
        let dispatchGroup = DispatchGroup()
        var users = [User]()
        for number in heardBy {
            dispatchGroup.enter()
            FirebaseService.getUser(with_number: number) { (user) in
                if let user = user {
                    users.append(user)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(users)
        }
    }
    
    /// Gets the user who said the quote, based on the phone number stored in saidBy
    func getSaidByUser(completion: @escaping (User) -> ()) {
        FirebaseService.getUser(with_number: saidBy) { (user) in
            if let user = user {
                completion(user)
            }
        }
    }
    
}
