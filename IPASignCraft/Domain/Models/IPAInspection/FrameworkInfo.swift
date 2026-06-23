//
//  FrameworkInfo.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import Foundation

/// Represents a single embedded framework
/// discovered inside the IPA bundle.
///
/// Example locations:
/// Payload/App.app/Frameworks/
struct FrameworkInfo: Identifiable {

    // MARK: - Identity

    /// Stable identifier used by SwiftUI lists/tables.
    let id = UUID()

    // MARK: - Basic Information

    /// Framework bundle name.
    ///
    /// Example:
    /// "Firebase.framework"
    /// "Alamofire.framework"
    let name: String

    // MARK: - Signing Information

    /// Indicates whether the framework
    /// contains a valid code signature.
    ///
    /// This can be verified using:
    /// - codesign
    /// - SecStaticCode APIs
    let isSigned: Bool

    // MARK: - Size Information

    /// Human-readable framework size.
    ///
    /// Example:
    /// "12 MB"
    /// "540 KB"
    ///
    /// Keep formatted for UI rendering.
    /// Raw byte count can be stored separately
    /// if advanced sorting/filtering is needed.
    let size: String
}

// MARK: - Mock Data

extension FrameworkInfo {

    /// Mock framework used for previews
    /// and UI development.
    static let mock = FrameworkInfo(
        name: "Firebase.framework",
        isSigned: true,
        size: "12 MB"
    )
}