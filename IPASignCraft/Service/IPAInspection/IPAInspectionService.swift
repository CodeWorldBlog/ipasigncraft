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

    private struct SecurityInspectionReport {
        let hasValidSignature: Bool
        let teamIdentifier: String
        let architectures: [String]
        let entitlements: [String]
    }

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
        defer { try? FileManager.default.removeItem(at: extractedURL) }

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

        let securityReport = inspectSecurity(
            for: appBundleURL,
            executableName: info.executableName
        )

        // Build inspection model
        return IPAInspection(

            appName: info.appName,

            bundleIdentifier: info.bundleIdentifier,

            version: info.version,

            buildNumber: info.buildNumber,

            teamIdentifier: securityReport.teamIdentifier,

            architectures: securityReport.architectures,

            hasValidSignature: securityReport.hasValidSignature,

            entitlements: securityReport.entitlements,

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
                ?? "0",

            executableName:
                dictionary["CFBundleExecutable"]
                as? String
        )
    }
}

// MARK: - Security Inspection

private extension IPAInspectionService {

    private func inspectSecurity(
        for appBundleURL: URL,
        executableName: String?
    ) -> SecurityInspectionReport {
        let appExecutableURL = appBundleURL.appendingPathComponent(executableName ?? "")
        let embeddedProfileURL = appBundleURL.appendingPathComponent("embedded.mobileprovision")

        let hasValidSignature = isSignedItem(at: appBundleURL) || isSignedItem(at: appExecutableURL)
        let teamIdentifier = extractTeamIdentifier(from: appExecutableURL, profileURL: embeddedProfileURL)
        let architectures = extractArchitectures(from: appExecutableURL)
        let entitlements = extractEntitlements(from: appExecutableURL, profileURL: embeddedProfileURL)

        return SecurityInspectionReport(
            hasValidSignature: hasValidSignature,
            teamIdentifier: teamIdentifier,
            architectures: architectures,
            entitlements: entitlements
        )
    }

    private func isSignedItem(at url: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: url.path) else { return false }

        let result = try? ShellExecutor.runWithOutput("/usr/bin/codesign --verify --deep --strict \"\(url.path)\"")
        return result?.status == 0
    }

    private func extractTeamIdentifier(from executableURL: URL, profileURL: URL) -> String {
        let profileResult = try? ShellExecutor.runWithOutput("/usr/bin/security cms -D -i \"\(profileURL.path)\"")
        guard let profileOutput = profileResult?.output.data(using: .utf8),
              let plist = try? PropertyListSerialization.propertyList(from: profileOutput, options: [], format: nil) as? [String: Any],
              let entitlements = plist["Entitlements"] as? [String: Any],
              let appIdentifier = entitlements["application-identifier"] as? String else {
            return "UNKNOWN"
        }

        let parts = appIdentifier.split(separator: ".")
        if parts.count >= 2 {
            return String(parts[0])
        }

        return "UNKNOWN"
    }

    private func extractArchitectures(from executableURL: URL) -> [String] {
        guard FileManager.default.fileExists(atPath: executableURL.path) else { return [] }

        let result = try? ShellExecutor.runWithOutput("/usr/bin/lipo -info \"\(executableURL.path)\"")
        guard let output = result?.output else { return [] }

        // lipo -info output formats:
        //   Fat:  "Architectures in the fat file: <path> are: armv7 arm64"
        //   Thin: "Non-fat file: <path> is architecture: arm64"
        // In both cases the architecture names appear after the last colon.
        let line = output.split(separator: "\n").first.map(String.init) ?? output
        guard let lastColon = line.lastIndex(of: ":") else { return [] }
        let archString = String(line[line.index(after: lastColon)...])

        return archString
            .components(separatedBy: .whitespaces)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func extractEntitlements(from executableURL: URL, profileURL: URL) -> [String] {
        let appEntitlementsResult = try? ShellExecutor.runWithOutput("/usr/bin/codesign -d --entitlements :- \"\(executableURL.path)\"")
        let profileResult = try? ShellExecutor.runWithOutput("/usr/bin/security cms -D -i \"\(profileURL.path)\"")

        var extracted: [String] = []

        if let output = appEntitlementsResult?.output,
           let plist = try? PropertyListSerialization.propertyList(from: Data(output.utf8), options: [], format: nil) as? [String: Any] {
            extracted = plist.keys.sorted().map { key in
                if key == "com.apple.security.application-groups" {
                    return "App Groups"
                }
                if key == "keychain-access-groups" {
                    return "Keychain Sharing"
                }
                if key == "aps-environment" {
                    return "Push Notifications"
                }
                return key
            }
        }

        if let profileOutput = profileResult?.output.data(using: .utf8),
           let plist = try? PropertyListSerialization.propertyList(from: profileOutput, options: [], format: nil) as? [String: Any],
           let entitlements = plist["Entitlements"] as? [String: Any] {
            let profileKeys = entitlements.keys.sorted().map { key in
                switch key {
                case "com.apple.security.application-groups": return "App Groups"
                case "keychain-access-groups": return "Keychain Sharing"
                case "aps-environment": return "Push Notifications"
                default: return key
                }
            }
            extracted = Array(Set(extracted + profileKeys)).sorted()
        }

        return extracted
    }

    private func humanReadableSize(for url: URL) -> String {
        let size = byteSize(for: url)
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    private func byteSize(for url: URL) -> Int64 {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return 0
        }

        if !isDirectory.boolValue {
            let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
            return (attrs?[.size] as? NSNumber)?.int64Value ?? 0
        }

        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey, .fileAllocatedSizeKey, .totalFileAllocatedSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }

        var total: Int64 = 0

        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: [.isRegularFileKey, .fileAllocatedSizeKey, .totalFileAllocatedSizeKey]),
                  values.isRegularFile == true else {
                continue
            }

            if let allocated = values.totalFileAllocatedSize ?? values.fileAllocatedSize {
                total += Int64(allocated)
            } else {
                let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
                total += (attrs?[.size] as? NSNumber)?.int64Value ?? 0
            }
        }

        return total
    }
}

// MARK: - Framework Scanning

private extension IPAInspectionService {

    /// Scans embedded frameworks
    /// inside the application bundle.
    func scanFrameworks(
        inside appBundleURL: URL
    ) throws -> [FrameworkInfo] {

        guard let enumerator = FileManager.default.enumerator(
            at: appBundleURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var discovered: [URL] = []

        for case let item as URL in enumerator {
            let ext = item.pathExtension.lowercased()

            if ext == "framework" {
                discovered.append(item)
                continue
            }

            if ext == "dylib" {
                discovered.append(item)
            }
        }

        let deduplicated = Dictionary(
            grouping: discovered,
            by: { $0.standardizedFileURL.path }
        )
        .compactMap { $0.value.first }
        .sorted {
            $0.path.localizedCaseInsensitiveCompare($1.path) == .orderedAscending
        }

        return deduplicated.map { itemURL in
            return FrameworkInfo(
                name: itemURL.lastPathComponent,
                isSigned: isSignedItem(at: itemURL),
                size: humanReadableSize(for: itemURL)
            )
        }
    }
}