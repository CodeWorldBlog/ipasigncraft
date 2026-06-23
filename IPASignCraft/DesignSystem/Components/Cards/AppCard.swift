//
//  AppCard.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 23/04/26.
//

import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(Spacing.base)
        .background(
            RoundedRectangle(cornerRadius: Radius.xl)
                .fill(AppColors.cardSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .shadow(color: AppColors.cardShadow, radius: 8, x: 0, y: 4)
        .clipShape(
            RoundedRectangle(cornerRadius: Radius.xl)
        )
    }
}
