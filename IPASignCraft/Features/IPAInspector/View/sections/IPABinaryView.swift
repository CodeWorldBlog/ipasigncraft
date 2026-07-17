//
//  IPABinaryView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import SwiftUI

/// Displays binary-level inspection data
/// extracted from the IPA executable.
///
/// Purpose:
/// Provide technical information related to:
/// - CPU architectures
/// - Mach-O binary analysis
/// - encryption state
/// - linked binary information
///
/// This screen is more technical than
/// General or Entitlements views and is
/// primarily useful for developers,
/// reverse engineering analysis and
/// signing diagnostics.
///
/// Future improvements may include:
/// - Mach-O load commands
/// - segment analysis
/// - linked dylibs
/// - bitcode detection
/// - binary size analysis
/// - symbol inspection
struct IPABinaryView: View {

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

            architectureSection

            binaryStatusSection
        }
    }
}

// MARK: - Header Section

private extension IPABinaryView {

    /// Displays introductory information
    /// about binary inspection.
    var headerSection: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text("Binary Analysis")
                .font(.largeTitle.bold())

            Text(
                "Technical inspection details extracted from the application executable."
            )
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Architecture Section

private extension IPABinaryView {

    /// Displays supported CPU architectures.
    ///
    /// Examples:
    /// - arm64
    /// - armv7
    /// - x86_64
    var architectureSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                title: "Architectures"
            )

            LazyVStack(spacing: 12) {

                ForEach(
                    inspection.architectures,
                    id: \.self
                ) { architecture in

                    architectureRow(
                        title: architecture
                    )
                }
            }
        }
    }
}

// MARK: - Binary Status Section

private extension IPABinaryView {

    /// Displays simplified binary validation
    /// and executable metadata.
    ///
    /// Future versions may include:
    /// - encryption detection
    /// - bitcode availability
    /// - executable size
    /// - PIE support
    var binaryStatusSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                title: "Binary Status"
            )

            statusRow(
                title: "Executable Present",
                passed: true
            )

            statusRow(
                title: "Architectures Detected",
                passed: !inspection.architectures.isEmpty
            )

            statusRow(
                title: "Signature Linked",
                passed: inspection.hasValidSignature
            )
        }
    }
}

// MARK: - Reusable Rows

private extension IPABinaryView {

    /// Displays architecture information row.
    @ViewBuilder
    func architectureRow(
        title: String
    ) -> some View {

        HStack(spacing: 12) {

            Image(systemName: "cpu")
                .foregroundStyle(.blue)

            Text(title)

            Spacer()
        }
        .padding(14)
        .background(
            Color.gray.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }

    /// Displays validation/status row.
    @ViewBuilder
    func statusRow(
        title: String,
        passed: Bool
    ) -> some View {

        HStack(spacing: 10) {

            Image(
                systemName: passed
                ? "checkmark.circle.fill"
                : "xmark.circle.fill"
            )
            .foregroundStyle(
                passed
                ? .green
                : .red
            )

            Text(title)

            Spacer()
        }
    }
}

// MARK: - Shared Helpers

private extension IPABinaryView {

    /// Shared section title styling.
    func sectionHeader(
        title: String
    ) -> some View {

        Text(title)
            .font(.title3.bold())
    }
}

// MARK: - Preview

#Preview {

    IPABinaryView(
        inspection: .mock
    )
}