//
//  IPAOverviewView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import SwiftUI

/// Overview dashboard for the inspected IPA.
///
/// Purpose:
/// Provide a quick high-level understanding
/// of the application before diving into
/// technical inspection details.
///
/// This screen should remain lightweight,
/// readable and visually structured.
///
/// Recommended focus:
/// - app identity
/// - signing status
/// - architectures
/// - capabilities
/// - framework count
struct IPAOverviewView: View {

    // MARK: - Properties

    /// Complete IPA inspection result.
    let inspection: IPAInspection

    // MARK: - Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 24
        ) {

            headerSection

            summaryCardsSection

            capabilitiesSection
        }
    }
}

// MARK: - Header Section

private extension IPAOverviewView {

    /// Displays app identity information.
    ///
    /// Example:
    /// - app name
    /// - bundle identifier
    /// - version/build
    var headerSection: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(inspection.appName)
                .font(.largeTitle.bold())

            Text(inspection.bundleIdentifier)
                .foregroundStyle(.secondary)

            Text(
                "Version \(inspection.version) (\(inspection.buildNumber))"
            )
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Summary Cards

private extension IPAOverviewView {

    /// Displays quick inspection highlights.
    ///
    /// These cards should provide
    /// instant visual understanding
    /// of the IPA state.
    var summaryCardsSection: some View {

        HStack(spacing: 16) {
            InspectorInfoCard(
                title: "Team",
                value: inspection.teamIdentifier
            )

            InspectorInfoCard(
                title: "Architectures",
                value: inspection.architectures.joined(separator: ", ")
            )

            InspectorInfoCard(
                title: "Frameworks",
                value: "\(inspection.frameworks.count)"
            )

            InspectorInfoCard(
                title: "Signature",
                value: inspection.hasValidSignature
                ? "Valid"
                : "Invalid"
            )
        }
    }
}

// MARK: - Capabilities

private extension IPAOverviewView {

    /// Displays simplified entitlement capabilities.
    ///
    /// Examples:
    /// - Push Notifications
    /// - App Groups
    /// - Keychain Sharing
    var capabilitiesSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("Capabilities")
                .font(.headline)

            ForEach(
                inspection.entitlements,
                id: \.self
            ) { entitlement in

                Label(
                    entitlement,
                    systemImage: "checkmark.circle.fill"
                )
                .foregroundStyle(.green)
            }
        }
    }
}

// MARK: - Preview

#Preview {

    IPAOverviewView(
        inspection: .mock
    )
}
