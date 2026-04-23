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
            .background(AppColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .cornerRadius(Radius.sm)
    }
}
