//
//  PhoneCodeController.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/21/21.
//

import UIKit
import Firebase

// MARK: Verification controller that handles code sent to phone to verify phone number

class PhoneCodeController: OnboardingBaseController, UITextFieldDelegate {
    
    
    var phoneNumberFormatted: String!
    let subLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = "Enter the password for this account. If it exists, we will sign you in. If not, we will create a new account"
        return label
    }()
    
    lazy var phoneField: UITextField = {
        let field = UITextField()
        field.keyboardType = UIKeyboardType.phonePad
        field.placeholder = "Enter password (at least 6 characters)"
        field.backgroundColor = .customLightGrey
        field.textColor = .black
        field.setLeftPaddingPoints(12)
        field.textContentType = .telephoneNumber
        field.layer.cornerRadius = 10
        field.isSecureTextEntry = true
        field.textAlignment = .center
        return field
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneField.layer.cornerRadius = 20
        phoneField.delegate = self
        phoneField.becomeFirstResponder()
        phoneField.inputAccessoryView = containerView
        
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.black
        attributes[.font] = UIFont.systemFont(ofSize: 22, weight: .heavy)
        let attributedText = NSMutableAttributedString(string: "Enter password for \n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .medium) , NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedText.append(NSAttributedString(string: "\(phoneNumberFormatted ?? "")", attributes: attributes))
        
        titleLabel.attributedText = attributedText
        
        
        view.backgroundColor = .white
        view.addSubview(subLabel)
        subLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: titleLabel.rightAnchor, centerX: nil, centerY: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        view.addSubview(phoneField)
        phoneField.anchor(top: subLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: view.rightAnchor, centerX: nil, centerY: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 0, height: 65)
        signUpButton.setTitle("Submit", for: .normal)
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(handleBackButton))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc func handleBackButton() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    // Checks if phone number is valid
    @objc func isFormValid() {
        guard let count = phoneField.text?.count else {return}
        self.signUpButton.setButtonState(isActive: count >= 6 ? true: false)
    }
    
    //Handles button tap and checks if account exists. If it does, user is signed in. If not, a new account is created
    override func buttonAction() {
        guard let count = phoneField.text?.count else {return}
        guard let password = phoneField.text else {return}
        signUpButton.setButtonState(isActive: false)
        signUpButton.showLoader(style: .white)
        if count >= 6 {
            let number = UserDefaults.standard.value(forKey: "authPhoneNumber") as! String
                    // user exists. Sign in user
                    OnboardingService.signInUser(number: number, password: password) { (result) in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                                self.signUpButton.setButtonState(isActive: true)
                                self.signUpButton.hideLoader()
                                self.view.isUserInteractionEnabled = true
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                self.showAlertLabel(title: "Uh oh!", message: error?.localizedDescription)
                                self.signUpButton.setButtonState(isActive: true)
                                self.signUpButton.hideLoader()
                                self.view.isUserInteractionEnabled = true
                            }
                        case .userDoesntExist:
                            // user doesn't exist. Create Account
                            OnboardingService.createUser(number: number, password: password) { (result) in
                                if result == true {
                                    DispatchQueue.main.async {
                                        self.signUpButton.setButtonState(isActive: true)
                                        self.signUpButton.hideLoader()
                                        let nameController = NameController()
                                        self.navigationController?.pushViewController(nameController, animated: true)
                                    }
                                }
                            }
                        }
                        
                    }
                
            
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isFormValid()
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        isFormValid()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        isFormValid()
    }
}

