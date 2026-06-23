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
                    InfoRow(
                        icon: "doc.fill",
                        color: AppColors.accent,
                        title: (filePath as NSString).lastPathComponent,
                        subtitle: title == "IPA File" ? "Ready for signing" : "Ready for inspection"
                    )
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: Spacing.base) {
        HomeFileSection(title: "IPA File", helper: "Select or drop the IPA you want to re-sign", filePath: .constant("/path/to/app.ipa"), supportedTypes: [.ipa])
            .padding()

        HomeFileSection(title: "IPA File", helper: "Select or drop the IPA you want to inspect", filePath: .constant(""), supportedTypes: [.ipa])
            .padding()
    }
}