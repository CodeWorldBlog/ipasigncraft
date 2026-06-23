//
//  View+Field.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 23/04/26.
//

import Foundation
import SwiftUI

/// Standard container for small input blocks (rows, fields, etc.)
extension View {
    func fieldContainer() -> some View {
        self
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(AppColors.cardSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .shadow(color: AppColors.cardShadow, radius: 6, x: 0, y: 2)
            .cornerRadius(Radius.sm)
    }
}
