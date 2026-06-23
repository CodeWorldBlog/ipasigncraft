import SwiftUI
internal import UniformTypeIdentifiers

/// A small composed control used across the app for file selection.
/// Combines the existing FilePickerView and FileDropView into a single reusable component.
struct FileBrowserView: View {
    let title: String?
    @Binding var filePath: String
    let supportedTypes: [UTType]

    init(title: String? = nil, filePath: Binding<String>, supportedTypes: [UTType]) {
        self.title = title
        self._filePath = filePath
        self.supportedTypes = supportedTypes
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if let title {
                Text(title)
                    .font(AppFont.secondary)
            }

            HStack(spacing: Spacing.base) {
                FilePickerView(
                    title: "Browse...",
                    supportedTypes: supportedTypes,
                    filePath: $filePath
                )

                FileDropView(
                    title: nil,
                    filePath: $filePath,
                    supportedTypes: supportedTypes
                )
            }
            .frame(maxHeight: 100)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.base) {
        FileBrowserView(title: "IPA File", filePath: .constant("/path/to/app.ipa"), supportedTypes: [.ipa])
            .padding()

        FileBrowserView(title: nil, filePath: .constant(""), supportedTypes: [.ipa])
            .padding()
    }
}
