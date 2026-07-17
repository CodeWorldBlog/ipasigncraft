//
//  IPAEntitlementsView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import SwiftUI

/// Displays entitlement capabilities
/// discovered inside the IPA.
///
/// Purpose:
/// Help developers quickly understand
/// which Apple capabilities are enabled.
///
/// Examples:
/// - Push Notifications
/// - App Groups
/// - Keychain Sharing
/// - Associated Domains
///
/// The UI intentionally presents
/// simplified human-readable capabilities
/// instead of raw entitlement XML.
///
/// Future versions may include:
/// - raw entitlement viewer
/// - entitlement diffing
/// - validation warnings
/// - entitlement search/filtering
struct IPAEntitlementsView: View {

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

            capabilitiesSection

            entitlementSummarySection
        }
    }
}

// MARK: - Header Section

private extension IPAEntitlementsView {

    /// Displays introductory information
    /// about entitlement inspection.
    var headerSection: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text("Entitlements")
                .font(.largeTitle.bold())

            Text(
                "Capabilities and permissions enabled for this application."
            )
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Capabilities Section

private extension IPAEntitlementsView {

    /// Displays human-readable
    /// entitlement capabilities.
    var capabilitiesSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                title: "Enabled Capabilities"
            )

            if inspection.entitlements.isEmpty {

                emptyCapabilitiesView

            } else {

                LazyVStack(spacing: 12) {

                    ForEach(
                        inspection.entitlements,
                        id: \.self
                    ) { entitlement in

                        entitlementRow(
                            title: entitlement
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Summary Section

private extension IPAEntitlementsView {

    /// Displays entitlement statistics
    /// and quick metadata.
    var entitlementSummarySection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                title: "Summary"
            )

            KeyValueRow(
                key: "Total Capabilities",
                value: "\(inspection.entitlements.count)"
            )
        }
    }
}

// MARK: - Empty State

private extension IPAEntitlementsView {

    /// Displayed when no entitlements
    /// are discovered.
    var emptyCapabilitiesView: some View {

        ContentUnavailableView(
            "No Entitlements Found",
            systemImage: "lock.slash",
            description: Text(
                "The application does not contain any detected capabilities."
            )
        )
    }
}

// MARK: - Reusable Rows

private extension IPAEntitlementsView {

    /// Displays a single entitlement capability.
    @ViewBuilder
    func entitlementRow(
        title: String
    ) -> some View {

        HStack(spacing: 12) {

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)

            Text(title)

            Spacer()
        }
        .padding(14)
        .background(
            Color.gray.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }
}

// MARK: - Shared Helpers

private extension IPAEntitlementsView {

    /// Shared section title styling.
    func sectionHeader(
        title: String
    ) -> some View {

        Text(title)
            .font(.title3.bold())
    }
}

// MARK: - Preview

#Preview {

    IPAEntitlementsView(
        inspection: .mock
    )
}