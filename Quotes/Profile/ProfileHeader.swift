//
//  ProfileHeader.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/25/21.
//

import UIKit
import Firebase

class ProfileHeaderCell: UICollectionViewCell {
    
    weak var delegate: ProfileDelegate?
    
    var user: User? {
        didSet {
            guard let user = user else {return}
            profileImageView.loadImage(urlString: user.profileImageUrl)
            if user.profileImageUrl == nil || user.profileImageUrl == "" {
                profileImageView.image = LetterImageGenerator().imageWith(name: user.name)
            }
            titleLabel.text = user.name
        }
    }
    
    let profileImageView: CustomImageView = {
       let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .customMidGrey
        return imageView
    }()
    
    let titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    lazy var saidByButton: UIButton = {
        let button = UIButton()
        button.setTitle("Said By", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.quotesRed, for: .normal)
        button.tag = 1
        button.addTarget(self, action: #selector(selectedIndex(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var heardByButton: UIButton = {
        let button = UIButton()
        button.setTitle("Heard By", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.darkGray, for: .normal)
        button.tag = 2
        button.addTarget(self, action: #selector(selectedIndex(_:)), for: .touchUpInside)
        return button
    }()
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, centerX: centerXAnchor, centerY: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        addSubview(titleLabel)
        titleLabel.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, centerX: centerXAnchor, centerY: nil, paddingTop: 3, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
        
        let seperator1 = UIView()
        seperator1.backgroundColor = UIColor.lightGray
        seperator1.alpha = 0.5
        addSubview(seperator1)
        seperator1.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, centerX: nil, centerY: nil, paddingTop: 6, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        
        let buttonStack = UIStackView(arrangedSubviews: [saidByButton, heardByButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        addSubview(buttonStack)
        buttonStack.anchor(top: seperator1.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, centerX: nil, centerY: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        
        let seperator2 = UIView()
        seperator2.backgroundColor = UIColor.lightGray
        seperator2.alpha = 0.5
        addSubview(seperator2)
        seperator2.anchor(top: seperator1.bottomAnchor, left: nil, bottom: bottomAnchor, right: nil, centerX: centerXAnchor, centerY: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: -12, paddingRight: 12, width: 1, height: 0)
        
        let seperator3 = UIView()
        seperator3.backgroundColor = UIColor.lightGray
        seperator3.alpha = 0.5
        addSubview(seperator3)
        seperator3.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, centerX: nil, centerY: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
          
          
        heardByButton.addTarget(self, action: #selector(selectedIndex(_:)), for: .touchUpInside)
        saidByButton.addTarget(self, action: #selector(selectedIndex(_:)), for: .touchUpInside)
    }
    
    
    /// Handles which tab is selected and changes its color, then calls delegate method to refresh the feed
    @objc func selectedIndex(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            saidByButton.setTitleColor(.quotesRed, for: .normal)
            heardByButton.setTitleColor(.darkGray, for: .normal)
            delegate?.selectedTabIndex(index: 0)
        case 2:
            saidByButton.setTitleColor(.darkGray, for: .normal)
            heardByButton.setTitleColor(.quotesRed, for: .normal)
            delegate?.selectedTabIndex(index: 1)
        default:
            saidByButton.setTitleColor(.darkGray, for: .normal)
            heardByButton.setTitleColor(.quotesRed, for: .normal)
            delegate?.selectedTabIndex(index: 0)
        }
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
