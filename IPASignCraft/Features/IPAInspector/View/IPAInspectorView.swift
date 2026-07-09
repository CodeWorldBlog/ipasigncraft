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

        ScreenShell {
            HStack(alignment: .top, spacing: Spacing.lg) {

                // Left column: main dashboard
                VStack(alignment: .center, spacing: Spacing.lg) {

                    headerSection

                    VStack(alignment: .leading, spacing: Spacing.lg) {

                        // File upload section
                        fileUploadSection

                        // Immediate placeholder summary while background inspection runs.
                        if viewModel.state.inspection == nil, let summary = viewModel.state.selectedFileSummary {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                HStack(alignment: .center, spacing: Spacing.base) {
                                    InfoRow(
                                        icon: "doc.fill",
                                        color: AppColors.accent,
                                        title: summary.fileName,
                                        subtitle: "\(summary.humanSize)\(summary.modifiedDate != nil ? " • \(summary.modifiedDate!)" : "")"
                                    )

                                    Spacer()

                                    // Small inline activity indicator
                                    if viewModel.state.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .scaleEffect(0.8)
                                    }
                                }
                                .padding(Spacing.base)
                                .background(RoundedRectangle(cornerRadius: Radius.sm).fill(AppColors.cardSurface))
                                .shadow(color: AppColors.cardShadow, radius: 4, x: 0, y: 1)
                            }
                        }

                        // Inspection results
                        if let inspection = viewModel.state.inspection {

                            Divider()

                            // Quick stat cards
                            statCardsSection(inspection: inspection)

                            // Expandable sections
                            inspectionDetailsSection(inspection: inspection)

                        }
                    }
                    .frame(maxWidth: 800, alignment: .leading)
                    .padding(.horizontal, Spacing.lg)
                }
                .frame(maxWidth: 800)

                // Right column: console and compact status
                VStack(alignment: .leading, spacing: Spacing.base) {

                    // Compact completion/status box (shows waiting/processing/complete)
                    compactCompletionStatusSection

                    // Reusable console component (shared with HomeView)
                    ConsoleView(
                        title: "Console",
                        icon: "terminal",
                        logContent: Binding(
                            get: { viewModel.state.log },
                            set: { viewModel.state.log = $0 }
                        ),
                        onClear: {
                            viewModel.clearLogs()
                        }
                    )

                    Spacer()
                }
                .frame(width: 340)
            }
            .padding(.vertical, Spacing.lg)
            .padding(.horizontal, Spacing.lg)
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
        WatercolorBackground()
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
            onSelect: { _ in },
            selectedSubtitle: "Ready For Inspection"
        )
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
    /// Compact variant of completion status suitable for sidebar.
    var compactCompletionStatusSection: some View {

        // Derive status pieces from view model state
        let (iconName, iconColor, titleText, subtitleText): (String, Color, String, String) = {
            if let error = viewModel.state.errorMessage {
                return ("xmark.octagon.fill", .red, "Inspection failed", error)
            }

            if viewModel.state.selectedIPAURL == nil {
                return ("tray", .gray, "Waiting for IPA", "Select or drop an IPA")
            }

            if viewModel.state.isLoading {
                return ("arrow.triangle.2.circlepath", AppColors.accentHover, "Processing IPA", "Scanning...")
            }

            if viewModel.state.inspection != nil {
                let ts = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
                return ("checkmark.circle.fill", .green, "Inspection completed", ts)
            }

            return ("info.circle.fill", .blue, "Ready", "")
        }()

        return HStack(spacing: Spacing.sm) {

            // Icon badge
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            // Textual info + optional progress
            VStack(alignment: .leading, spacing: 4) {
                Text(titleText)
                    .font(AppFont.small)
                    .fontWeight(.semibold)

                if !subtitleText.isEmpty {
                    Text(subtitleText)
                        .font(AppFont.caption)
                        .foregroundColor(AppColors.secondaryText)
                }

                if viewModel.state.isLoading {
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accent))
                        .frame(height: 6)
                        .cornerRadius(3)
                        .padding(.top, 6)
                }
            }
            Spacer()
        }
        .padding(Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(AppColors.cardSurface)
        )
        .shadow(color: AppColors.cardShadow, radius: 6, x: 0, y: 2)
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
