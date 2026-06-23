//
//  CollapsibleSection.swift
//  IPASignCraft
//
//  Created by Copilot
//

import SwiftUI

/// A collapsible section component for the IPA Inspector dashboard.
///
/// Displays a header with icon, title, and optional badge,
/// with expandable/collapsible content below.
struct CollapsibleSection<Content: View>: View {

    // MARK: - Properties

    /// Icon name for the section header
    let icon: String

    /// Color for the icon
    let iconColor: Color

    /// Title of the section
    let title: String

    /// Optional subtitle/description
    let subtitle: String?

    /// Optional badge value (e.g., count)
    let badge: String?

    /// Badge color
    let badgeColor: Color

    /// Content to display when expanded
    let content: () -> Content

    /// Whether section is expanded
    @State private var isExpanded = false
    @State private var isFocused = false

    // MARK: - Initialization

    init(
        icon: String,
        iconColor: Color = .blue,
        title: String,
        subtitle: String? = nil,
        badge: String? = nil,
        badgeColor: Color = .blue,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.badgeColor = badgeColor
        self.content = content
    }

    // MARK: - Body

    var body: some View {

        VStack(spacing: 0) {

            // Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.22)) {
                    isExpanded.toggle()
                }
            }) {

                HStack(spacing: Spacing.base) {

                    // Icon
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.1))

                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(iconColor)
                    }
                    .frame(width: 32, height: 32)

                    // Title and subtitle
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(AppFont.body)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primaryText)

                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(AppFont.secondary)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }

                    Spacer()

                    // Badge
                    if let badge = badge {
                        Text(badge)
                            .font(AppFont.secondary)
                            .fontWeight(.semibold)
                            .foregroundColor(badgeColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(badgeColor.opacity(0.1))
                            .cornerRadius(4)
                    }

                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.secondaryText)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.22), value: isExpanded)
                }
                .padding(Spacing.base)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.space, modifiers: [])
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(title)
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")

            // Content
            if isExpanded {
                Divider()
                    .padding(.horizontal, Spacing.base)

                content()
                    .padding(Spacing.base)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(AppColors.cardSurface)
                .shadow(color: AppColors.cardShadow, radius: 6, x: 0, y: 2)
        )
        .onHover { hovering in
            // show focus ring when hovered
            withAnimation(.easeInOut(duration: 0.18)) {
                isFocused = hovering
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .stroke(isFocused ? AppColors.accent.opacity(0.25) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.base) {
        CollapsibleSection(
            icon: "info.circle",
            iconColor: .blue,
            title: "Overview",
            subtitle: "General information about the IPA and app bundle.",
            badge: nil
        ) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("App Name")
                        .font(AppFont.secondary)
                    Spacer()
                    Text("MyApp")
                        .font(AppFont.body)
                }
                HStack {
                    Text("Bundle ID")
                        .font(AppFont.secondary)
                    Spacer()
                    Text("com.example.app")
                        .font(AppFont.body)
                }
            }
        }

        CollapsibleSection(
            icon: "checkmark.seal.fill",
            iconColor: .green,
            title: "Signing & Provisioning",
            subtitle: "Code signature details and provisioning profile info.",
            badge: "Valid",
            badgeColor: .green
        ) {
            Text("Signing details content goes here")
                .font(AppFont.secondary)
        }
    }
    .padding()
}
