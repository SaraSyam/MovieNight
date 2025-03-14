//
//  editeViewController.swift
//  FinialTask
//
//  Created by Sara Syam on 23/12/2024.
//

import UIKit
import Alamofire
import CoreData
import AlamofireEasyLogger

class editeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let genderPickerView = UIPickerView()
    let countryPickerView = UIPickerView()
    let genders = ["Male", "Female", "Other"]
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var currentUser: User?
    // ... other properties ...
    var countries: [Country] = []
    // Menu items for table view
    var filteredCountries: [Country] = []
    private let menuItems = [
        NSLocalizedString("email", comment: ""),
        NSLocalizedString("gender", comment: ""),
        NSLocalizedString("country", comment: "")
    ]
    
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var editeProfileImage: UIImageView!
    @IBOutlet weak var editeProfileUserName: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        genderTextField.inputView = genderPickerView
        countryTextField.inputView = countryPickerView
        title = NSLocalizedString("edit profile", comment: "")
        setupUI()
        fetchCurrentUser()
        setupProfileImage()
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.isHidden = true // Hide the tab bar when this view appears
        countryTextField.inputView = countryPickerView
        fetchCountries() // Fetch countries when the view loads
        filteredCountries = countries
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name("languageChanged"), object: nil)
        let currentLanguage = UserDefaults.standard.string(forKey: "language") ?? NSLocale.preferredLanguages.first ?? "en"
        updateLanguage(language: currentLanguage)
        

    }
    
    func searchCountries(for query: String) {
      filteredCountries = countries.filter { country in
        return country.name?.common?.lowercased().contains(query.lowercased()) ?? false
      }
      countryPickerView.reloadAllComponents()
    }
    
    // For genderPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == genderPickerView { // Check if it's the gender picker
            return genders.count
        } else { // Assume it's the country picker
            return filteredCountries.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == genderPickerView {
            // Check for out-of-bounds access for gender picker
            guard row < genders.count else {
                return nil
            }
            return genders[row]
        } else {
            if row < countries.count, let country = countries[safe: row] {
                if let countryName = country.name?.common {
                    return countryName
                }
            } else {
                print("Invalid row index for country picker: \(row)")
                // Handle the case where the row is out of bounds (e.g., disable interaction)
                return nil // Or return "Unknown Country"
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genderPickerView {
            genderTextField.text = genders[row]
            currentUser?.gender = genders[row]
            saveData()
        } else {
            if row < filteredCountries.count {
                let selectedCountry = filteredCountries[row]
                countryTextField.text = selectedCountry.name?.common
                currentUser?.country = selectedCountry.name?.common
                saveData()
            } else {
                print("Invalid row selected in country picker: \(row)")
                // Optionally display an alert to the user
                let alert = UIAlertController(title: "Error", message: "Invalid country selection.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        genderTextField.resignFirstResponder()
        countryTextField.resignFirstResponder()
    }
    
    private func showGenderPicker() {
        let alert = UIAlertController(
            title: NSLocalizedString("select gender", comment: ""),
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
            title: NSLocalizedString("other", comment: ""), // Add "Other" option
            style: .default) { [weak self] _ in
                self?.genderTextField.text = NSLocalizedString("other", comment: "")
            })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel
        ))
        
        present(alert, animated: true)
    }

    private func saveData() {
        guard let currentUser = currentUser else {
            print("Error: Current user is nil.")
            return
        }

        // Update user properties
        currentUser.userName = editeProfileUserName.text ?? ""
        currentUser.email = emailTextField.text ?? ""
        // ... (other property updates if needed)

        do {
            try context.save()
            print("User data saved successfully.")
            NotificationCenter.default.post(name: Notification.Name("UserDataUpdated"), object: nil)

        } catch {
            print("Error saving user data: \(error)")
        }
    }
    
    func fetchCountries() {
        AF.request("https://restcountries.com/v3.1/all")
            .validate()
            .responseDecodable(of: [Country].self) { response in
                switch response.result {
                case .success(let countries):
                    DispatchQueue.main.async {
                        self.countries = countries
                        self.filteredCountries = countries // Update filteredCountries initially
                        self.countryPickerView.reloadAllComponents()
                        print("Successfully fetched countries:", countries)
                    }
                case .failure(let error):
                    print("Error fetching countries: \(error)")
                    print(error.localizedDescription)
                    // Handle the error (e.g., display an error message to the user)
                }
            }
    }
    
    private func setupUI() {
        profileLabel.text = NSLocalizedString("profile", comment: "")
    }
    
    private func fetchCurrentUser() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                self.currentUser = user
                DispatchQueue.main.async {
                    // ... rest of the code ...
                    self.editeProfileUserName.text = user.userName
                    self.emailTextField.text = user.email
                    self.genderTextField.text = user.gender
                    self.countryTextField.text = user.country
                    if let imageData = user.profileImageData, let image = UIImage(data: imageData) {
                        self.editeProfileImage.image = image
                    } else {
                        // Handle the case where no profile image is saved
                        self.editeProfileImage.image = UIImage(named: "noDataImage")
                    }
                }
            } else {
                // Handle the case where no user is found
                // Handle case where no user data is found
                DispatchQueue.main.async {
                    self.editeProfileUserName.text = "Guest"
                    self.emailTextField.text = "Not Logged In"
                }
                print("No user found.")
                // You might want to display an error message to the user here
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
    
    private func setupProfileImage() {
        editeProfileImage.layer.cornerRadius = editeProfileImage.frame.width / 2
        editeProfileImage.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        editeProfileImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func profileImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            editeProfileImage.image = editedImage
            saveProfileImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            editeProfileImage.image = originalImage
            editeProfileImage.image = originalImage
            saveProfileImage(originalImage)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func saveProfileImage(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8), let user = currentUser {
            user.gender = genderTextField.text
            user.profileImageData = imageData
            do {
                try context.save()
                print("Profile image saved to Core Data successfully!")
                
                // Show a success message (optional)
                let successAlert = UIAlertController(title: "Success", message: "Profile image saved successfully!", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(successAlert, animated: true)
                
                // Update the UI immediately
                editeProfileImage.image = image
            } catch {
                print("Failed to save profile image to Core Data: \(error)")
                // Handle the error (e.g., present an alert)
                let errorAlert = UIAlertController(title: "Error", message: "Failed to save profile image.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
            }
        } else {
            print("Error: Could not save image data or user is nil.")
        }
    }
    
    private func loadProfileImage() {
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let savedImage = UIImage(data: imageData) {
            editeProfileImage.image = savedImage
        }
    }
    
    @objc func handleLanguageChange() {
           // Update UI elements
           title = NSLocalizedString("edit_profile", comment: "")
           // ... update other UI elements
       }
    
    @objc func languageChanged(_ notification: Notification) {
        if let language = notification.userInfo?["language"] as? String {
            updateLanguage(language: language)
        }
    }
    func updateLanguage(language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            print("Error: Could not find language resource for \(language)")
            return
        }
        let bundle = Bundle(path: path)!
        profileLabel.text = NSLocalizedString("profile" , bundle: bundle, comment: "")

    }
        
    @IBAction func navButton(_ sender: Any) {
        let vc = profileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension editeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      let newText = (textField.text ?? "") as NSString
      let result = newText.replacingCharacters(in: range, with: string)
      searchCountries(for: result)
      return true
    }
    
}
extension Array {
    subscript(safe index: Index) -> Element? {
        guard index >= 0 && index < endIndex else { return nil }
        return self[index]
    }
}
