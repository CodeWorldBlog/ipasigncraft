//
//  IPAInspectorSection.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import Foundation

/// Navigation sections available
/// inside the IPA Inspector feature.
///
/// Each section represents a dedicated
/// inspection domain of the IPA.
enum IPAInspectorSection: String, CaseIterable, Identifiable {

    // MARK: - Sections

    /// High-level summary dashboard.
    ///
    /// Shows:
    /// - app identity
    /// - health status
    /// - architectures
    /// - signing overview
    case overview

    /// General application metadata.
    ///
    /// Shows:
    /// - bundle identifier
    /// - version
    /// - build number
    /// - minimum iOS version
    /// - supported devices
    case general

    /// Signing and provisioning analysis.
    ///
    /// Shows:
    /// - certificate details
    /// - provisioning profile
    /// - expiration
    /// - validation warnings
    case signing

    /// Application entitlements.
    ///
    /// Shows:
    /// - push notifications
    /// - app groups
    /// - keychain access
    /// - associated domains
    case entitlements

    /// Mach-O binary inspection.
    ///
    /// Shows:
    /// - architectures
    /// - encryption status
    /// - linked libraries
    /// - load commands
    case binary

    /// Embedded frameworks and dylibs.
    ///
    /// Shows:
    /// - framework list
    /// - signing status
    /// - framework sizes
    case frameworks

    /// Security and validation analysis.
    ///
    /// Shows:
    /// - ATS configuration
    /// - jailbreak indicators
    /// - debug symbols
    /// - suspicious libraries
    case security

    // MARK: - Identifiable

    var id: String {
        rawValue
    }
}

// MARK: - UI Helpers

extension IPAInspectorSection {

    /// Human-readable title
    /// used in sidebar navigation.
    var title: String {

        switch self {

        case .overview:
            return "Overview"

        case .general:
            return "General"

        case .signing:
            return "Signing"

        case .entitlements:
            return "Entitlements"

        case .binary:
            return "Binary"

        case .frameworks:
            return "Frameworks"

        case .security:
            return "Security"
        }
    }

    /// SF Symbol used for sidebar navigation
    /// and section headers.
    var systemImage: String {

        switch self {

        case .overview:
            return "square.grid.2x2"

        case .general:
            return "info.circle"

        case .signing:
            return "signature"

        case .entitlements:
            return "lock.shield"

        case .binary:
            return "cpu"

        case .frameworks:
            return "shippingbox"

        case .security:
            return "shield"
        }
    }
}