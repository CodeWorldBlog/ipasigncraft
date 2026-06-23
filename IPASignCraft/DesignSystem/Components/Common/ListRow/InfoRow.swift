//
//  InfoRow.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 09/06/26.
//

import SwiftUI

/// A reusable row component for displaying file or item information.
///
/// Typically used to show:
/// - Selected file summaries
/// - Status information
/// - Item details with icon and label
///
/// Components:
/// - Icon on the left (with custom color)
/// - Title and subtitle in the middle
/// - Spacer on the right
/// - Container styling from the design system
struct InfoRow: View {

    // MARK: - Properties

    /// SF Symbol icon name
    let icon: String

    /// Icon color
    let color: Color

    /// Primary text (main title)
    let title: String

    /// Secondary text (description)
    let subtitle: String

    // MARK: - Body

    var body: some View {

        HStack(spacing: Spacing.sm) {

            Image(systemName: icon)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {

                Text(title)
                    .font(AppFont.secondary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(AppFont.secondary)
                    .foregroundColor(AppColors.secondaryText)
            }

            Spacer()
        }
        .fieldContainer()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(subtitle)
    }
}

// MARK: - Preview

#Preview {

    InfoRow(
        icon: "doc.fill",
        color: AppColors.accent,
        title: "ExampleApp.ipa",
        subtitle: "Ready for inspection"
    )
}
