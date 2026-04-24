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
    
    // MARK: - Backgrounds
    static let background = Color(hexValue: "#F4F1EA").opacity(0.9) // warm ivory
    static let cardBackground = Color.white.opacity(0.75)
    static let dropZoneBackground = Color.white.opacity(0.4)
    
    // MARK: - Borders
    static let border = Color.black.opacity(0.06)
    
    // MARK: - States
    static let success = Color(hexValue: "#34C759")
    static let error = Color(hexValue: "#FF453A")
    
    // MARK: - Logs
    static let logBackground = Color(hexValue: "#1C1C1E")
}
