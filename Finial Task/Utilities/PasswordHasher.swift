//
//  PasswordHasher.swift
//  FinialTask
//
//  Created by Sara Syam on 23/12/2024.
//
import CommonCrypto
import Foundation

func hashPassword(password: String) -> String? {
    guard let data = password.data(using: .utf8) else { return nil }
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress!, CC_LONG(data.count), &digest)
    }

    let hexBytes = digest.map { String(format: "%02hhx", $0) }
    return hexBytes.joined()
}
