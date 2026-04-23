//
//  File.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 23/04/26.
//

import SwiftUI

public extension Color {
    init(hexValue: String) {
        let hex = hexValue.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
