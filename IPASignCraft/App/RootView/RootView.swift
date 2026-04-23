//
//  RootView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 22/04/26.
//

import Foundation
import SwiftUI

struct RootView: View {
    @State private var selection: SidebarItem = .home
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar (fixed)
            SidebarView(selection: $selection)
                .frame(width: 220)
            Divider()
            // Content (flexible)
            detailView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .home:
            HomeView()
        }
    }
}
