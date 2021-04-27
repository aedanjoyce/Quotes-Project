//
//  HomeViewCell.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/22/21.
//

import UIKit
import Firebase

class HomeViewCell: UICollectionViewCell {
    
    
    weak var delegate: HomeViewControllerDelegate? // Delegate used to push to certain user profiles based on whats tapped in the cell
    
    
    /// Property to render the information from the quote
    var quote: Quote? {
        didSet {
            if let quote = quote {
                self.setItemProperties(quote: quote)
            }
        }
    }
    
    var user: User?
    private var heardByUsers = [User]()
    
    /// Assigns all user data to the necessary fields within the collectionView cell
    private func setItemProperties(quote: Quote) {
        quote.getSaidByUser { (user) in
        
            // Assigns information from quote to labels
            self.user = user
            self.profileView.loadImage(urlString: user.profileImageUrl)
            if user.profileImageUrl == "" {
                self.profileView.image = LetterImageGenerator().imageWith(name: user.name)
            }
            self.nameLabel.text = user.name
            self.quoteLabel.text = quote.text
            
            
            // Gets the quote's users from their phone numbers
            quote.getHeardByUsers { (users) in
                
                
                // Custom attributed text for the "Heard By" label
                let user_string = self.constructUserString(users: users)
                self.heardByUsers = users
                
                var attributes = [NSAttributedString.Key: AnyObject]()
                attributes[.foregroundColor] = UIColor.lightGray
                attributes[.font] = UIFont.systemFont(ofSize: 16, weight: .medium)
                let attributedText = NSMutableAttributedString(string: "Heard by: ", attributes: attributes)
                attributedText.append(NSAttributedString(string: user_string, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.black.cgColor]))
                self.heardLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedAttributedLabel(gesture:))))
                self.heardLabel.attributedText = attributedText
                self.heardLabel.isUserInteractionEnabled = true

                
            }
            
            // Formats the time stamp for the quote
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/YYYY"
            
            self.timeStamp.text = "\(formatter.string(from: quote.creationDate))"
            
            // Allows the name label to be tapped on and sent to that user's profile page
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.pushToProfile))
            self.nameLabel.isUserInteractionEnabled = true
            self.nameLabel.addGestureRecognizer(tapGesture)

        }
        
    }
    
    // Handles the tapping of a name within the "Heard By" label
    @objc func tappedAttributedLabel(gesture: UITapGestureRecognizer)  {
        let rangeMap = getRangeMap(users: self.heardByUsers)
        
        for range in Array(rangeMap.keys) {
            if gesture.didTapAttributedTextInLabel(label: self.heardLabel, inRange: range) {
                if let user = rangeMap[range] {
                    self.delegate?.pushToUserProfile(user: user)
                    break
                }
            }
        }
    }
    
    /// Handles delegate method that pushes to a certain user's profile
    @objc func pushToProfile() {
        if let user = user {
            delegate?.pushToUserProfile(user: user)
        }
    }
    
    
    /// returns a cleanly constructed string of names who heard the quote
    private func constructUserString(users: [User]) -> String {
        var user_string = ""
        
        var counter = 0
        for user in users {
            if counter == users.count - 1 {
                user_string += user.name
            } else {
                user_string += user.name + ", "
            }
            counter += 1
        }
        return user_string
    }
    
    /*
     Returns a map of ranges to users from a given set of users.
     This is used to pinpoint where in the "Heard By" label each user is.
     This way, when a user taps a name in the label, we can trigger a
     function to push to that user's profile page
     */
    private func getRangeMap(users: [User]) -> [NSRange: User] {
        var ranges = [NSRange: User]()
        
        for user in users {
            let str = user.name
            if let range = self.heardLabel.text?.index(of: str)?.encodedOffset {
                ranges[NSRange(location: range, length: str.count)] = user
            }
        }
        
        return ranges
    }
    
    
    lazy var profileView: CustomImageView = {
       let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor  = .darkGray
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
        
        return label
    }()
    
    let quoteLabel: UITextView = {
        let label = UITextView()
        label.font = UIFont.systemFontItalic(size: 14, fontWeight: .regular)
        label.textColor = UIColor.quotesRed
        label.textAlignment = .left
        label.isScrollEnabled = false
        label.backgroundColor = UIColor.clear
        label.isUserInteractionEnabled = false
        label.textContainerInset = .zero
        label.textContainer.lineFragmentPadding = 0
    
        return label
    }()
    
    let heardLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    let timeStamp: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.lightGray
        return label
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupViews()
    }
    
    private func setupViews() {
        
        addSubview(profileView)
        profileView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, centerX: nil, centerY: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 45, height: 45)
        profileView.layer.cornerRadius = 45 / 2
        
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileView.topAnchor, left: profileView.rightAnchor, bottom: nil, right: rightAnchor, centerX: nil, centerY: nil, paddingTop: 0, paddingLeft: 6, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)
        
        addSubview(timeStamp)
        timeStamp.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, centerX: nil, centerY: nameLabel.centerYAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)

        addSubview(quoteLabel)
        quoteLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: timeStamp.rightAnchor, centerX: nil, centerY: nil, paddingTop: 3, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        addSubview(heardLabel)
        heardLabel.anchor(top: quoteLabel.bottomAnchor, left: quoteLabel.leftAnchor, bottom: nil, right: timeStamp.rightAnchor, centerX: nil, centerY: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        let seperator = UIView()
        seperator.backgroundColor = .lightGray
        addSubview(seperator)
        seperator.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, centerX: nil, centerY: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
