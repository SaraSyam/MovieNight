//
//  loginViewController.swift
//  Finial Task
//
//  Created by Sara Syam on 25/11/2024.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn
import FirebaseCore
import CoreData

class loginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmLabelButton: UIButton!
    @IBOutlet weak var orContinueWithLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var orContinueLabel: UILabel!
    @IBOutlet weak var googleLabelButton: UIButton!
    @IBOutlet weak var appleLabelButton: UIButton!
    @IBOutlet weak var byLoginLabel: UILabel!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButtonImage = UIImage(systemName:"arrow.left")?.withTintColor(.white)
        navigationItem.backBarButtonItem = UIBarButtonItem(image: backButtonImage, style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged),  name: Notification.Name("languageChanged"), object: nil)
        
        let currentLanguage = UserDefaults.standard.string(forKey: "language") ?? NSLocale.preferredLanguages.first ?? "en"
        updateLanguage(language: currentLanguage)
        let language = UserDefaults.standard.string(forKey: "language") ?? "en"
        
        if language == "ar" {
            emailTextField.textAlignment = .right
            emailTextField.semanticContentAttribute = .forceRightToLeft
            passwordTextField.textAlignment = .right
            passwordTextField.semanticContentAttribute = .forceRightToLeft
            
        } else {
            emailTextField.textAlignment = .left
            emailTextField.semanticContentAttribute = .forceLeftToRight
            emailTextField.textAlignment = .left
            emailTextField.semanticContentAttribute = .forceLeftToRight
        }
        appleLabelButton.addTarget(self, action: #selector(handleAppleSignIn),for: .touchUpInside)
    }
    
    var onLoginSuccess: (() -> Void)?
    @objc func handleAppleSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let appleIDRequest = appleIDProvider.createRequest()
        appleIDRequest.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests:[appleIDRequest])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor
    {
        return self.view.window!
    }
    func setUPProviderLoginView(){
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        // self.loginProviderStackView.addArrangedSubview(button)
    }
    
    
    @IBAction func loginByApple(_ sender: Any) {
    }
    @IBAction func loginByGoogle(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                print("ERROR: ", error.localizedDescription)
                // Handle error appropriately (e.g., show an alert)
                return
            }
            
            if let user = result?.user {
                print("User is: \(user)")
                // Use user information if needed
                if let onLoginSuccess = self.onLoginSuccess {
                    onLoginSuccess() // Correct here
                } else {
                    // This else block was the problem
                    guard let tabBarController = self.tabBarController else {
                        fatalError("TabBarController not found")
                    }
                    tabBarController.selectedIndex = 0
                }
            }
        }
    }
    @IBAction func confirmButton(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            print("Email field is empty")
            let alert = UIAlertController(title: "email is not valid", message: "you must enterd valid email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            print("password field is empty")
            let alert = UIAlertController(title: "data is not valid", message: "you must enterd valid password,email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        Auth.auth().signIn(withEmail: email, password: password){ authDate, error in
            if error != nil {
                let alert = UIAlertController(title: "data is not valid", message: "you must enterd valid password,email", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            if authDate != nil {
                if let onLoginSuccess = self.onLoginSuccess {
                    onLoginSuccess() // Call your separate function for handling success
                } else {
                    // Assuming you have a reference to your tabBarController instance (e.g., in AppDelegate)
                    guard let tabBarController = self.tabBarController else {
                        fatalError("TabBarController not found")
                    }
                    tabBarController.selectedIndex = 0 }
            }
        }
        // Create fetch request
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)
        
        do {
            let users = try context.fetch(fetchRequest)
            
            if let user = users.first {
                // Update timeStamp for the current login
                user.timeStamp = Date()
                try context.save()
            } else {
                showAlert(
                    title: "login_error",
                    message: "invalid_login_credentials"
                )
            }
        } catch {
            print("Error during login: \(error)")
            showAlert(
                title: "login_error",
                message: "login_error_message"
            )
        }
    }
    
    @IBAction func navigationBarLeft(_ sender: Any) {
        let onboardingViewController = onboardingViewController() 
        navigationController?.pushViewController(onboardingViewController, animated: true)
    }
    
    
    @IBAction func showPasswordButtonTapped(_ sender: Any) {
        passwordTextField.isSecureTextEntry.toggle()

        if passwordTextField.isSecureTextEntry {
            if let eyeSlashImage = UIImage(systemName: "eye.slash") {
                let whiteEyeSlashImage = eyeSlashImage.withTintColor(.white, renderingMode: .alwaysOriginal)
                showPasswordButton.setImage(whiteEyeSlashImage, for: .normal)
            }
        } else {
            if let eyeImage = UIImage(systemName: "eye") {
                let whiteEyeImage = eyeImage.withTintColor(.white, renderingMode: .alwaysOriginal)
                showPasswordButton.setImage(whiteEyeImage, for: .normal)
            }
        }
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
        
        let localizedStrings = ["Email", "Password", "Confirm", "or continue with", "Google", "Apple", "By sign in or sign up, you agree to our Terms of Service and Privacy Policy", "Login"]
        
        for (index, stringKey) in localizedStrings.enumerated() {
            let localizedString = NSLocalizedString(stringKey, bundle: bundle, comment: "")
            switch index {
            case 0:
                emailTextField.placeholder = localizedString
            case 1:
                passwordTextField.placeholder = localizedString
            case 2:
                confirmLabelButton.setTitle(localizedString, for: .normal)
            case 3 :
                orContinueWithLabel.text = localizedString
            case 4 :
                googleLabelButton.setTitle(localizedString, for: .normal)
            case 5 :
                appleLabelButton.setTitle(localizedString, for: .normal)
            case 6 :
                byLoginLabel.text = localizedString
            case 7 :
                loginTitle.text = localizedString
            default:
                break
            }
        }
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString(title, comment: ""),
            message: NSLocalizedString(message, comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("ok", comment: ""),
            style: .default
        ))
        present(alert, animated: true)
    }
}
extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

extension UIViewController{
    func push(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
