//
//  IPAInspectionService.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import Foundation

/// Default implementation responsible for
/// running the IPA inspection pipeline.
///
/// Responsibilities:
/// - validate IPA file
/// - extract IPA contents
/// - locate .app bundle
/// - parse application metadata
/// - inspect frameworks
/// - build IPAInspection model
///
/// This service should remain focused on
/// orchestration logic.
///
/// Heavy parsing logic should gradually move into:
/// - parsers
/// - analyzers
/// - helper services
final class IPAInspectionService: IPAInspectionServicing {

    // MARK: - Public API

    /// Runs the complete IPA inspection pipeline.
    func inspectIPA(
        at url: URL
    ) async throws -> IPAInspection {

        // Validate file existence
        try validateIPA(at: url)

        // Extract IPA contents
        let extractedURL = try extractIPA(
            at: url
        )

        // Locate .app bundle
        let appBundleURL = try locateAppBundle(
            inside: extractedURL
        )

        // Parse basic application metadata
        let info = try parseInfoPlist(
            from: appBundleURL
        )

        // Parse embedded frameworks
        let frameworks = try scanFrameworks(
            inside: appBundleURL
        )

        // Build inspection model
        return IPAInspection(

            appName: info.appName,

            bundleIdentifier: info.bundleIdentifier,

            version: info.version,

            buildNumber: info.buildNumber,

            teamIdentifier: "UNKNOWN",

            architectures: ["arm64"],

            hasValidSignature: true,

            entitlements: [
                "Push Notifications",
                "Keychain Sharing"
            ],

            frameworks: frameworks
        )
    }
}

// MARK: - Validation

private extension IPAInspectionService {

    /// Ensures the selected file
    /// is a valid IPA.
    func validateIPA(
        at url: URL
    ) throws {

        guard FileManager.default.fileExists(
            atPath: url.path
        ) else {

            throw IPAInspectionError.fileNotFound
        }

        guard url.pathExtension.lowercased() == "ipa" else {

            throw IPAInspectionError.invalidIPA
        }
    }
}

// MARK: - IPA Extraction

private extension IPAInspectionService {

    /// Extracts the IPA contents
    /// into a temporary directory.
    func extractIPA(
        at url: URL
    ) throws -> URL {

        let temporaryDirectory =
            FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(
            at: temporaryDirectory,
            withIntermediateDirectories: true
        )

        // Extract IPA using unzip command
        try IPAExtractorService.unzip(url, to: temporaryDirectory)

        return temporaryDirectory
    }
}

// MARK: - App Bundle Discovery

private extension IPAInspectionService {

    /// Locates the main .app bundle
    /// inside the extracted IPA contents.
    ///
    /// Expected structure:
    /// Payload/AppName.app
    func locateAppBundle(
        inside extractedURL: URL
    ) throws -> URL {

        let payloadURL =
            extractedURL.appendingPathComponent(
                "Payload"
            )

        // Verify Payload directory exists
        guard FileManager.default.fileExists(atPath: payloadURL.path) else {
            throw IPAInspectionError.appBundleNotFound
        }

        let contents = try FileManager.default.contentsOfDirectory(
            at: payloadURL,
            includingPropertiesForKeys: nil
        )

        guard let appBundle = contents.first(
            where: {
                $0.pathExtension == "app"
            }
        ) else {

            throw IPAInspectionError.appBundleNotFound
        }

        return appBundle
    }
}

// MARK: - Info.plist Parsing

private extension IPAInspectionService {

    /// Parses application metadata
    /// from Info.plist.
    func parseInfoPlist(
        from appBundleURL: URL
    ) throws -> ParsedIPAInfo {

        let plistURL =
            appBundleURL.appendingPathComponent(
                "Info.plist"
            )

        guard let dictionary = NSDictionary(
            contentsOf: plistURL
        ) as? [String: Any] else {

            throw IPAInspectionError.infoPlistMissing
        }

        return ParsedIPAInfo(

            appName:
                dictionary["CFBundleDisplayName"]
                as? String
                ?? "Unknown App",

            bundleIdentifier:
                dictionary["CFBundleIdentifier"]
                as? String
                ?? "Unknown",

            version:
                dictionary["CFBundleShortVersionString"]
                as? String
                ?? "0.0",

            buildNumber:
                dictionary["CFBundleVersion"]
                as? String
                ?? "0"
        )
    }
}

// MARK: - Framework Scanning

private extension IPAInspectionService {

    /// Scans embedded frameworks
    /// inside the application bundle.
    func scanFrameworks(
        inside appBundleURL: URL
    ) throws -> [FrameworkInfo] {

        let frameworksURL =
            appBundleURL.appendingPathComponent(
                "Frameworks"
            )

        guard FileManager.default.fileExists(
            atPath: frameworksURL.path
        ) else {

            return []
        }

        let contents = try FileManager.default.contentsOfDirectory(
            at: frameworksURL,
            includingPropertiesForKeys: nil
        )

        return contents
            .filter {
                $0.pathExtension == "framework"
            }
            .map { frameworkURL in

                FrameworkInfo(
                    name: frameworkURL.lastPathComponent,
                    isSigned: true,
                    size: "Unknown"
                )
            }
    }
}