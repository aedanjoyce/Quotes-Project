### Quotes: Raya Hack Project

#### By Aedan Joyce

##### This ReadMe file will cover how to run the project, choices of architectural design, and other useful comments about the project



#### Setup

1. Clone the project to your Desktop
2. Install the podfile by opening terminal and navigating to the project's directory. Then run:
   - pod deintegrate
   - pod install
3. Open the Quotes.xcworkspace file
4. Choose to run on either a simulator device or a connected iPhone
5. Then you can start using the app! **Note: if you are using a simulator and are testing the app with the app's contacts. Avoid using the contact Kate for any of the fields, as this contact only has emails and no phone number, causing strange behaviors with the app**

#### Project Structure, Architectural Design, and Engineering Choices

##### Project Structure

- The app is built using Swift and the backend used is Google's Firestore. 
- The app is entirely built programatically - no storyboards are used
- The third party libraries used are Googles Firestore (for networking) and ViewAnimator (for some nifty animations throughout the app)

- The entire codebase follows the MVC design pattern. Networking logic is seperated into its own service layer for each aspect of the app. For example, for submitting and fetching quotes, all the networking logic can be found in 'QuoteService.swift'

##### Explanation of Data Structures:

The app has two main data structures used. One to persist and handle **Users**, and the other to handle the creation and fetching of **Quotes**. In most cases, users and their quotes/information are retrieved by their phone number, since phone numbers are unique identifiers

**Quotes**:

| Parameter             | Reason                                                       |
| --------------------- | ------------------------------------------------------------ |
| user: User?           | The user associated with the quote                           |
| text: String          | The quote's text                                             |
| saidBy: String        | The phone number associated with the user who said the quote, in string form. Which can then be used to retrieve the user's information |
| heardBy: [String]     | An array of phone numbers who heard the quote, which can be used to retrieved each respective user's information, such as their name |
| creationDate: Date    | The creation date of the quote                               |
| heardByString: String | A string of all the users who heard the quote. This property is used to dynamically calculate the size of the string of people, and then use this value as the height of each collectionView cell on the feed |

**Users:**

| Parameter               | Reason                                        |
| ----------------------- | --------------------------------------------- |
| uid: String             | Personal identifier associated with this user |
| name: String            | Name of user                                  |
| profileImageUrl: String | The URL of the user's profile image           |
| phone_number: String    | The user's phone number                       |

