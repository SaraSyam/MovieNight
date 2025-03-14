//
//  myTabBarViewController.swift
//  Finial Task
//
//  Created by Sara Syam on 25/11/2024.
//
import UIKit

class myTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpTabs()
        self.tabBar.barTintColor = .black
        self.tabBar.tintColor = UIColor(named:"mainColor")
        self.tabBar.unselectedItemTintColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name("languageChanged"), object: nil)
        let currentLanguage = UserDefaults.standard.string(forKey: "language") ?? NSLocale.preferredLanguages.first ?? "en"
        updateLanguage(language: currentLanguage)
    }
    private func setUpTabs(){
        let tabBarTitles = ["Home", "Ticket", "Movie", "Profile"] // Array of keys for localized tab bar titles

        let home = self.createNav(with: tabBarTitles[0], and: UIImage(named: "home"), vc: homeViewController())
        let ticket = self.createNav(with: tabBarTitles[1], and: UIImage(named: "ticket"), vc: ticketViewController())
        let movie = self.createNav(with: tabBarTitles[2], and: UIImage(named: "video"), vc: movieViewController())
        let profile = self.createNav(with: tabBarTitles[3], and: UIImage(named: "user"), vc: profileViewController())
        
        self.setViewControllers([home,ticket,movie,profile], animated: true)
    }
    private func createNav(with titleKey: String, and image: UIImage?, vc: UIViewController) -> UINavigationController{
        let nav = UINavigationController(rootViewController: vc)

        // Get the current bundle
        let currentLanguage = UserDefaults.standard.string(forKey: "language") ?? NSLocale.preferredLanguages.first ?? "en"
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") else {
            print("Error: Could not find language resource for \(currentLanguage)")
            return nav // Use default language
        }
        let bundle = Bundle(path: path)!

        nav.tabBarItem.title = NSLocalizedString(titleKey, bundle: bundle, comment: "")
        nav.tabBarItem.image = image
        // ... (rest of the createNav function)

        return nav
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
        _ = Bundle(path: path)!
        self.setUpTabs() // Reload tab bar with updated titles
    }
}


