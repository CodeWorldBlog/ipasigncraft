//
//  FileDropView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 17/03/26.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct FileDropView: View {
    let title: String?
    @Binding var filePath: String
    @State private var isHovering = false
    let supportedTypes: [UTType]

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {

            // Title
            if let title {
                Text(title)
                    .font(.headline)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1.2, dash: [6])
                    )
                    .foregroundColor(
                        isHovering ? AppColors.accent.opacity(0.6) : Color.gray.opacity(0.38)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.cardSurface)
                    )

                VStack(spacing: 6) {

                    Image(systemName: "tray.and.arrow.down")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    if filePath.isEmpty {
                        Text("Drop IPA file here")
                            .fontWeight(.medium)

                        Text("or click to browse")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    } else {
                        Text("IPA package loaded successfully")
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, 18)
            }
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                openPanel()
            }
            .focusable(true)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.18)) {
                    isHovering = hovering
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(filePath.isEmpty ? "File drop target" : "File loaded")
            .accessibilityHint("Click to browse, or drop an IPA file here.")
            .onDrop(of: ["public.file-url"], isTargeted: $isHovering) { providers in

                providers.first?.loadItem(forTypeIdentifier: "public.file-url",
                                         options: nil) { data, _ in
                    DispatchQueue.main.async {

                        if let data = data as? Data,
                           let url = URL(dataRepresentation: data,
                                         relativeTo: nil) {

                            filePath = url.path
                        }
                    }
                }

                return true
            }

            // File picker button (clean separation)
            HStack {
                Spacer()
                FilePickerView(
                    title: "Browse",
                    supportedTypes: supportedTypes,
                    filePath: $filePath
                )
            }
        }
    }

    #if os(macOS)
    private func openPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = supportedTypes
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                filePath = url.path
            }
        }
    }
    #endif
}

#Preview {
    FileDropView(
        title: "FileDropView",
        filePath: .constant("/path/to/file.ipa"),
        supportedTypes: [.ipa]
    )
}
