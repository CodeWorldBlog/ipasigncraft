//
//  KeychainService.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 19/03/26.
//

import Foundation

enum KeychainError: Error, LocalizedError {
    case locked
    case noCertificates
    case unlockFailed
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .locked:
            return "Keychain is locked. Please unlock it."
        case .noCertificates:
            return "No signing certificates found."
        case .unlockFailed:
            return "Failed to unlock keychain. Check password."
        case .unknown(let message):
            return message
        }
    }
}

struct KeychainService {

    // MARK: - Fetch Certificates
    static func fetchCertificates() throws -> [SigningCertificate] {
        let result = try ShellExecutor.runWithOutput("""
        security find-identity -v -p codesigning
        """)
        let output = result.output
        // Detect locked keychain
        if output.contains("User interaction is not allowed") {
            throw KeychainError.locked
        }

        // Parse certificates
        let names = output
            .components(separatedBy: "\n")
            .compactMap { line -> String? in

                guard let start = line.firstIndex(of: "\""),
                      let end = line.lastIndex(of: "\""),
                      start < end else { return nil }

                return String(line[line.index(after: start)..<end])
            }

        if names.isEmpty {
            throw KeychainError.noCertificates
        }

        return names.map { SigningCertificate(name: $0) }
    }

    // MARK: - Unlock Keychain (Optional)

    static func unlockKeychain(password: String) throws {

        let command = """
        security unlock-keychain -p '\(password)' ~/Library/Keychains/login.keychain-db
        """

        let result = try ShellExecutor.runWithOutput(command)
        let output = result.output
        if output.contains("The user name or passphrase you entered is not correct") {
            throw KeychainError.unlockFailed
        }
    }

    // MARK: - Retry Fetch After Unlock

    static func fetchCertificatesAfterUnlock(password: String) throws -> [SigningCertificate] {
        try unlockKeychain(password: password)
        return try fetchCertificates()
    }
}
