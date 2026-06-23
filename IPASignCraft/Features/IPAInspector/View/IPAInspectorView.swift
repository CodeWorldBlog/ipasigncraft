import SwiftUI

/// Main IPA Inspector screen with dashboard layout.
///
/// Single-column centered layout:
/// - File upload section at top
/// - Quick stat cards
/// - Expandable detail sections
/// - Status indicator at bottom
///
/// This provides a clean, focused dashboard experience
/// for analyzing IPA file contents.
struct IPAInspectorView: View {

    // MARK: - View Model

    /// Owns IPA inspection state.
    @StateObject
    private var viewModel = IPAInspectorDetailViewModel()

    // MARK: - Body

    var body: some View {

        ZStack {

            // Background
            inspectorBackground

            // Main content with left dashboard and right console/status
            ScrollView {
                HStack(alignment: .top, spacing: Spacing.lg) {

                    // Left column: main dashboard
                    VStack(alignment: .center, spacing: Spacing.lg) {

                        headerSection

                        VStack(alignment: .leading, spacing: Spacing.lg) {

                            // File upload section
                            fileUploadSection

                            // Selected file info
                            if let ipaPath = viewModel.state.selectedIPAURL?.path {
                                selectedFileSection(fileName: (ipaPath as NSString).lastPathComponent)
                            }

                            // Inspection results
                            if let inspection = viewModel.state.inspection {

                                Divider()

                                // Quick stat cards
                                statCardsSection(inspection: inspection)

                                // Expandable sections
                                inspectionDetailsSection(inspection: inspection)

                                // Completion status (main)
                                completionStatusSection
                            }
                        }
                        .frame(maxWidth: 800, alignment: .leading)
                        .padding(.horizontal, Spacing.lg)
                    }
                    .frame(maxWidth: 800)

                    // Right column: console and compact status
                    VStack(alignment: .leading, spacing: Spacing.base) {

                        // Console / Logs placeholder
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Console")
                                .font(AppFont.heading3)
                                .fontWeight(.semibold)

                            Text("Live logs and inspection output")
                                .font(AppFont.secondary)
                                .foregroundColor(AppColors.secondaryText)

                            // Simple scrollable console area
                            ScrollView {
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    ForEach(viewModel.state.log.split(separator: "\n").suffix(50), id: \.self) { line in
                                        Text(String(line))
                                            .font(AppFont.small)
                                            .foregroundColor(AppColors.secondaryText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(Spacing.base)
                            }
                            .frame(minHeight: 220, maxHeight: 320)
                            .background(RoundedRectangle(cornerRadius: Radius.sm).fill(AppColors.cardSurface))
                            .shadow(color: AppColors.cardShadow, radius: 6, x: 0, y: 2)
                        }

                        // Compact completion/status box
                        compactCompletionStatusSection

                        Spacer()
                    }
                    .frame(width: 340)
                }
                .padding(.vertical, Spacing.lg)
                .padding(.horizontal, Spacing.lg)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                refreshButton
            }
        }
    }
}

// MARK: - Background
private extension IPAInspectorView {

