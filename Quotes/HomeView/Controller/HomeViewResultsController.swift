//
//  HomeViewResultsController.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/26/21.
//

import UIKit
import Firebase

//MARK: Class that handles the search results for the home view
class HomeViewResultsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var quotes = [Quote]()
    weak var delegate: HomeViewControllerDelegate?
    var searchText: String?
    
    private let cellId = "cellId"
    private let emptyCellId = "emptyCellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        collectionView.register(HomeViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(EmptyStateCell.self, forCellWithReuseIdentifier: emptyCellId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // If no search results, render empty cell
        if quotes.count == 0 {
            let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellId, for: indexPath) as! EmptyStateCell
            emptyCell.subLabel.text = "No search results for \(searchText ?? "that quote"). Try another."
            return emptyCell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeViewCell
        cell.quote = quotes[indexPath.item]
        cell.delegate = self.delegate
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quotes.count == 0 ? 1 : quotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Dynamic sizing
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
    
    fileprivate func estimateFrameSize(text: String) -> CGRect {
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedString.Key: UIFont.systemFont(ofSize: 16, weight: .regular)], context: nil)
    }
    
}
