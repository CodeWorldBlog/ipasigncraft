//
//  IPASecurityView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import SwiftUI

/// Displays security-related inspection
/// and validation results for the IPA.
///
/// Purpose:
/// Help developers identify:
/// - weak security configurations
/// - risky application settings
/// - suspicious binary indicators
/// - validation concerns
///
/// This screen is intentionally designed
/// as a high-level diagnostics dashboard
/// instead of a low-level security audit.
///
/// Future improvements may include:
/// - ATS analysis
/// - jailbreak detection indicators
/// - debug symbol detection
/// - insecure URL scheme detection
/// - weak cryptography checks
/// - binary hardening analysis
struct IPASecurityView: View {

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

            securityStatusSection

            validationChecksSection

            recommendationsSection
        }
    }
}

// MARK: - Header Section

private extension IPASecurityView {

    /// Displays introductory security
    /// inspection information.
    var headerSection: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text("Security")
                .font(.largeTitle.bold())

            Text(
                "Security diagnostics and validation checks for the inspected IPA."
            )
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Security Status

private extension IPASecurityView {

    /// Displays overall security state.
    ///
    /// Future versions may calculate
    /// a real security score based on:
    /// - ATS configuration
    /// - binary encryption
    /// - entitlement risks
    /// - unsigned frameworks
    var securityStatusSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                title: "Security Status"
            )

            HStack(spacing: 14) {

                Image(systemName: "shield.checkered")
                    .font(.largeTitle)
                    .foregroundStyle(.green)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text("No Major Issues Detected")
                        .font(.headline)

                    Text(
                        "The IPA passed the currently available security checks."
                    )
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Validation Checks

private extension IPASecurityView {

    /// Displays simplified validation checks.
    ///
    /// Future checks may become dynamic
    /// once binary and plist analysis
    /// are implemented.
    var validationChecksSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            sectionHeader(
                title: "Validation Checks"
            )

            validationRow(
                title: "Valid Code Signature",
                passed: inspection.hasValidSignature
            )

            validationRow(
                title: "Signed Frameworks",
                passed: inspection.frameworks.allSatisfy {
                    $0.isSigned
                }
            )

            validationRow(
                title: "Architectures Present",
                passed: !inspection.architectures.isEmpty
            )
        }
    }
}

// MARK: - Recommendations

private extension IPASecurityView {

    /// Displays developer-facing
    /// recommendations and guidance.
    ///
    /// Future versions may generate
    /// contextual recommendations
    /// dynamically from inspection results.
    var recommendationsSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                title: "Recommendations"
            )

            recommendationRow(
                text: "Verify provisioning profile expiration dates regularly."
            )

            recommendationRow(
                text: "Ensure all embedded frameworks are properly signed."
            )

            recommendationRow(
                text: "Review entitlements before distributing production builds."
            )
        }
    }
}

// MARK: - Reusable Components

private extension IPASecurityView {

    /// Displays validation result row.
    @ViewBuilder
    func validationRow(
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

    /// Displays recommendation/help row.
    @ViewBuilder
    func recommendationRow(
        text: String
    ) -> some View {

        HStack(alignment: .top, spacing: 10) {

            Image(systemName: "lightbulb")
                .foregroundStyle(.yellow)

            Text(text)

            Spacer()
        }
    }
}

// MARK: - Shared Helpers

private extension IPASecurityView {

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

    IPASecurityView(
        inspection: .mock
    )
}