//
//  ViewController.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/21/21.
//

import UIKit
import Firebase

/// Details: Controller that manages each view within the application
class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 1 {
            let quoteController = UINavigationController(rootViewController: QuoteController())
            self.present(quoteController, animated: true, completion: nil)
            return false
        }
        
        
            
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAuth()
    }
    
    /*
     Checks if there is a current user logged in. If not, display sign up/login page
    */
    private func checkAuth() {
        if Auth.auth().currentUser?.uid == nil {
            // present onboarding if user is nil
            let phoneAuthController = UINavigationController(rootViewController: PhoneAuthController())
            phoneAuthController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                self.present(phoneAuthController, animated: false, completion: nil)
            }
            
        } else {
            // otherwise, setup views
            DispatchQueue.main.async {
                self.setupControllers()
            }
        }
    }
    
    /*
     Sets up each view for the tab bar
    */
    private func setupControllers() {
        let homeView = UINavigationController(rootViewController: HomeViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        homeView.tabBarItem.image = UIImage(named: "feedIcon")
        let quoteView = UINavigationController(rootViewController: UIViewController())
        quoteView.tabBarItem.image = UIImage(named: "quoteProcessIcon")
        
        let profileController = ProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        let profileView = UINavigationController(rootViewController: ProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        profileView.tabBarItem.image = UIImage(named: "ProfileIcon")
        profileController.isCurrentUser = true
        
        
        viewControllers = [homeView, quoteView, profileView]
        tabBar.isTranslucent = false
        tabBar.backgroundColor = UIColor.white
        tabBar.tintColor = UIColor(red: 0.96, green: 0.61, blue: 0.63, alpha: 1.00)
        tabBar.unselectedItemTintColor = UIColor(red:0.67, green:0.71, blue:0.75, alpha:1.0)
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0.5)
        topBorder.backgroundColor = UIColor(red:0.83, green:0.84, blue:0.85, alpha:1.0).cgColor
        tabBar.layer.addSublayer(topBorder)
        tabBar.clipsToBounds = true
        topBorder.opacity = 0.88
        removeTabbarItemsText()
    }
    
    /// Removes the tab bar text view so only the picture remains
    func removeTabbarItemsText() {

        var offset: CGFloat = 6.0

        if #available(iOS 11.0, *), traitCollection.horizontalSizeClass == .regular {
            offset = 0.0
        }

        if let items = tabBar.items {
            for item in items {
                item.title = ""
                item.imageInsets = UIEdgeInsets(top: offset, left: 0, bottom: -offset, right: 0)
            }
        }
    }


}
