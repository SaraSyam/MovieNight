// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - WelcomeElement
struct Country: Codable {
    let name: Name?
}

// MARK: - Name
struct Name: Codable {
    let common, official: String?
    let nativeName: NativeName?
}

// MARK: - NativeName
struct NativeName: Codable {
    let ara: Translation?
}

// MARK: - Translation
struct Translation: Codable {
    let official, common: String?
}

typealias Welcome = [Country]
