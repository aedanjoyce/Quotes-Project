//
//  QuoteReviewController.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/23/21.
//

import UIKit
import Firebase
import AddressBook
import ContactsUI


/// Protocol that handles custom actions for the quote review step
protocol QuoteReviewControllerDelegate: class {
    
    /// Function that sets the name to the selected button
    func handleContactSelected(contact: CNContact)
    
}


class QuoteReviewController: UIViewController, CNContactPickerDelegate, QuoteReviewControllerDelegate {
    
    private var saidByUser: String?
    private var saidByContact: CNContact?
    var quote: String!
    private var creationDate: Date? {
        didSet {
            self.isFormValid()
        }
    }
    private var heardByContacts = [CNContact]()
    private var heardByUsers = [String]()
    
    
    
    private let saidLabel: UILabel = {
       let label = UILabel()
        label.textColor = .quotesRed
        label.text = "Said"
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    private lazy var saidButton: QuoteCustomButton = {
        let button = QuoteCustomButton(backgroundColor: .customMidGrey, textColor: .darkGray)
        button.setTitle("One of your contacts...", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(handleContactSaid), for: .touchUpInside)
        return button
    }()
    
    private let heardLabel: UILabel = {
       let label = UILabel()
        label.textColor = .quotesRed
        label.text = "Heard"
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    private lazy var heardButton: QuoteCustomButton = {
        let button = QuoteCustomButton(backgroundColor: .customMidGrey, textColor: .darkGray)
        button.setTitle("One or more of your contacts...", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(handleContactHeard), for: .touchUpInside)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        return button
    }()
    
    private let whenLabel: UILabel = {
       let label = UILabel()
        label.textColor = .quotesRed
        label.text = "When"
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    private lazy var monthButton: QuoteCustomButton = {
        let button = QuoteCustomButton(backgroundColor: .customMidGrey, textColor: .darkGray)
        button.setTitle("MM", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(handleDate), for: .touchUpInside)
        return button
    }()
    
    private lazy var dayButton: QuoteCustomButton = {
        let button = QuoteCustomButton(backgroundColor: .customMidGrey, textColor: .darkGray)
        button.setTitle("DD", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(handleDate), for: .touchUpInside)
        return button
    }()
    
    private lazy var yearButton: QuoteCustomButton = {
        let button = QuoteCustomButton(backgroundColor: .customMidGrey, textColor: .darkGray)
        button.setTitle("YYYY", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(handleDate), for: .touchUpInside)
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
       let picker = UIDatePicker()
        picker.date = Date()
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var quoteLabel: UILabel = {
       let label = UILabel()
        label.text = self.quote
        label.font = UIFont.systemFontItalic(size: 22, fontWeight: .medium)
        label.textColor = .quotesRed
        label.numberOfLines = 0
        
        return label
    }()
    
    /// Handles the changing of the date from the date picker
    @objc func datePickerChanged(picker: UIDatePicker) {
        let components = picker.calendar.dateComponents([.era, .year, .month, .day],
                                                    from: picker.date)
        monthButton.setTitle("\(components.month ?? 0)", for: .normal)
        dayButton.setTitle("\(components.day ?? 0)", for: .normal)
        yearButton.setTitle("\(components.year ?? 0)", for: .normal)
        self.creationDate = picker.date
    }
    
    private var pickerIsSelected = false
    
    /// Toggles the date picker
    @objc private func handleDate() {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) {
                self.datePicker.alpha = self.pickerIsSelected == false ? 1 : 0
            } completion: { (result) in
                
            }
        pickerIsSelected = !pickerIsSelected
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Review"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleConfirm))
        navigationItem.leftBarButtonItem?.tintColor = .quotesRed
        navigationItem.rightBarButtonItem?.tintColor = .quotesRed
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDate))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        setupViews()
    }
    
    private func setupViews() {
        
        let labelStack = UIStackView(arrangedSubviews: [saidLabel, heardLabel, whenLabel])
        labelStack.axis = .vertical
        labelStack.distribution = .fillEqually
        view.addSubview(labelStack)
        labelStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, centerX: nil, centerY: nil, paddingTop: 24, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: view.frame.height / 2.5)
        
        
        
        let dateStack = UIStackView(arrangedSubviews: [monthButton, dayButton, yearButton])
        dateStack.axis = .horizontal
        dateStack.distribution = .fillEqually
        dateStack.spacing = 16
        
        view.addSubview(saidButton)
        saidButton.anchor(top: nil, left: saidLabel.rightAnchor, bottom: nil, right: view.rightAnchor, centerX: nil, centerY: saidLabel.centerYAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 65)
        
        view.addSubview(heardButton)
        heardButton.anchor(top: nil, left: heardLabel.rightAnchor, bottom: nil, right: view.rightAnchor, centerX: nil, centerY: heardLabel.centerYAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 65)
        
        view.addSubview(dateStack)
        dateStack.anchor(top: nil, left: whenLabel.rightAnchor, bottom: nil, right: view.rightAnchor, centerX: nil, centerY: whenLabel.centerYAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 16, width: 0, height: 65)
        
        view.addSubview(quoteLabel)
        quoteLabel.anchor(top: labelStack.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, centerX: nil, centerY: nil, paddingTop: 6, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)
        
        
        
        view.addSubview(datePicker)
        datePicker.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, centerX: nil, centerY: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 200)
        datePicker.alpha = 0
        navigationItem.rightBarButtonItem?.isEnabled = false
         
    }
    
    // Handles the selection of a contact
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        
        if contacts.count == 0 {return}
        
        var user_string = ""
        var counter = 0
        self.heardByUsers.removeAll()
        self.heardByContacts.removeAll()
        self.heardByContacts = contacts
        for contact in contacts {
            self.heardByUsers.append("\(contact.givenName) \(contact.familyName)")
            
            if counter == contacts.count - 1 {
                user_string += "\(contact.givenName) \(contact.familyName)"
            } else {
                user_string += "\(contact.givenName) \(contact.familyName), "
            }
            counter += 1
        }
        
        DispatchQueue.main.async {
            self.heardButton.setTitle(user_string, for: .normal)
            self.isFormValid()
        }
        
        
    }
    
    func isFormValid() {
        let isValid = saidButton.titleLabel?.text != "One of your contacts..." && heardButton.titleLabel?.text != "One or more of your contacts..." && monthButton.titleLabel?.text != "MM"
        navigationItem.rightBarButtonItem?.isEnabled = isValid
    }
    
    
    
    @objc private func handleContactSaid() {
        let contactPicker = SingularContactPicker()
        contactPicker.quoteReviewDelegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    @objc private func handleContactHeard() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    @objc func handleDismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Creates quote
    @objc func handleConfirm() {
        guard let saidByContact = saidByContact, let saidByUser = saidByUser, let creationDate = creationDate else {return}
        QuoteService.createQuote(quote: quote, saidBy: saidByContact, heardBy: self.heardByContacts, creationDate: creationDate) { (result) in
            if result == true {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
}

//MARK: Extension that handles custom delegate methods
extension QuoteReviewController {
    func handleContactSelected(contact: CNContact) {
        DispatchQueue.main.async {
            self.saidByUser = "\(contact.givenName) \(contact.familyName)"
            self.saidButton.setTitle("\(contact.givenName) \(contact.familyName)", for: .normal)
            self.isFormValid()
            self.saidByContact = contact
        }
    }
    
}


/// Custom class that allows only one contact to be selected, instead of multiple
class SingularContactPicker: CNContactPickerViewController, CNContactPickerDelegate {
    
    weak var quoteReviewDelegate: QuoteReviewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        quoteReviewDelegate?.handleContactSelected(contact: contact)
    }
    
}




