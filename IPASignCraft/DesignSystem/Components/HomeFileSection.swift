import SwiftUI
internal import UniformTypeIdentifiers

/// Reusable section composed of HomeSectionView + FileBrowserView + helper text
/// Use this in places that need an "IPA File" style input area.
struct HomeFileSection: View {
    let title: String
    let helper: String?
    @Binding var filePath: String
    let supportedTypes: [UTType]
    var onSelect: ((String) -> Void)? = nil
    /// Optional subtitle to show when a file is selected. Parent views can pass
    /// a context-appropriate label such as "Ready For Signing" or
    /// "Ready For Inspection". If nil, suffix-based fallback is used.
    var selectedSubtitle: String? = nil

    var body: some View {
        HomeSectionView(title) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                if let helper {
                    Text(helper)
                        .font(AppFont.secondary)
                        .foregroundColor(AppColors.secondaryText)
                }

                // Large drop area
                FileDropView(
                    title: nil,
                    filePath: $filePath,
                    supportedTypes: supportedTypes
                )
                .frame(minHeight: 140)
                .onChange(of: filePath) { newPath in
                    guard !newPath.isEmpty else { return }
                    onSelect?(newPath)
                }

                if !filePath.isEmpty {
                    // If parent provided a subtitle, use it; otherwise fallback
                    // to a simple suffix-based heuristic.
                    let subtitleText = selectedSubtitle ?? {
                        let lower = filePath.lowercased()
                        if lower.hasSuffix(".ipa") {
                            return "Ready For Signing"
                        }
                        return "Ready for inspection"
                    }()

                    InfoRow(
                        icon: "doc.fill",
                        color: AppColors.accent,
                        title: (filePath as NSString).lastPathComponent,
                        subtitle: subtitleText
                    )
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: Spacing.base) {
        HomeFileSection(title: "IPA File", helper: "Select or drop the IPA you want to re-sign", filePath: .constant("/path/to/app.ipa"), supportedTypes: [.ipa], selectedSubtitle: "Ready For Signing")
            .padding()

        HomeFileSection(title: "IPA File", helper: "Select or drop the IPA you want to inspect", filePath: .constant(""), supportedTypes: [.ipa], selectedSubtitle: "Ready For Inspection")
            .padding()
    }
}