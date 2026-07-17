//
//  IPAInspection.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import Foundation

/// Root inspection model representing
/// the analyzed contents of an IPA.
///
/// This model should remain UI-independent.
/// Avoid adding view formatting logic here.
struct IPAInspection {

    // MARK: - Basic Application Information

    /// Display name of the application.
    ///
    /// Example:
    /// "Instagram"
    /// "Lido mBriefing"
    let appName: String

    /// Unique bundle identifier from Info.plist.
    ///
    /// Example:
    /// "com.company.app"
    let bundleIdentifier: String

    /// Human-readable release version.
    ///
    /// CFBundleShortVersionString
    ///
    /// Example:
    /// "5.2"
    let version: String

    /// Internal build number.
    ///
    /// CFBundleVersion
    ///
    /// Example:
    /// "402"
    let buildNumber: String

    // MARK: - Signing Information

    /// Apple Developer Team Identifier
    /// extracted from provisioning profile
    /// or code signature.
    ///
    /// Example:
    /// "ABCDE12345"
    let teamIdentifier: String

    // MARK: - Binary Information

    /// CPU architectures supported
    /// by the application binary.
    ///
    /// Example:
    /// ["arm64"]
    /// ["armv7", "arm64"]
    let architectures: [String]

    /// Indicates whether the application
    /// signature is currently valid.
    ///
    /// This should represent:
    /// - code signature validation
    /// - provisioning match
    /// - entitlement consistency
    let hasValidSignature: Bool

    // MARK: - Entitlements

    /// Human-readable entitlement list.
    ///
    /// Example:
    /// - Push Notifications
    /// - App Groups
    /// - Keychain Sharing
    ///
    /// Keep this simplified for UI rendering.
    /// Raw entitlement dictionaries should
    /// be stored separately if needed.
    let entitlements: [String]

    // MARK: - Embedded Frameworks

    /// Embedded frameworks discovered
    /// inside the IPA bundle.
    let frameworks: [FrameworkInfo]

    /// Application identifier extracted from embedded
    /// provisioning profile, e.g. "ABCDE12345.com.company.app" or "ABCDE12345.com.company.*"
    let provisioningAppIdentifier: String?
    /// Expiration date from embedded provisioning profile
    let provisioningExpiration: Date?
}

// MARK: - Mock Data

extension IPAInspection {

    /// Preview and development mock object.
    ///
    /// Used for:
    /// - SwiftUI previews
    /// - UI prototyping
    /// - development testing
    static let mock = IPAInspection(

        appName: "Lido mBriefing",

        bundleIdentifier: "com.company.mbriefing",

        version: "5.2",

        buildNumber: "402",

        teamIdentifier: "ABCDE12345",

        architectures: [
            "arm64"
        ],

        hasValidSignature: true,

        entitlements: [
            "Push Notifications",
            "App Groups",
            "Keychain Sharing"
        ],

        frameworks: [

            FrameworkInfo(
                name: "Firebase.framework",
                isSigned: true,
                size: "12 MB"
            ),

            FrameworkInfo(
                name: "Alamofire.framework",
                isSigned: true,
                size: "3 MB"
            )
        ]
            ,
            provisioningAppIdentifier: "ABCDE12345.com.company.mbriefing",
            provisioningExpiration: nil
        )
}
