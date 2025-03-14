//
//  profileViewController.swift
//  Finial Task
//
//  Created by Sara Syam on 25/11/2024.
//

import UIKit
import CoreData

class profileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let languageManager = LocalizationManager.shared
    let profileIconArray = [UIImage(named: "home"),UIImage(named: "ticket"),UIImage(named: "Icon"),UIImage(named: "exit")]
    //    var descriptionArray = [
    //        NSLocalizedString("Home", comment: ""),
    //        NSLocalizedString("My Ticket", comment: ""),
    //        NSLocalizedString("Change language", comment: ""),
    //        NSLocalizedString("Logout", comment: "")
    //    ]
    var descriptionArray = [String]() // Initialize empty array
    
    private lazy var context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Could not get app delegate")
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileUserName: UILabel!
    @IBOutlet weak var profileUserEmail: UILabel!
    @IBOutlet weak var profileTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTable.delegate = self
        profileTable.dataSource = self
        profileTable.register(UINib(nibName: "profileTableViewCell", bundle: nil), forCellReuseIdentifier: "profileTableViewCell")
        fetchUserData()
        self.tabBarController?.tabBar.isHidden = false
        loadProfileImage()
        // Make profile image circular
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true
        
        // Load descriptions based on current language (or user preference)
        let language = UserDefaults.standard.string(forKey: "language") ?? Locale.current.language.languageCode?.identifier ?? "en"
        descriptionArray = loadLocalizedDescriptions(forLanguage: language)
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil, userInfo: ["language": language])
        
    }
    
    
    @IBAction func profileEditeTappedClicked(_ sender: Any) {
        let VC = editeViewController()
        navigationController?.pushViewController(VC, animated: true)
    }
    
    private func fetchUserData() {
        guard let context = context else {
            print("Core Data context is nil. Cannot fetch user name.")
            return
        }
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        // Sort by the most recent entry
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                DispatchQueue.main.async {
                    self.profileUserName.text = user.userName
                    self.profileUserEmail.text = user.email
                    if let imageData = user.profileImageData, let image = UIImage(data: imageData) {
                        self.profileImage.image = image
                    } else {
                        // Handle the case where no profile image is saved
                        self.profileImage.image = UIImage(named: "noDataImage")
                    }
                }
            } else {
                // Handle case where no user data is found (e.g., display default values)
                DispatchQueue.main.async {
                    self.profileUserName.text = "Guest"
                    self.profileUserEmail.text = "Not Logged In"
                }
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
    
    @objc private func profileImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profileImage.image = editedImage
            saveProfileImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImage.image = originalImage
            saveProfileImage(originalImage)
        }
        
        // Ensure circle shape is maintained
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func saveProfileImage(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profileImage")
        }
    }
    
    private func loadProfileImage() {
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let savedImage = UIImage(data: imageData) {
            profileImage.image = savedImage
        }
    }
    
    private func loadLocalizedDescriptions(forLanguage language: String) -> [String] {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            print("Error: Could not find language resource for \(language)")
            return loadLocalizedDescriptions(forLanguage: "en") // Fallback to English
        }
        let bundle = Bundle(path: path)!
        return [
            NSLocalizedString("Home", bundle: bundle, comment: ""),
            NSLocalizedString("My Ticket", bundle: bundle, comment: ""),
            NSLocalizedString("Change language", bundle: bundle, comment: ""),
            NSLocalizedString("Logout", bundle: bundle,comment: "")
        ]
    }
    
    func updateLanguage(language: String) {
        languageManager.setLanguage(language)
        descriptionArray = loadLocalizedDescriptions(forLanguage: language)
        // Update other UI elements based on language
        if language == "ar" {
            // Example: Adjust layout for RTL
            profileTable.semanticContentAttribute = .forceRightToLeft
        } else {
            // Reset for LTR (if applicable)
            profileTable.semanticContentAttribute = .forceLeftToRight
        }
        profileTable.reloadData()
        // Post a notification to inform other view controllers of the language change
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil, userInfo: ["language": language])
    }
}


extension profileViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileIconArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileTableViewCell", for: indexPath)as!profileTableViewCell
        cell.ProfileIcon.image = profileIconArray[indexPath.row]
        let language = UserDefaults.standard.string(forKey: "language") ?? "en"
        if language == "ar" {
            cell.profileCellNavimg.image = UIImage(cgImage: cell.profileCellNavimg.image!.cgImage!, scale: 1.0, orientation: .down)
        } else {
            cell.profileCellNavimg.image = UIImage(cgImage: cell.profileCellNavimg.image!.cgImage!, scale: 1.0, orientation: .up)
        }
        cell.profileCellLabel.text = descriptionArray[indexPath.row] // Use localized text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row immediately
        
        switch indexPath.row {
        case 0: // Home
            // Navigate to Home View Controller
            let homeVC = homeViewController() // Instantiate your view controller
            self.navigationController?.popViewController(animated: true)
            navigationController?.pushViewController(homeVC, animated: true)
        case 1: // My Ticket
            // Navigate to Ticket View Controller
            let ticketVC = ticketViewController() // Instantiate your view controller
            self.navigationController?.popViewController(animated: true)
            navigationController?.pushViewController(ticketVC, animated: true)
        case 2: // Change Language
            let actionSheet = UIAlertController(title: "Change Language", message: "Select your preferred language", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Arabic", style: .default, handler: { _ in
                self.updateLanguage(language: "ar")
            }))
            actionSheet.addAction(UIAlertAction(title: "English", style: .default, handler: { _ in
                self.updateLanguage(language: "en")
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(actionSheet, animated: true)
            break
        case 3: // Logout
            // Handle Logout Logic
            let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                print("Logout confirmed") // Check if this is printed to the console
                
                let onboardingVC = onboardingViewController()
                let navigationController = UINavigationController(rootViewController: onboardingVC)
                guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                    fatalError("No active scene found")
                }
                scene.windows.first?.rootViewController = navigationController
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        default:
            break // Handle any other cases or do nothing
        }
    }
}
