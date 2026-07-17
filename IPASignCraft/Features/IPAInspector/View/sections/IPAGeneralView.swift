//
//  IPAGeneralView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import SwiftUI

/// Displays general metadata information
/// extracted from the IPA.
///
/// Purpose:
/// Present human-readable application details
/// commonly found inside:
/// - Info.plist
/// - bundle metadata
/// - application configuration
///
/// This screen should remain simple,
/// readable and non-technical compared
/// to binary/security inspection screens.
struct IPAGeneralView: View {

    // MARK: - Properties

    /// Complete IPA inspection result.
    let inspection: IPAInspection

    // MARK: - Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 24
        ) {

            applicationSection

            versionSection

            bundleSection
        }
    }
}

// MARK: - Application Information

private extension IPAGeneralView {

    /// Displays high-level application identity.
    ///
    /// Example:
    /// - app name
    /// - display name
    var applicationSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                title: "Application"
            )

            KeyValueRow(
                key: "App Name",
                value: inspection.appName
            )
        }
    }
}

// MARK: - Version Information

private extension IPAGeneralView {

    /// Displays version-related metadata.
    ///
    /// Derived from:
    /// - CFBundleShortVersionString
    /// - CFBundleVersion
    var versionSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                title: "Version Information"
            )

            KeyValueRow(
                key: "Version",
                value: inspection.version
            )

            KeyValueRow(
                key: "Build Number",
                value: inspection.buildNumber
            )
        }
    }
}

// MARK: - Bundle Information

private extension IPAGeneralView {

    /// Displays bundle-level identifiers.
    ///
    /// Example:
    /// - bundle identifier
    /// - team identifier
    var bundleSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                title: "Bundle Information"
            )

            KeyValueRow(
                key: "Bundle Identifier",
                value: inspection.bundleIdentifier
            )

            KeyValueRow(
                key: "Team Identifier",
                value: inspection.teamIdentifier
            )
        }
    }
}

// MARK: - Shared Helpers

private extension IPAGeneralView {

    /// Shared section title styling
    /// used throughout the inspector.
    func sectionHeader(
        title: String
    ) -> some View {

        Text(title)
            .font(.title3.bold())
    }
}

// MARK: - Preview

#Preview {

    IPAGeneralView(
        inspection: .mock
    )
}