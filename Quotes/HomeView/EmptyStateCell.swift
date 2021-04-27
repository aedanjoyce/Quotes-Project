//
//  EmptyStateCell.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/25/21.
//

import UIKit
import Firebase

//MARK: Class that represents an empty state in the collection view
class EmptyStateCell: UICollectionViewCell {
    
    weak var user: User? {
        didSet {
            guard let user = user else {return}
            FirebaseService.getCurrentUser { (u) in
                if u.phone_number != user.phone_number {
                    DispatchQueue.main.async {
                        self.subLabel.text = "\(user.name) hasn't said or heard any quotes yet. When they do, they will appear here."
                    }
                }
            }
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .quotesRed
        label.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        label.text = "Uh oh!"
        label.textAlignment = .center
        return label
    }()
    
    let subLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.text = "You haven't said or heard any quotes yet. When you do, they will appear here."
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .customLightGrey
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: nil, bottom: nil, right: nil, centerX: centerXAnchor, centerY: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -48).isActive = true
        addSubview(subLabel)
        subLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, centerX: nil, centerY: nil, paddingTop: 8, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
