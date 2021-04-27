//
//  NameController.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/21/21.
//

import UIKit
import Firebase

class NameController: OnboardingBaseController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Button that allows the user to choose a photo
    lazy var photoChooser: UIButton =  {
       let button = UIButton()
        button.setImage(UIImage(named: "PhotoChooser"), for: .normal)
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handlePhoto), for: .touchUpInside)
        return button
    }()
    
    /// First name field
    lazy var firstField: UITextField = {
        let field = UITextField()
        field.keyboardType = UIKeyboardType.default
        field.placeholder = "First name"
        field.backgroundColor = .customLightGrey
        field.textColor = .black
        field.textAlignment = .center
        field.setLeftPaddingPoints(12)
        field.textContentType = .name
        return field
    }()
    
    /// Last name field
    lazy var lastField: UITextField = {
        let field = UITextField()
        field.keyboardType = UIKeyboardType.default
        field.placeholder = "Last name"
        field.backgroundColor = .customLightGrey
        field.textColor = .black
        field.textAlignment = .center
        field.setLeftPaddingPoints(12)
        field.textContentType = .familyName
        return field
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(photoChooser)
        photoChooser.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, centerX: view.centerXAnchor, centerY: nil, paddingTop: 72, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 120)
        let stack = UIStackView(arrangedSubviews: [firstField, lastField])
        view.addSubview(stack)
        stack.anchor(top: photoChooser.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, centerX: nil, centerY: nil, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 65)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 24
        firstField.layer.cornerRadius = 20
        lastField.layer.cornerRadius = 20
        firstField.delegate = self
        lastField.delegate = self
        firstField.becomeFirstResponder()
        firstField.inputAccessoryView = containerView
        lastField.inputAccessoryView = containerView
        signUpButton.setTitle("Continue", for: .normal)
    }
    
    /// Handles photo selection
    @objc func handlePhoto() {
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.inputAccessoryView?.isHidden = true
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.allowsEditing = true
                self.present(pickerController, animated: true, completion: nil)
            }
        }
    }
    
    /// Handles completion  of signup process
    override func buttonAction() {
        self.signUpButton.setButtonState(isActive: false)
        self.signUpButton.showLoader(style: .white)
        let number = UserDefaults.standard.value(forKey: "authPhoneNumber") as! String
        if let firstName = firstField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let lastName = lastField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let image = photoChooser.imageView?.image {
                
            let name = firstName + " " + lastName
            
            // Saves user info in database
            OnboardingService.setUserProperties(number: number, name: name, image: image) { (result) in
                    DispatchQueue.main.async {
                        if result == false{
                            self.showAlertLabel(title: "Uh oh!", message: "Error storing name. Please try again")
                            self.signUpButton.setButtonState(isActive: true)
                            self.signUpButton.hideLoader()
                            return
                        }
                        self.signUpButton.setButtonState(isActive: true)
                        self.signUpButton.hideLoader()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            
            } else {
                DispatchQueue.main.async {
                    self.signUpButton.setButtonState(isActive: true)
                    self.signUpButton.hideLoader()
                    self.showAlertLabel(title: "Uh oh!", message: "Something went wrong signing up. Try again.")
                }
            }
    }
    
    
    // Handles selection of new photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            photoChooser.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            photoChooser.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        photoChooser.layer.cornerRadius = photoChooser.frame.width / 2
        photoChooser.layer.masksToBounds = true
        dismiss(animated: true) {
            self.firstField.becomeFirstResponder()
        }
        self.inputAccessoryView?.isHidden = false
    }
    
    /// Checks if all forms are filled out before finishing signup
    func isFormValid() {
        guard let firstCount = firstField.text?.count, let secondCount = lastField.text?.count else {return}
        
        if firstCount > 1 && secondCount > 1 {
            signUpButton.setButtonState(isActive: true)
        } else {
            signUpButton.setButtonState(isActive: false)
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstField {
            lastField.becomeFirstResponder()
        }
        return true
    }
    
    
    
}
