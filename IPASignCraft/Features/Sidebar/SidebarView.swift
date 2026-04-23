//
//  SidebarView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 22/04/26.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem
    
    var body: some View {
        ZStack {
            // Background layer (watercolor + soft overlay)
            sidebarBackground
            // Foreground content
            VStack(alignment: .leading, spacing: 18) {
                header
                // Subtle divider to separate header from menu
                Divider().opacity(0.3)
                menuOptions
                Spacer()
                footer
            }
            .padding(20)
        }
    }
}

// MARK: - Background
private extension SidebarView {
    /// Watercolor background with soft white overlay
    /// Keeps UI readable while preserving aesthetic
    var sidebarBackground: some View {
        GeometryReader { geo in
            Image("sidebarBgWatercolor")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Header
private extension SidebarView {
    
    /// App branding (icon + title + tagline)
    var header: some View {
        HStack(spacing: 10) {
            
            // Brand icon with subtle gradient
            Image(systemName: "feather.fill")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("IPASignCraft")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Craft. Sign. Deploy.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 10)
    }
}

// MARK: - Menu
private extension SidebarView {
    
    /// Main navigation items
    var menuOptions: some View {
        VStack(alignment: .leading, spacing: 6) {
            sidebarItem(icon: "house", title: "Home", isActive: true)
        }
    }
    
    /// Single sidebar row
    /// - Highlights active state
    /// - Keeps icon and text visually consistent
    func sidebarItem(icon: String, title: String, isActive: Bool = false) -> some View {
        HStack(spacing: 10) {
            
            Image(systemName: icon)
                .foregroundColor(isActive ? .blue : .primary.opacity(0.7))
            
            Text(title)
                .foregroundColor(isActive ? .blue : .primary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isActive
            ? RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.12))
            : nil
        )
    }
}

// MARK: - Footer
private extension SidebarView {
    
    /// App version (fetched dynamically from Info.plist)
    var footer: some View {
        Text(AppInfo.version)
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
