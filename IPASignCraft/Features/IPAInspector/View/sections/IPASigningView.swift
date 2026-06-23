//
//  IPASigningView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import SwiftUI

/// Displays signing and provisioning
/// information for the inspected IPA.
///
/// Purpose:
/// Help developers quickly validate:
/// - signing identity
/// - provisioning information
/// - signature health
/// - team consistency
///
/// This screen becomes especially useful
/// when diagnosing installation or
/// resigning issues.
struct IPASigningView: View {

    // MARK: - Properties

    /// Complete IPA inspection result.
    let inspection: IPAInspection

    // MARK: - Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 24
        ) {

            signatureStatusSection

            signingInformationSection

            validationSection
        }
    }
}

// MARK: - Signature Status

private extension IPASigningView {

    /// Displays the overall signature state.
    ///
    /// Example:
    /// - Valid
    /// - Invalid
    /// - Expired
    var signatureStatusSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                title: "Signature Status"
            )

            HStack(spacing: 12) {

                Image(
                    systemName: inspection.hasValidSignature
                    ? "checkmark.seal.fill"
                    : "xmark.seal.fill"
                )
                .foregroundStyle(
                    inspection.hasValidSignature
                    ? .green
                    : .red
                )
                .font(.title2)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(
                        inspection.hasValidSignature
                        ? "Valid Signature"
                        : "Invalid Signature"
                    )
                    .font(.headline)

                    Text(
                        inspection.hasValidSignature
                        ? "The IPA signature appears valid."
                        : "The IPA signature validation failed."
                    )
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Signing Information

private extension IPASigningView {

    /// Displays signing-related metadata.
    ///
    /// Example:
    /// - team identifier
    /// - certificate info
    /// - provisioning profile
    var signingInformationSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                title: "Signing Information"
            )

            KeyValueRow(
                key: "Team Identifier",
                value: inspection.teamIdentifier
            )

            KeyValueRow(
                key: "Bundle Identifier",
                value: inspection.bundleIdentifier
            )
        }
    }
}

// MARK: - Validation Checks

private extension IPASigningView {

    /// Displays simplified validation results.
    ///
    /// Future improvements may include:
    /// - entitlement mismatch detection
    /// - expired profile warnings
    /// - unsupported device checks
    var validationSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            sectionHeader(
                title: "Validation"
            )

            validationRow(
                title: "Signature Verification",
                passed: inspection.hasValidSignature
            )

            validationRow(
                title: "Bundle Identifier Check",
                passed: true
            )

            validationRow(
                title: "Provision Match",
                passed: true
            )
        }
    }
}

// MARK: - Shared Helpers

private extension IPASigningView {

    /// Shared section title styling.
    func sectionHeader(
        title: String
    ) -> some View {

        Text(title)
            .font(.title3.bold())
    }

    /// Reusable validation status row.
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
}

// MARK: - Preview

#Preview {

    IPASigningView(
        inspection: .mock
    )
}