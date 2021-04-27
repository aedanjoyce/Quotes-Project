//
//  QuoteCreatorService.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/25/21.
//

import UIKit
import Firebase
import Contacts


struct QuoteService {
    
    /// Creates a quote and stores it in Firestore
    static func createQuote(quote: String, saidBy: CNContact, heardBy: [CNContact], creationDate: Date, completion: @escaping (Bool) -> ()) {
        
        let saidByPhoneNumber = (saidBy.phoneNumbers[0].value).value(forKey: "digits") as? String ?? ""
        var heardByPhoneNumbers = [String]()
        var heardByString = ""
        
        var counter = 0
        
        // Creates appropriate array
        for contact in heardBy {
            heardByPhoneNumbers.append((contact.phoneNumbers[0].value).value(forKey: "digits") as? String ?? "")
            
            if counter == heardBy.count - 1 {
                heardByString += "\(contact.givenName) \(contact.familyName)"
            } else {
                heardByString += "\(contact.givenName) \(contact.familyName), "
            }
            
            counter += 1
        }
        
        let quote = Quote(text: quote, saidBy: saidByPhoneNumber, heardBy: heardByPhoneNumbers, creationDate: creationDate, heardByString: "Heard by: \(heardByString)").toDictionary()
        
        // Stores quote in database
        Firestore.firestore().collection("Quotes").document().setData(quote) { (error) in
            if let error = error {
                print(error)
                completion(false)
            }
        
        
            var contacts = [CNContact]()
            contacts =  heardBy
            contacts.append(saidBy)
            
            let dispatchGroup = DispatchGroup()
            
            // Creates a new user profile for contacts if they don't already exist in the database
            // When a user signs up with this phone number later on, they can change the name of the user
            // Otherwise it remains how it appears in the address book
            for contact in contacts {
                dispatchGroup.enter()
                let phone_number = (contact.phoneNumbers[0].value).value(forKey: "digits") as? String ?? ""
                FirebaseService.getUser(with_number: phone_number) { (user) in
                    if user == nil {
                        FirebaseService.createUserFromContact(contact: contact) { (user) in
                        }
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(true)
            }
        }
    }
    
    /// Fetches quotes for the specified user. Only shows quotes that the user has heard or said
    static func fetchQuotes(user: User, completion: @escaping ([Quote]) -> ()) {
        var quotes = [Quote]()
            Firestore.firestore().collection("Quotes").whereField("saidBy", isEqualTo: user.phone_number).getDocuments { (snapshot, error) in
                if let error = error {
                    print(error)
                }
                
                snapshot?.documents.forEach({ (snap) in
                    quotes.append(Quote(data: snap.data()))
                })
                Firestore.firestore().collection("Quotes").whereField("heardBy", arrayContains: user.phone_number).getDocuments { (snapshotTwo, error) in
                    if let error = error {
                        print(error)
                    }
                    snapshotTwo?.documents.forEach({ (s) in
                        quotes.append(Quote(data: s.data()))
                    })
                    completion(quotes)
                }
        }
    }
    
    /// Fetches quotes for a user that is queried by the search bar
    static func fetchQuotes(with text: String, user: User, completion: @escaping ([Quote]) -> ()) {
        var quotes = [Quote]()
        
        Firestore.firestore().collection("users").order(by: "name").start(at: [text]).end(at: [text + "\u{f8ff}"]).getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
                completion([])
            }
            guard let documents = snapshot?.documents else {return}
            let dispatchGroup = DispatchGroup()
            for snapshot in documents {
                dispatchGroup.enter()
                let u = User(uid: snapshot.documentID, data: snapshot.data())
                fetchSaidQuotes(user: u) { (saidQuotes) in
                    quotes.append(contentsOf: saidQuotes)
                    fetchHeardQuotes(user: u) { (heardQuotes) in
                        quotes.append(contentsOf: heardQuotes)
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(quotes)
            }

        }
    }
    
    /// Fetches quotes that were said by the specified user
    static func fetchSaidQuotes(user: User, completion: @escaping ([Quote]) -> ()) {
        var quotes = [Quote]()
        var query: Query!
        FirebaseService.getCurrentUser { (u) in
            if user.phone_number == u.phone_number {
                query = Firestore.firestore().collection("Quotes").whereField("saidBy", isEqualTo: user.phone_number)
            } else {
                query = Firestore.firestore().collection("Quotes").whereField("saidBy", isEqualTo: user.phone_number).whereField("heardBy", arrayContains: u.phone_number)
            }
        
            query.getDocuments { (snapshot, error) in
                if let error = error {
                    print(error)
                }
                    
                snapshot?.documents.forEach({ (snap) in
                    quotes.append(Quote(data: snap.data()))
                })
                completion(quotes)
            }
        }
    }
    
    /// Fetches quotes that were heard by the specified user
    static func fetchHeardQuotes(user: User, completion: @escaping ([Quote]) -> ()) {
        var quotes = [Quote]()
        
        var query: Query!
        FirebaseService.getCurrentUser { (u) in
            if user.phone_number == u.phone_number {
                query = Firestore.firestore().collection("Quotes").whereField("heardBy", arrayContains: user.phone_number)
            } else {
                query = Firestore.firestore().collection("Quotes").whereField("heardBy", arrayContains: user.phone_number).whereField("saidBy", isEqualTo: u.phone_number)
            }

            query.getDocuments { (snapshotTwo, error) in
                if let error = error {
                    print(error)
                }
                snapshotTwo?.documents.forEach({ (s) in
                    quotes.append(Quote(data: s.data()))
                })
                completion(quotes)
            }
        }
    }
    
    
    
}
