//
//  IPAFrameworksView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import SwiftUI

/// Displays embedded frameworks discovered
/// inside the IPA bundle.
///
/// Purpose:
/// Help developers inspect:
/// - embedded frameworks
/// - signing state
/// - framework size
/// - dependency structure
///
/// Example frameworks:
/// - Firebase.framework
/// - Alamofire.framework
/// - GoogleMaps.framework
///
/// Future improvements may include:
/// - framework version detection
/// - duplicate framework warnings
/// - unsigned framework detection
/// - weak-linked framework analysis
/// - framework search/filtering
struct IPAFrameworksView: View {

    // MARK: - Properties

    /// Complete IPA inspection result.
    let inspection: IPAInspection

    // MARK: - Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 24
        ) {

            headerSection

            frameworkTableSection
        }
        .padding(24)
    }
}

// MARK: - Header Section

private extension IPAFrameworksView {

    /// Displays introductory framework
    /// inspection information.
    var headerSection: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text("Frameworks")
                .font(.largeTitle.bold())

            Text(
                "Embedded frameworks and dependency inspection."
            )
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Framework Table

private extension IPAFrameworksView {

    /// Displays embedded frameworks
    /// using a macOS table layout.
    ///
    /// Columns:
    /// - framework name
    /// - signing status
    /// - size
    var frameworkTableSection: some View {

        Group {

            if inspection.frameworks.isEmpty {

                emptyFrameworkView

            } else {

                Table(inspection.frameworks) {

                    // Framework name
                    TableColumn("Framework") { framework in

                        frameworkNameCell(
                            framework
                        )
                    }

                    // Signature status
                    TableColumn("Signed") { framework in

                        frameworkSigningCell(
                            framework
                        )
                    }

                    // Human-readable size
                    TableColumn("Size") { framework in

                        Text(framework.size)
                    }
                }
            }
        }
    }
}

// MARK: - Empty State

private extension IPAFrameworksView {

    /// Displayed when no embedded
    /// frameworks are detected.
    var emptyFrameworkView: some View {

        ContentUnavailableView(
            "No Frameworks Found",
            systemImage: "shippingbox",
            description: Text(
                "The application does not contain embedded frameworks."
            )
        )
    }
}

// MARK: - Table Cells

private extension IPAFrameworksView {

    /// Displays framework name cell.
    @ViewBuilder
    func frameworkNameCell(
        _ framework: FrameworkInfo
    ) -> some View {

        HStack(spacing: 10) {

            Image(systemName: "shippingbox")

            Text(framework.name)
        }
    }

    /// Displays framework signing status.
    @ViewBuilder
    func frameworkSigningCell(
        _ framework: FrameworkInfo
    ) -> some View {

        HStack(spacing: 8) {

            Image(
                systemName: framework.isSigned
                ? "checkmark.circle.fill"
                : "xmark.circle.fill"
            )
            .foregroundStyle(
                framework.isSigned
                ? .green
                : .red
            )

            Text(
                framework.isSigned
                ? "Valid"
                : "Invalid"
            )
        }
    }
}

// MARK: - Preview

#Preview {

    IPAFrameworksView(
        inspection: .mock
    )
}