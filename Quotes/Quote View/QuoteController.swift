//
//  QuoteController.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/22/21.
//

import UIKit
import Firebase

class QuoteController: UIViewController, UITextViewDelegate {
    
    lazy private var inputField: UITextView = {
       let field = UITextView()
        field.textColor = .white
        field.backgroundColor = .clear
        field.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        field.delegate = self
        return field
    }()
    
    
    /// Limit the number of characters to be typed as a quote
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 120    // 120 Limit Value
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let value = 120  - textView.text.count
        characterCountLabel.text = "\(value)"
        isFormValid()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isFormValid()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        isFormValid()
    }

    
    private var submitButton = QuoteCustomButton(backgroundColor: UIColor.quotesRed, textColor: .white)
    private var characterCountLabel: UILabel = {
       let label = UILabel()
        label.textColor = .quotesRed
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = "120"
        return label
    }()
    
    /// Custom input accessory view that handles the submit of a quote typed by the user
    lazy private var containerView: UIView = {
        var containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 65))
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(submitButton)
        submitButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, centerX: nil, centerY: containerView.centerYAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 110, height: 50)
        submitButton.layer.cornerRadius = 12
        submitButton.setTitle("Quote it", for: .normal)
        submitButton.setButtonState(isActive: false)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        containerView.addSubview(characterCountLabel)
        characterCountLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: nil, centerX: nil, centerY: containerView.centerYAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        
        return containerView
    }()
    
    private func isFormValid() {
        guard let count = inputField.text?.count else {return}
        self.submitButton.setButtonState(isActive: count > 0 ? true: false)
    }
    
    @objc private func handleSubmit() {
        self.view.endEditing(true)
        let quoteReviewController = QuoteReviewController()
        quoteReviewController.quote = self.inputField.text
        self.navigationController?.pushViewController(quoteReviewController, animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(inputField)
        inputField.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, centerX: nil, centerY: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        inputField.becomeFirstResponder()
        inputField.inputAccessoryView = containerView
        inputField.delegate = self
    }
    
    private func setupNavigationBar() {
        view.backgroundColor = .quotesRed
        navigationItem.title = "Quotes"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.titleView?.tintColor =  .white
        navigationItem.titleView?.backgroundColor = .white
    }
    
    @objc private func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    
    
}
