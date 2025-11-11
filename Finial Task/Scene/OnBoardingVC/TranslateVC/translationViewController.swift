//
//  translationViewController.swift
//  Finial Task
//
//  Created by Sara Syam on 23/11/2024.
//

import UIKit

class translationViewController: UIViewController {
    
    @IBOutlet weak var chooseLanguageLabel: UILabel!
    @IBOutlet weak var arabicLabel: UILabel!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var arabicButton: UIButton!
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var isArabicSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentLanguage = UserDefaults.standard.string(forKey: "language") ?? NSLocale.preferredLanguages.first
        if currentLanguage == "ar" {
            isArabicSelected = true
            updateLanguage(language: "ar")
        } else {
            isArabicSelected = false
            updateLanguage(language: "en")
        }
        let systemLanguage = Locale.current.language.languageCode?.identifier
        isArabicSelected = systemLanguage == "ar"
        updateLanguage(language: systemLanguage!)
        presentationController?.delegate = self
        
    }
    
    
    @IBAction func arabicButtonTapped(_ sender: UIButton) {
        if !isArabicSelected {
            sender.setImage(UIImage(named: "selectedImage"), for: .normal)
            arabicLabel.textColor = UIColor(named: "mainColor")
            englishButton.setImage(UIImage(named: "unSelectedImage"), for: .normal)
            englishLabel.textColor = .gray
            isArabicSelected = true
            UserDefaults.standard.set("ar", forKey: "language")
            updateLanguage(language: "ar")
            LocalizationManager.shared.setLanguage("ar")
            
        }
    }
    
    @IBAction func englishButtonTapped(_ sender: UIButton) {
        if isArabicSelected {
            sender.setImage(UIImage(named: "selectedImage"), for: .normal)
            englishLabel.textColor = UIColor(named: "mainColor")
            arabicButton.setImage(UIImage(named: "unSelectedImage"), for: .normal)
            arabicLabel.textColor = .gray
            isArabicSelected = false
            UserDefaults.standard.set("en", forKey: "language")
            updateLanguage(language: "en")
            print("\(String(describing: updateLanguage))")
            LocalizationManager.shared.setLanguage("en")
        }
    }
    
    @IBAction func confirmButton(_ sender: Any) {
        if let blurView = self.presentingViewController?.view.subviews.last as? BlurEffectView {
            UIView.animate(withDuration: 0.3, animations: {
                blurView.alpha = 0
            }, completion: { _ in
                blurView.removeFromSuperview()
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        NotificationCenter.default.post(name: .translationViewControllerDismissed, object: nil)
        
    }
    func updateLanguage(language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            print("Error: Could not find language resource for \(language)")
            return
        }
        let bundle = Bundle(path: path)!
        
        chooseLanguageLabel.text = NSLocalizedString("Choose language", bundle: bundle, comment: "")
        arabicLabel.text = NSLocalizedString("Arabic", bundle: bundle, comment: "")
        englishLabel.text = NSLocalizedString("English", bundle: bundle, comment: "")
        confirmButton.setTitle(NSLocalizedString("Confirm", bundle: bundle, comment: ""), for: .normal)
        NotificationCenter.default.post(name: Notification.Name("languageChanged"), object: nil, userInfo: ["language": language])
    }
}

extension Notification.Name {
    static let translationViewControllerDismissed = Notification.Name("translationViewControllerDismissed")
}

extension translationViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        NotificationCenter.default.post(name: .translationViewControllerDismissed, object: nil)
    }
}
