//
//  PhoneAuthController.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/21/21.
//

import UIKit
import Firebase

class PhoneAuthController: OnboardingBaseController, UITextFieldDelegate {
    
    let subLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = "We won't share your number with anyone. It is used simply for authentication with your account."
        return label
    }()
    
    lazy var phoneField: UITextField = {
        let field = UITextField()
        field.keyboardType = UIKeyboardType.phonePad
        field.placeholder = "+1 (555)-555-5555"
        field.backgroundColor = .customLightGrey
        field.textColor = .black
        field.setLeftPaddingPoints(12)
        field.textContentType = .telephoneNumber
        field.layer.cornerRadius = 10
        field.textAlignment = .center
        return field
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.black
        attributes[.font] = UIFont.systemFont(ofSize: 22, weight: .heavy)
        let attributedText = NSMutableAttributedString(string: "Welcome to ", attributes: attributes)
        attributedText.append(NSAttributedString(string: "Quotes! ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .heavy), NSAttributedString.Key.foregroundColor: UIColor.quotesRed.cgColor]))
        attributedText.append(NSAttributedString(string: "Please enter your phone number to begin.", attributes: attributes))
        
        titleLabel.attributedText = attributedText
        
        view.backgroundColor = .white
        view.addSubview(subLabel)
        subLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: titleLabel.rightAnchor, centerX: nil, centerY: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        view.addSubview(phoneField)
        phoneField.anchor(top: subLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: view.rightAnchor, centerX: nil, centerY: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 0, height: 65)
        phoneField.delegate = self
        phoneField.becomeFirstResponder()
        phoneField.inputAccessoryView = containerView
        signUpButton.setTitle("Continue", for: .normal)
    }
    
    // Checks if phone number is valid
    @objc func isFormValid() {
        guard let count = phoneField.text?.count else {return}
        self.signUpButton.setButtonState(isActive: count == 14 ? true: false)
    }
    
    //Handles button tap and verifies phone number with firebase
    override func buttonAction() {
        guard let text = phoneField.text else {return}
        let phoneNumber = text.filter("0123456789.".contains)
        //TODO: Fill In
        let number = phoneNumber.applyPatternOnNumbers(pattern: "+1 ###-###-####" , replacmentCharacter: "#")
        UserDefaults.standard.set(phoneNumber, forKey: "authPhoneNumber")
        
        DispatchQueue.main.async {
            let controller = PhoneCodeController()
            controller.phoneNumberFormatted = text
            self.navigationController?.pushViewController(controller, animated: true)
            self.signUpButton.setButtonState(isActive: true)
            self.signUpButton.hideLoader()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = textField.text?.applyPatternOnNumbers(pattern: "(###) ###-####", replacmentCharacter: "#")
        isFormValid()
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.text = textField.text?.applyPatternOnNumbers(pattern: "(###) ###-####", replacmentCharacter: "#")
        isFormValid()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.applyPatternOnNumbers(pattern: "(###) ###-####", replacmentCharacter: "#")
        isFormValid()
    }
    
    // Function that automatically modifies text into phone number format
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // make sure the result is under 16 characters
        return updatedText.count <= 14
    }
}
