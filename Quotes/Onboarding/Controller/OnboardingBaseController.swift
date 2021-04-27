//
//  OnboardingController.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/21/21.
//

import UIKit
import Firebase

//MARK: Generic class that is inherited by most controllers in the onboarding process
class OnboardingBaseController: UIViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, centerX: nil, centerY: nil, paddingTop: 90, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)
        navigationItem.setLeftBarButton(UIBarButtonItem(image: UIImage(named: "Back-Button"), style: .plain, target: self, action: #selector(dismissView)), animated: true)
        setupSignUpButton()
    }
    @objc func dismissView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setTitleLabel(title: String) {
        self.titleLabel.text = title
    }
    
    
    var containerView = UIView()
    
    lazy var signUpButton: QuoteCustomButton = {
        let button = QuoteCustomButton(backgroundColor: .quotesRed, textColor: .white)
        button.setTitle("Send Code", for: .normal)
        button.setButtonState(isActive: false)
        return button
    }()
    
    private func setupSignUpButton() {
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80))
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(signUpButton)
        signUpButton.anchor(top: nil, left: nil, bottom: containerView.bottomAnchor, right: nil, centerX: containerView.centerXAnchor, centerY: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -12, paddingRight: 0, width: containerView.frame.width - 64, height: 65)
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.containerView.alpha = 1
            //self.view.layoutIfNeeded()
        }, completion: nil)
        signUpButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    
    @objc func buttonAction() {}
    
}

//MARK: Custom button that is used across the entire code base
class QuoteCustomButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(tappedButton), for: .touchDown)
        self.addTarget(self, action: #selector(resetButton), for: .touchDragExit)
        self.addTarget(self, action: #selector(resetButton), for: .touchUpInside)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        self.layer.cornerRadius = 15
        self.addSubview(activityIndicator)
        activityIndicator.anchor(top: nil, left: nil, bottom: nil, right: nil, centerX: centerXAnchor, centerY: centerYAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        activityIndicator.alpha = 0
    }
    
    private var tColor: UIColor!
    private var bColor: UIColor!
    
    let activityIndicator: UIImageView = {
       let view = UIImageView(image: UIImage(named: "Loader-White")!)
       view.contentMode = .scaleAspectFill
       return view
    }()
    

    convenience init(backgroundColor: UIColor, textColor: UIColor) {
        self.init()
        self.tColor = textColor
        self.bColor = backgroundColor
        self.backgroundColor = backgroundColor
        self.setTitleColor(textColor, for: .normal)
    }
    
    enum LoaderStyle {
        case blue
        case white
    }
    
    func showLoader(style: LoaderStyle) {
        self.activityIndicator.image = style == .white ? UIImage(named: "Loader-White") : UIImage(named: "Loader")
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.activityIndicator.alpha = 1
            self.activityIndicator.spin(duration: 0.50)
            self.titleLabel?.alpha = 0
        }, completion: nil)
    }
    
    func hideLoader() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.activityIndicator.alpha = 0
            self.activityIndicator.stopSpinning()
            self.titleLabel?.alpha = 1
        }, completion: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Performs animation when tapping button
    @objc private func tappedButton() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    /// Resets button after being tapped
    @objc private func resetButton() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    /// Enables or disables button
    @objc func setButtonState(isActive: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            if isActive {
                self.isSelected = true
                self.backgroundColor = self.bColor
                self.setTitleColor(self.tColor, for: .normal)
                self.isEnabled = true
            } else {
                self.backgroundColor = self.bColor.withAlphaComponent(0.25)
                self.isEnabled = false
                self.isSelected = false
            }
        }, completion: nil)
    }
    
}

//MARK: Helper for activityIndicator animation

public extension UIImageView {
  func spin(duration: Double) {
    let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
      rotation.toValue = Double.pi * 2
      rotation.duration = duration // or however long you want ...
      rotation.isCumulative = true
      rotation.repeatCount = Float.greatestFiniteMagnitude
      layer.add(rotation, forKey: "rotationAnimation")
  }

  func stopSpinning() {
    layer.removeAllAnimations()
  }
}

