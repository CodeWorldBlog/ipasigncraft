//
//  AppColors.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 23/04/26.
//


import SwiftUI

enum AppColors {
    // MARK: - Text
    static let primaryText = Color(hexValue: "#1D1D1F")
    static let secondaryText = Color(hexValue: "#6E6E73")
    static let disabledText = Color(hexValue: "#A1A1A6")

    // MARK: - Accent (Green System)
    static let accent = Color(hexValue: "#2F5D3A")        // Deep forest (base)
    static let accentHover = Color(hexValue: "#3E7A4E")   // Slightly lighter green
    static let accentPressed = Color(hexValue: "#254A2E") // Slightly darker

    // MARK: - Backgrounds & Surfaces
    static let background = Color(hexValue: "#F7F6FA")    // very light neutral
    static let cardBackground = Color.white.opacity(0.92)
    static let controlBackground = Color(nsColor: .controlBackgroundColor)
    static let dropZoneBackground = Color(hexValue: "#F0F5FF").opacity(0.6)

    // Subtle card surface used for elevated blocks
    static let cardSurface = Color(hexValue: "#FFFFFF")

    // Header / decorative gradient
    static let headerGradientStart = Color(hexValue: "#F2E9FF")
    static let headerGradientEnd = Color(hexValue: "#E9F4FF")

    // MARK: - Borders & Shadows
    static let border = Color(hexValue: "#000000").opacity(0.06)
    static let cardShadow = Color(hexValue: "#000000").opacity(0.04)

    // MARK: - States
    static let success = Color(hexValue: "#34C759")
    static let error = Color(hexValue: "#FF453A")

    // MARK: - Logs
    static let logBackground = Color(hexValue: "#1C1C1E")
}

