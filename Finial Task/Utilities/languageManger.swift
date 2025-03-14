//
//  languageManger.swift
//  FinialTask
//
//  Created by Sara Syam on 09/01/2025.
//

import Foundation
// LocalizationManager.swift
class LocalizationManager {
  static let shared = LocalizationManager()
    private var bundle: Bundle?
    private(set) var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"

    func setLanguage(_ language: String) {
      guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
        print("Error: Could not find language resource for \(language)")
        return
      }
      bundle = Bundle(path: path)!
      NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil, userInfo: ["language": language])
    }

    func localizedString(_ key: String, comment: String = "") -> String {
      guard let bundle = bundle else {
        return NSLocalizedString(key, comment: comment) // Fallback to default localization
      }
      return NSLocalizedString(key, bundle: bundle, comment: comment)
    }
  }


extension Notification.Name {
  static let languageChanged = Notification.Name("languageChanged")
}
