//
//  File.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 24/04/26.
//

internal import UniformTypeIdentifiers

extension UTType {
    static let ipa = UTType(importedAs: "com.apple.itunes.ipa")
    static let mobileProvision = UTType(importedAs: "com.apple.mobileprovision")
    static let p12 = UTType(importedAs: "com.rsa.pkcs-12")
}
