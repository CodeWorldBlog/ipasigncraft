//
//  StatCard.swift
//  IPASignCraft
//
//  Created by Copilot
//

import SwiftUI

/// A reusable card displaying a single statistic with
/// icon, label, and value.
///
/// Used in the IPA Inspector dashboard to show
/// quick insights like Version, Signature, Frameworks, etc.
struct StatCard: View {

    // MARK: - Properties

    /// The icon/symbol representing the stat
    let icon: String

    /// Background color for the icon area
    let iconColor: Color

    /// Label text describing the stat
    let label: String

    /// The value to display (can be multi-line)
    let value: String

    /// Optional subtitle/description below value
    let subtitle: String?

    // MARK: - Initialization

    init(
        icon: String,
        iconColor: Color,
        label: String,
        value: String,
        subtitle: String? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.label = label
        self.value = value
        self.subtitle = subtitle
    }

    // MARK: - Body

    @State private var isHovering = false

    var body: some View {

        VStack(alignment: .leading, spacing: Spacing.sm) {

            // Icon with background
            HStack {

                ZStack {
                    RoundedRectangle(cornerRadius: Spacing.xs)
                        .fill(
                            iconColor.opacity(0.15)
                        )

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                .frame(width: 40, height: 40)

                Spacer()
            }

            // Label
            Text(label)
                .font(AppFont.secondary)
                .foregroundColor(AppColors.secondaryText)
                .lineLimit(1)

            // Value
            Text(value)
                .font(AppFont.section)
                .fontWeight(.semibold)
                .lineLimit(2)

            // Optional subtitle
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
            }
        }
        .padding(Spacing.base)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(AppColors.cardSurface)
                .shadow(color: AppColors.cardShadow, radius: 6, x: 0, y: 2)
        )
        .scaleEffect(isHovering ? 1.02 : 1)
        .animation(.easeInOut(duration: 0.18), value: isHovering)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.18)) {
                isHovering = hovering
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}


// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.base) {
        StatCard(
            icon: "square.and.line.vertical.and.square",
            iconColor: .purple,
            label: "Version",
            value: "5.2",
            subtitle: "CFBundleShortVersionString"
        )

        StatCard(
            icon: "checkmark.seal.fill",
            iconColor: .green,
            label: "Signature",
            value: "Valid",
            subtitle: "Code signature is valid"
        )

        StatCard(
            icon: "person.badge.key",
            iconColor: .orange,
            label: "Team ID",
            value: "ABCDE12345",
            subtitle: "Development Team"
        )
    }
    .padding()
}
