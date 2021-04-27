//
//  HomeViewController.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/21/21.
//

import UIKit
import Firebase
import ViewAnimator


protocol HomeViewControllerDelegate: class {
    
    /// Pushes to a user profile from a given user
    func pushToUserProfile(user: User)
}



class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomeViewControllerDelegate {
    
    var quotes = [Quote]()
    private var queriedQuotes = [Quote]()
    private var searchController: UISearchController?
    private let cellId = "cellId"
    private let refreshControl = UIRefreshControl()
    private let emptyCellId = "emptyCellId"
    
    // Delegate function
    func pushToUserProfile(user: User) {
        let profileController = ProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        profileController.user = user
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(profileController, animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchFeed()
        setupSearchController()
    }
    
    /// Sets up navigation bar and registers collectionView cells to be used in the collectionView
    @objc func setupCollectionView() {
        self.view.backgroundColor = .white
        self.collectionView.backgroundColor = .white
        collectionView.register(HomeViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(EmptyStateCell.self, forCellWithReuseIdentifier: emptyCellId)
        navigationItem.title = "Quotes"
        collectionView.alwaysBounceVertical = true
        navigationController?.navigationBar.backgroundColor = .white
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchFeed), for: .valueChanged)
    }
    
    /// Sets up and embeds a search controller at the top of the collectionView
    @objc func setupSearchController() {
        let results = HomeViewResultsController(collectionViewLayout: UICollectionViewFlowLayout())
        results.delegate = self
        searchController = UISearchController(searchResultsController: results)
        searchController?.dimsBackgroundDuringPresentation = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        searchController?.searchBar.placeholder = "Search who said it or who heard it"
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.delegate = self
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.backgroundColor = UIColor.white
        definesPresentationContext = true
        
    }

    /// Fetches the quotes associated with the login user. NOTE: this only fetches the quotes that the user said or heard
    @objc private func fetchFeed() {
        self.quotes.removeAll()
        FirebaseService.getCurrentUser { (user) in
            QuoteService.fetchQuotes(user: user) { (quotes) in
                self.quotes = quotes
                self.quotes.sort { (q1, q2) -> Bool in
                    return q1.creationDate.compare(q2.creationDate) == .orderedDescending
                }
                DispatchQueue.main.async {
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
                    self.collectionView.reloadData()
                    self.collectionView.performBatchUpdates {
                        // Custom animation on reload
                        if let cells = self.collectionView?.orderedVisibleCells {
                            UIView.animate(views: cells, animations: [AnimationType.zoom(scale: 0.9)])
                        }
                    } completion: { (result) in
                        // do something
                    }

                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // If there are no quotes to be shown, show an empty state
        if quotes.count == 0 {
            let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellId, for: indexPath) as! EmptyStateCell
            return emptyCell
        }

        // Otherwise, render the quote cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeViewCell
        cell.quote = quotes[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quotes.count == 0 ? 1 : quotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        /*
         Dynamic sizing for each cell, based on the size and height of the quote's text and the number
         of people who heard the quote, plus the padding of each subView and their respective heights
         */
        if quotes.count != 0 {
            let label = UILabel(frame: CGRect.zero)
            label.text = quotes[indexPath.item].text
            label.sizeToFit()
            
            let heardLabel = UILabel(frame: CGRect.zero)
            heardLabel.text = quotes[indexPath.item].heardByString
            heardLabel.sizeToFit()
        
            
            return CGSize(width: view.frame.width, height: estimateFrameSize(text: quotes[indexPath.item].text).height + estimateFrameSize(text: quotes[indexPath.item].heardByString).height + 50)
        } else {
            return CGSize(width: view.frame.width, height: collectionView.frame.height)
        }
    }
    
    /// Helper function that estimates the frame size of a given text
    fileprivate func estimateFrameSize(text: String) -> CGRect {
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedString.Key: UIFont.systemFont(ofSize: 16, weight: .regular)], context: nil)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
}


// MARK: Functions that handle the search bar
extension HomeViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.queriedQuotes.removeAll()
        
        // Throttling to prevent excessive updates to the search results
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchController.searchBar)
        perform(#selector(self.reload(_:)), with: searchController.searchBar, afterDelay: 0.75)
        
    }
    
    
    /// Custom reload function that refreshes the search results for the search bar
    @objc func reload(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {return}
        if text.count == 0 {
            self.queriedQuotes.removeAll()
            updateSearchResultsController(searchText: text)
        } else if text.count > 1 {
            FirebaseService.getCurrentUser { (user) in
                QuoteService.fetchQuotes(with: text, user: user) { (quotes) in
                    self.queriedQuotes = quotes
                    self.updateSearchResultsController(searchText: text)
                }
            }
        }
    }
    
    /// Updates the search results controller and refreshes with an animation
    private func updateSearchResultsController(searchText: String) {
        guard let resultsController = self.searchController?.searchResultsController as? HomeViewResultsController else {return}
        resultsController.quotes = self.queriedQuotes
        resultsController.searchText = searchText
        resultsController.collectionView?.reloadData()
        self.collectionView.performBatchUpdates {
            if let cells = self.collectionView?.orderedVisibleCells {
                UIView.animate(views: cells, animations: [AnimationType.zoom(scale: 0.9)])
            }
        } completion: { (result) in
            // do something
        }
    }
    
    
}
