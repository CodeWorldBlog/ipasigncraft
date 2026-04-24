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
    
    @State private var isHovering = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.button)
                .foregroundColor(.white)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(background)
                .overlay(border)
                .cornerRadius(Radius.md)
                .scaleEffect(isPressed ? 0.97 : 1)
                .animation(.easeOut(duration: 0.12), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .onHover { hovering in
            isHovering = hovering
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    private var background: some View {
        Group {
            if isEnabled {
                AppColors.accent
                    .opacity(isHovering ? 0.9 : 1)
            } else {
                AppColors.accent.opacity(0.25)
            }
        }
    }
    
    private var border: some View {
        RoundedRectangle(cornerRadius: Radius.md)
            .strokeBorder(Color.white.opacity(isEnabled ? 0.15 : 0.05), lineWidth: 1)
    }
}
