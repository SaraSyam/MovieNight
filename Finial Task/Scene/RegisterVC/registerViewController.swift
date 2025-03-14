//
//  registerViewController.swift
//  Finial Task
//
//  Created by Sara Syam on 24/11/2024.
//

import UIKit
import Foundation
import FirebaseAuth
import CoreData
import Firebase
import FirebaseCore
import GoogleSignIn
import Network

class registerViewController: UIViewController {

    
    @IBOutlet weak var registerTitleLabel: UILabel!
    @IBOutlet weak var registerTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmLabelButton: UIButton!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var orContinueLabel: UILabel!
    @IBOutlet weak var appleLabelButton: UIButton!
    @IBOutlet weak var googleLabelButton: UIButton!
    @IBOutlet weak var byLoginLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkMonitor.shared.startMonitoring() // Start monitoring network status
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name("languageChanged"), object: nil)
        let currentLanguage = UserDefaults.standard.string(forKey: "language") ?? NSLocale.preferredLanguages.first ?? "en"
        updateLanguage(language: currentLanguage)
        let language = UserDefaults.standard.string(forKey: "language") ?? "en"
        if language == "ar" {
            registerTextField.textAlignment = .right
            registerTextField.semanticContentAttribute = .forceRightToLeft
            genderTextField.textAlignment = .right
            genderTextField.semanticContentAttribute = .forceRightToLeft
            countryTextField.textAlignment = .right
            countryTextField.semanticContentAttribute = .forceRightToLeft
            emailTextField.textAlignment = .right
            emailTextField.semanticContentAttribute = .forceRightToLeft
            passwordTextField.textAlignment = .right
            passwordTextField.semanticContentAttribute = .forceRightToLeft
            confirmPasswordTextField.textAlignment = .right
            confirmPasswordTextField.semanticContentAttribute = .forceRightToLeft
        } else {
            registerTextField.textAlignment = .left
            registerTextField.semanticContentAttribute = .forceLeftToRight
            genderTextField.textAlignment = .left
            genderTextField.semanticContentAttribute = .forceLeftToRight
            countryTextField.textAlignment = .left
            countryTextField.semanticContentAttribute = .forceLeftToRight
            emailTextField.textAlignment = .left
            emailTextField.semanticContentAttribute = .forceLeftToRight
            passwordTextField.textAlignment = .left
            passwordTextField.semanticContentAttribute = .forceLeftToRight
            confirmPasswordTextField.textAlignment = .left
            confirmPasswordTextField.semanticContentAttribute = .forceLeftToRight
        }
        // Add a tap gesture recognizer to the gender text field
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(genderTextFieldTapped))
         genderTextField.addGestureRecognizer(tapGesture)
         genderTextField.inputView = UIView() //prevents keyboard from showing
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NetworkMonitor.shared.stopMonitoring() // Stop monitoring when view disappears
    }
    
    func showAlert(title: String, message: String) {
        // Show an alert to the user
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
       present(alert, animated: true, completion: nil)
    }
    
    @objc func languageChanged(_ notification: Notification) {
        if let language = notification.userInfo?["language"] as? String {
            updateLanguage(language: language)
            if language == "ar" { // Replace "ar" with your right-to-left language code
                view.semanticContentAttribute = .forceRightToLeft
            } else {
                view.semanticContentAttribute = .forceLeftToRight
            }
        }
    }
    func updateLanguage(language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            print("Error: Could not find language resource for \(language)")
            return
        }
        let bundle = Bundle(path: path)!
        registerTitleLabel.text = NSLocalizedString("Register",bundle: bundle, comment: "")
        registerTextField.placeholder = NSLocalizedString("Your Name", bundle: bundle, comment: "")
        genderTextField.placeholder = NSLocalizedString("Gender", bundle: bundle, comment: "")
        countryTextField.placeholder = NSLocalizedString("Country", bundle: bundle,comment: "")
        emailTextField.placeholder = NSLocalizedString("Email", bundle: bundle, comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", bundle: bundle, comment: "")
        confirmPasswordTextField.placeholder = NSLocalizedString("Confirm Password", bundle: bundle, comment: "")
        confirmLabelButton.setTitle(NSLocalizedString("Confirm", bundle: bundle, comment: ""), for: .normal)
        orContinueLabel.text = NSLocalizedString("or continue with",bundle: bundle, comment: "")
        googleLabelButton.setTitle(NSLocalizedString("Google", bundle: bundle, comment: ""), for: .normal)
        appleLabelButton.setTitle(NSLocalizedString("Apple", bundle: bundle, comment: ""), for: .normal)
        byLoginLabel.text = NSLocalizedString("By sign in or sign up, you agree to our Terms of Service and Privacy Policy",bundle: bundle, comment: "")
        navigationItem.title = NSLocalizedString("Register",bundle: bundle, comment: "")
    }
    
    @IBAction func didTapConfirm(_ sender: Any) {
        guard let name = registerTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty, password == confirmPassword
        else {
            showAlert(
                title: "Your details is missing",
                message: "You should enter all fields correctly"
            )
            return
        }
        let hashedPassword = hashPassword(password: password)
        guard let hashedPassword = hashedPassword else {
            print("Error: Could not hash password.")
            showAlert(title: "Registration Error", message: "An error occurred during registration.")
            return
        }
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", emailTextField.text!)
        do {
            let existingUsers = try context?.fetch(fetchRequest)
            if let _ = existingUsers?.first {
                showAlert(title: "Error", message: "A user with this email already exists.")
                return
            }

            let newUser = User(context: context!) // Now 'context' is guaranteed to be valid
            newUser.userName = registerTextField.text
            newUser.email = emailTextField.text
            newUser.password = hashedPassword // Hashed password
            newUser.gender = genderTextField.text
            newUser.country = countryTextField.text
            newUser.timeStamp = Date()
            
            try context?.save()
            showSuccessAndNavigate()

        } catch let error as NSError {
            if error.code == 1550 { // Check for constraint violation
                showAlert(title: "Error", message: "A user with this email already exists.")
            } else {
                print("Error saving/fetching user: \(error)")
                showAlert(title: "Registration Error", message: "Failed to save user.")
            }
        }
        if NetworkMonitor.shared.isConnected {
        Auth.auth().createUser(withEmail: email, password: password){ [weak self] authResult, error in
            guard let self = self else { return }
            if error != nil {
                let alert = UIAlertController(title: "data is not valid", message: "you must enterd valid password,email", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            guard (authResult?.user) != nil else { return }
            saveUser(name: name, email: email, password: password)
        }
        } else {
            // No internet connection, show an alert or handle offline behavior
            showAlert(title: "Offline", message: "Internet connection is required to register.")
        }
    }
    private func showGenderPicker() {
        let alert = UIAlertController(
            title: NSLocalizedString("select_gender", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("male", comment: ""),
            style: .default) { [weak self] _ in
                self?.genderTextField.text = NSLocalizedString("male", comment: "")
            })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("female", comment: ""),
            style: .default) { [weak self] _ in
                self?.genderTextField.text = NSLocalizedString("female", comment: "")
            })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel
        ))
        
        present(alert, animated: true)
    }
    
    private func saveUser(name: String, email: String, password: String) {
        guard let context = self.context else { return }

        // Check if a user with this email already exists
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let existingUsers = try context.fetch(fetchRequest)
            if let existingUser = existingUsers.first {
                // User already exists, update their details (if needed)
                existingUser.userName = name
                existingUser.password = password // Hash this in real app
                existingUser.timeStamp = Date()
                existingUser.gender = genderTextField.text
                existingUser.country = countryTextField.text
                print("User updated")

            } else {
                // User doesn't exist, create a new user
                let newUser = User(context: context)
                newUser.userName = name
                newUser.email = email
                newUser.password = password // Hash this in real app
                newUser.timeStamp = Date()
                newUser.gender = genderTextField.text
                newUser.country = countryTextField.text
                print("New user saved")
            }

            try context.save()
            showSuccessAndNavigate()

        } catch {
            print("Error saving/fetching user: \(error)")
            showAlert(title: "registration error title", message: "registration error message")
        }
    }
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(
            title: NSLocalizedString(title, comment: ""),
            message: NSLocalizedString(message, comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("ok", comment: ""),
            style: .default,
            handler: completion
        ))
        present(alert, animated: true)
    }
    private func showSuccessAndNavigate() {
        showAlert(title: "Registration Successful", message: "Welcome to the App please Login!") { [weak self] _ in
          guard let self = self else { return }
            let OnBoarding = onboardingViewController()
          self.navigationController?.pushViewController(OnBoarding, animated: true)
        }
    }
    
    @IBAction func genderTextFieldTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Select Gender", message: nil, preferredStyle: .actionSheet)

         alert.addAction(UIAlertAction(title: "Male", style: .default, handler: { (_) in
             self.genderTextField.text = "Male"
         }))

         alert.addAction(UIAlertAction(title: "Female", style: .default, handler: { (_) in
             self.genderTextField.text = "Female"
         }))

         alert.addAction(UIAlertAction(title: "Other", style: .default, handler: { (_) in
             self.genderTextField.text = "Other"
         }))

         alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

         self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func navButton(_ sender: Any) {
        let VC = onboardingViewController()
        navigationController?.pushViewController(VC, animated: true)
    }
    
    
    private lazy var context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Could not get app delegate")
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }()
}

