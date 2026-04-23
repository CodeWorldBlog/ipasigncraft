//
//  PrimaryButton.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 23/04/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.button)
                .foregroundColor(.white)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(isEnabled ? AppColors.accent : Color.gray.opacity(0.4))
                .cornerRadius(Radius.md)
        }
        .buttonStyle(.plain)
        .scaleEffect(isEnabled ? 1 : 1)
        .animation(.easeOut(duration: 0.15), value: isEnabled)
        .disabled(!isEnabled)
    }
}
