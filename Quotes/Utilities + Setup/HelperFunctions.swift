//
//  HelperFunctions.swift
//  Quotes
//
//  Created by Aedan Joyce on 4/21/21.
//

import UIKit

//MARK: Extension that sets custom colors to be used across the app
extension UIColor {
    open class var quotesRed: UIColor { get {return UIColor(red: 1.00, green: 0.26, blue: 0.34, alpha: 1.00)}}
    open class var customLightGrey: UIColor { get{return UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)}}
    open class var customMidGrey: UIColor { get{return UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)}}
}


extension UIViewController {
    
    /// Helper function  that shows an alert to the user
    func showAlertLabel(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK: Extension that adds padding to text fields
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}


//MARK: Extension that changes textfield text to specified pattern
extension String {
    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(encodedOffset: index)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}



extension UIView {

//MARK: Anchoring function to simplify auto layout process
func anchor(top: NSLayoutYAxisAnchor?,left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, centerX: NSLayoutXAxisAnchor?, centerY: NSLayoutYAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    if let top = top {
        self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
    }
    if let left = left {
        self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
    }
    if let bottom = bottom {
        bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
    }
    if let right = right {
        rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
    }
    if let centerX = centerX {
        centerXAnchor.constraint(equalTo: centerX).isActive = true
    }
    if let centerY = centerY {
        centerYAnchor.constraint(equalTo: centerY).isActive = true
    }
    
    if width != 0 {
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    if height != 0 {
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
    
}



// Custom Image Class with built in caching
fileprivate var imageCache = [String: UIImage]()
class CustomImageView: UIImageView {
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch post image:", err)
                return
            }
            
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            
            guard let imageData = data else { return }
            
            let photoImage = UIImage(data: imageData)
            
            imageCache[url.absoluteString] = photoImage
            DispatchQueue.main.async {
                self.image = photoImage
            }
            
            }.resume()
    }
    
}


extension Date {
    
    /// function that displays time in terms of seconds, minutes, hours, and days
    func timeDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
        
    }
    func shortenedTimeDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "s"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "m"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "h"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "d"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "w"
        } else {
            quotient = secondsAgo / month
            unit = "mon"
        }
        
        return "\(quotient)\(unit)"
    }
}


// Helper function that allows for italicized text
extension UIFont {
    static func systemFontItalic(size fontSize: CGFloat = 17.0, fontWeight: UIFont.Weight = .regular) -> UIFont {
        let font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitItalic)!, size: fontSize)
    }
}

// Class that generates a custom image with user's initials
class LetterImageGenerator: NSObject {
    func imageWith(name: String?) -> UIImage? {
    let frame = CGRect(x: 0, y: 0, width: 300, height: 300)
    let nameLabel = UILabel(frame: frame)
    nameLabel.textAlignment = .center
    nameLabel.backgroundColor = .lightGray
    nameLabel.textColor = .white
    nameLabel.font = UIFont.boldSystemFont(ofSize: 150)
    var initials = ""
    if let initialsArray = name?.components(separatedBy: " ") {
      if let firstWord = initialsArray.first {
        if let firstLetter = firstWord.first {
          initials += String(firstLetter).capitalized
        }
      }
      if initialsArray.count > 1, let lastWord = initialsArray.last {
        if let lastLetter = lastWord.first {
          initials += String(lastLetter).capitalized
        }
      }
    } else {
      return nil
    }
    nameLabel.text = initials
    UIGraphicsBeginImageContext(frame.size)
    if let currentContext = UIGraphicsGetCurrentContext() {
      nameLabel.layer.render(in: currentContext)
      let nameImage = UIGraphicsGetImageFromCurrentImageContext()
      return nameImage
    }
    return nil
  }
}

extension UITapGestureRecognizer {
    
    /// Function that allows certain ranges of a string to be selected. Used in homeView to select 'heardBy' users
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
