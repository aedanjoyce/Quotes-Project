//
//  ProfileController.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/21/21.
//

import UIKit
import Firebase
import ViewAnimator

/// Custom delegate that handles custom methods for the profile
protocol ProfileDelegate: class {
    
    /// Function that handles when either the "said by" or "heard by" button is selected
    func selectedTabIndex(index: Int)
}

class ProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ProfileDelegate, HomeViewControllerDelegate {
    
    func pushToUserProfile(user: User) {
        let profileController = ProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        profileController.user = user
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(profileController, animated: true)
        }
    }

    /// Handles which tab is selected and refreshes the feed. If 0, then "Said By" is selected. "Heard By" is selected otherwise
    var selectedIndex: Int? = 0 {
        didSet {
            guard let index = selectedIndex else {return}
            fetchFeed(index: index)
        }
    }
    
    func selectedTabIndex(index: Int) {
        selectedIndex = index
    }
    
    
    var isCurrentUser: Bool? {
        didSet {
        }
    }
    
    /// Refreshes the feed. If 0, then "Said By" is shown. "Heard By" is shown otherwise
    func fetchFeed(index: Int) {
        self.quotes.removeAll()
        guard let user = user else {return}
        if index == 0 {
            QuoteService.fetchSaidQuotes(user: user) { (quotes) in
                self.displayQuotes(quotes: quotes)
            }
        } else {
            QuoteService.fetchHeardQuotes(user: user) { (quotes) in
                self.displayQuotes(quotes: quotes)
            }
        }
    }
    
    /// Helper function that displays and sorts the quotes for the collectionView
    private func displayQuotes(quotes: [Quote]) {
        self.quotes = quotes
        self.quotes.sort { (q1, q2) -> Bool in
            return q1.creationDate.compare(q2.creationDate) == .orderedDescending
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.performBatchUpdates {
                if let cells = self.collectionView?.orderedVisibleCells {
                    UIView.animate(views: cells, animations: [AnimationType.zoom(scale: 0.9)])
                }
            } completion: { (result) in
                // do something
            }
        }
    }
    
    var user: User? {
        didSet {
            guard let user = user else {return}
            self.selectedTabIndex(index: 0)
            navigationItem.title = user.name
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private var quotes = [Quote]()
    
    
    private let cellId = "cellId"
    private let headerId = "headerId"
    private let emptyCellId = "emptyCellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.collectionView.backgroundColor = .white
        collectionView.register(HomeViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(EmptyStateCell.self, forCellWithReuseIdentifier: emptyCellId)
        collectionView.register(ProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView.alwaysBounceVertical = true
        fetchFeed(index: 0)
    }
    
    
    @objc func handleLogout() {
        do {
            
            try Auth.auth().signOut()
            let onboarding = PhoneAuthController()
            let navController = UINavigationController(rootViewController: onboarding)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        } catch let signOutErr {
            print("Failed to sign out:", signOutErr)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Gets current user if no user is set
        if user == nil {
            FirebaseService.getCurrentUser { (user) in
                self.user = user
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(self.handleLogout))
                    self.navigationItem.rightBarButtonItem?.tintColor = .black
                }
                
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if quotes.count == 0 {
            let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellId, for: indexPath) as! EmptyStateCell
            emptyCell.user = self.user
            return emptyCell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeViewCell
        cell.quote = quotes[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! ProfileHeaderCell
        header.user = self.user
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 220)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quotes.count == 0 ? 1 : quotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if quotes.count != 0 {
            let label = UILabel(frame: CGRect.zero)
            label.text = quotes[indexPath.item].text
            label.sizeToFit()
            
            let heardLabel = UILabel(frame: CGRect.zero)
            heardLabel.text = quotes[indexPath.item].heardByString
            heardLabel.sizeToFit()
        
            
            return CGSize(width: view.frame.width, height: estimateFrameSize(text: quotes[indexPath.item].text).height + estimateFrameSize(text: quotes[indexPath.item].heardByString).height + 50)
        } else {
            return CGSize(width: view.frame.width, height: collectionView.frame.height - 250)
        }
    }
    
    fileprivate func estimateFrameSize(text: String) -> CGRect {
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedString.Key: UIFont.systemFont(ofSize: 16, weight: .regular)], context: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    
}
