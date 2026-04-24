//
//  FilePickerView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 19/03/26.
//

import SwiftUI
import AppKit
internal import UniformTypeIdentifiers

struct FilePickerView: View {
    let title: String
    let supportedTypes: [UTType]
    @Binding var filePath: String

    var body: some View {
        HStack {
            Text(title)

            Text(filePath.isEmpty ? "No file selected" : filePath)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)

            Spacer()
            Button("Browse") {
                self.openPanel()
            }
        }
    }

    private func openPanel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        
        // Convert extensions → UTType
        panel.allowedContentTypes = supportedTypes

        if panel.runModal() == .OK {
            filePath = panel.url?.path ?? ""
        }
    }
}

#Preview {
    FilePickerView(
        title: "FilePickerView", supportedTypes: [.ipa],
        filePath: .constant("/path/to/file.ipa")
    )
}
