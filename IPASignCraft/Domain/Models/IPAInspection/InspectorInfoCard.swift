//
//  InspectorInfoCard.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import SwiftUI

/// Reusable information card used throughout
/// the IPA Inspector feature.
///
/// Purpose:
/// Display short summary values in a compact,
/// visually grouped format.
///
/// Common usage:
/// - Version
/// - Build Number
/// - Team Identifier
/// - Framework Count
/// - Architecture List
///
/// The card is intentionally lightweight
/// and should only display concise values.
///
/// Avoid placing large multiline content here.
struct InspectorInfoCard: View {

    // MARK: - Properties

    /// Small descriptive label.
    ///
    /// Example:
    /// "Version"
    /// "Frameworks"
    let title: String

    /// Main displayed value.
    ///
    /// Example:
    /// "5.2"
    /// "12"
    /// "arm64"
    let value: String

    // MARK: - Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            titleView

            valueView
        }
        .padding(16)
        .frame(
            maxWidth: 180,
            alignment: .leading
        )
        .background(
            cardBackground
        )
    }
}

// MARK: - Title View

private extension InspectorInfoCard {

    /// Displays the card label/title.
    var titleView: some View {

        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Value View

private extension InspectorInfoCard {

    /// Displays the primary card value.
    var valueView: some View {

        Text(value)
            .font(.headline)
            .lineLimit(2)
    }
}

// MARK: - Background

private extension InspectorInfoCard {

    /// Shared card background styling.
    var cardBackground: some View {

        RoundedRectangle(cornerRadius: 14)
            .fill(
                Color.gray.opacity(0.08)
            )
    }
}

// MARK: - Preview

#Preview {

    HStack {

        InspectorInfoCard(
            title: "Version",
            value: "5.2"
        )

        InspectorInfoCard(
            title: "Architectures",
            value: "arm64"
        )
    }
    .padding()
}