    var inspectorBackground: some View {

        GeometryReader { geo in

            Color(nsColor: .windowBackgroundColor)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Header Section
private extension IPAInspectorView {

    var headerSection: some View {

        VStack(alignment: .leading, spacing: Spacing.xs) {

            HStack(spacing: Spacing.base) {

                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: Spacing.xs)
                        .fill(
                            LinearGradient(
                            gradient: Gradient(colors: [AppColors.headerGradientStart, AppColors.headerGradientEnd]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.purple)
                }
                .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 4) {

                    Text("IPA Inspector")
                        .font(AppFont.title)

                    Text("Analyze IPA contents, signing, frameworks and security.")
                        .font(AppFont.secondary)
                        .foregroundColor(AppColors.secondaryText)
                }

                Spacer()
            }
            .frame(maxWidth: 800, alignment: .leading)
            .padding(.horizontal, Spacing.lg)
        }
    }
}

// MARK: - File Upload Section
private extension IPAInspectorView {

    var fileUploadSection: some View {

        HomeFileSection(
            title: "IPA File",
            helper: "Select or drop the IPA you want to inspect",
            filePath: Binding(
                get: { viewModel.state.selectedIPAURL?.path ?? "" },
                set: { path in
                    if !path.isEmpty {
                        let url = URL(fileURLWithPath: path)
                        viewModel.inspectIPA(at: url)
                    }
                }
            ),
            supportedTypes: [.ipa],
            onSelect: { _ in }
        )
    }
}

// MARK: - Selected File Section
private extension IPAInspectorView {

    func selectedFileSection(fileName: String) -> some View {

        HStack(spacing: Spacing.base) {

            ZStack {
                RoundedRectangle(cornerRadius: Spacing.xs)
                    .fill(AppColors.accent.opacity(0.1))

                Image(systemName: "doc.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.accent)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(fileName)
                    .font(AppFont.body)
                    .fontWeight(.semibold)

                Text("Ready for inspection")
                    .font(AppFont.caption)
                    .foregroundColor(AppColors.secondaryText)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(AppColors.success)
        }
        .padding(Spacing.base)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
            .fill(AppColors.cardSurface)
        )
        .shadow(color: AppColors.cardShadow, radius: 6, x: 0, y: 2)
    }
}

// MARK: - Quick Stat Cards
private extension IPAInspectorView {

    func statCardsSection(inspection: IPAInspection) -> some View {

        VStack(alignment: .leading, spacing: Spacing.base) {

            // First row: Version, Signature, Frameworks
            HStack(spacing: Spacing.base) {

                StatCard(
                    icon: "square.and.line.vertical.and.square",
                    iconColor: .purple,
                    label: "Version",
                    value: inspection.version,
                    subtitle: "CFBundleShortVersionString"
                )

                StatCard(
                    icon: "checkmark.seal.fill",
                    iconColor: .green,
                    label: "Signature",
                    value: inspection.hasValidSignature ? "Valid" : "Invalid",
                    subtitle: inspection.hasValidSignature ? "Code signature is valid" : "Code signature is invalid"
                )

                StatCard(
                    icon: "square.3.layers.3d",
                    iconColor: .blue,
                    label: "Frameworks",
                    value: "\(inspection.frameworks.count)",
                    subtitle: "Embedded frameworks"
                )
            }

            // Second row: Team ID, Entitlements, Architecture
            HStack(spacing: Spacing.base) {

                StatCard(
                    icon: "person.badge.key",
                    iconColor: .orange,
                    label: "Team ID",
                    value: inspection.teamIdentifier,
                    subtitle: "Development Team"
                )

                StatCard(
                    icon: "list.clipboard.fill",
                    iconColor: .yellow,
                    label: "Entitlements",
                    value: "\(inspection.entitlements.count)",
                    subtitle: "Total entitlements"
                )

                StatCard(
                    icon: "cpu",
                    iconColor: .pink,
                    label: "Architecture",
                    value: inspection.architectures.joined(separator: ", "),
                    subtitle: "Primary architecture"
                )
            }
        }
    }
}

// MARK: - Inspection Details Sections
private extension IPAInspectorView {

    func inspectionDetailsSection(inspection: IPAInspection) -> some View {

        VStack(spacing: Spacing.base) {

            // Overview Section
            CollapsibleSection(
                icon: "info.circle",
                iconColor: .blue,
                title: "Overview",
                subtitle: "General information about the IPA and app bundle."
            ) {
                IPAOverviewView(inspection: inspection)
            }

            // General Information Section
            CollapsibleSection(
                icon: "doc.text",
                iconColor: .blue,
                title: "General Information",
                subtitle: "Bundle ID, version, build, minimum OS, and more."
            ) {
                IPAGeneralView(inspection: inspection)
            }

            // Signing & Provisioning Section
            CollapsibleSection(
                icon: "checkmark.seal.fill",
                iconColor: .green,
                title: "Signing & Provisioning",
                subtitle: "Code signature details and provisioning profile info.",
                badge: inspection.hasValidSignature ? "Valid" : "Invalid",
                badgeColor: inspection.hasValidSignature ? .green : .red
            ) {
                IPASigningView(inspection: inspection)
            }

            // Entitlements Section
            CollapsibleSection(
                icon: "list.clipboard.fill",
                iconColor: .yellow,
                title: "Entitlements",
                subtitle: "View all entitlements included in this IPA.",
                badge: "\(inspection.entitlements.count)",
                badgeColor: .yellow
            ) {
                IPAEntitlementsView(inspection: inspection)
            }

            // Binary Analysis Section
            CollapsibleSection(
                icon: "cpu.fill",
                iconColor: .orange,
                title: "Binary Analysis",
                subtitle: "Mach-O information, architectures, encryption and more."
            ) {
                IPABinaryView(inspection: inspection)
            }

            // Frameworks Section
            CollapsibleSection(
                icon: "cube.transparent",
                iconColor: .blue,
                title: "Frameworks",
                subtitle: "Embedded frameworks and their signing status.",
                badge: "\(inspection.frameworks.count)",
                badgeColor: .blue
            ) {
                IPAFrameworksView(inspection: inspection)
            }

            // Security Section
            CollapsibleSection(
                icon: "lock.shield.fill",
                iconColor: .red,
                title: "Security",
                subtitle: "Security checks, warnings and recommendations.",
                badge: "No issues",
                badgeColor: .green
            ) {
                IPASecurityView(inspection: inspection)
            }
        }
    }
}

// MARK: - Completion Status
private extension IPAInspectorView {

    var completionStatusSection: some View {

        HStack(spacing: Spacing.sm) {

            Image(systemName: "info.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.blue)

            Text("Inspection completed successfully")
                .font(AppFont.secondary)

            Spacer()

            Text("Today, 10:42 AM")
                .font(AppFont.caption)
                .foregroundColor(AppColors.secondaryText)

            Image(systemName: "clock")
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(Spacing.base)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(AppColors.cardSurface)
        )
        .shadow(color: AppColors.cardShadow, radius: 6, x: 0, y: 2)
    }

    /// Compact variant of completion status suitable for sidebar.
    var compactCompletionStatusSection: some View {

        HStack(spacing: Spacing.xs) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text("Inspection completed")
                    .font(AppFont.small)
                    .fontWeight(.semibold)

                Text("Today, 10:42 AM")
                    .font(AppFont.small)
                    .foregroundColor(AppColors.secondaryText)
            }

            Spacer()
        }
        .padding(Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(AppColors.cardSurface)
        )
        .shadow(color: AppColors.cardShadow, radius: 4, x: 0, y: 1)
    }
}

// MARK: - Toolbar
private extension IPAInspectorView {

    /// Re-runs IPA inspection.
    var refreshButton: some View {

        Button {

            if let ipaURL = viewModel.state.selectedIPAURL {
                viewModel.inspectIPA(at: ipaURL)
            }

        } label: {

            Label(
                "Refresh",
                systemImage: "arrow.clockwise"
            )
        }
        .disabled(
            viewModel.state.selectedIPAURL == nil
        )
    }
}

// MARK: - Preview

#Preview {
    IPAInspectorView()
}
