//
//  HomeSectionView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 23/04/26.
//

import SwiftUI

struct HomeSectionView<Content: View>: View {
    private let title: String
    private let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                /// Section title (consistent typography)
                Text(title)
                    .font(AppFont.section)
                    .foregroundColor(AppColors.primaryText)
                
                /// Section content
                content
            }
        }
    }
}
