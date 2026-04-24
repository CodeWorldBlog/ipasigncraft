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
            sidebarBackground
            
            VStack(alignment: .leading, spacing: 18) {
                header
                
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
    
    var header: some View {
        HStack(spacing: 10) {
            
            Image("sidebarIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("IPASignCraft")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Craft. Sign. Deploy.")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding(.bottom, 10)
    }
}

// MARK: - Menu
private extension SidebarView {
    
    var menuOptions: some View {
        VStack(alignment: .leading, spacing: 6) {
            sidebarItem(icon: "house", title: "Home", item: .home)
        }
    }
    
    func sidebarItem(icon: String, title: String, item: SidebarItem) -> some View {
        SidebarRow(
            icon: icon,
            title: title,
            isActive: selection == item
        )
        .onTapGesture {
            selection = item
        }
    }
}

// MARK: - Sidebar Row
struct SidebarRow: View {
    let icon: String
    let title: String
    let isActive: Bool
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 10) {
            
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(iconColor)
            
            Text(title)
                .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                .foregroundColor(AppColors.primaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
        .animation(.easeOut(duration: 0.12), value: isHovering)
    }
    
    private var iconColor: Color {
        if isActive { return AppColors.accent }
        if isHovering { return AppColors.accent.opacity(0.8) }
        return AppColors.primaryText.opacity(0.7)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(backgroundColor)
    }
    
    private var backgroundColor: Color {
        if isActive {
            return AppColors.accent.opacity(0.14)
        } else if isHovering {
            return AppColors.accent.opacity(0.06)
        } else {
            return Color.clear
        }
    }
}

// MARK: - Footer
private extension SidebarView {
    var footer: some View {
        Text(AppInfo.version)
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
