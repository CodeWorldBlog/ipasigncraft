//
//  IPAExtractorService.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 16/03/26.
//

import Foundation

struct ProvisionExtractService {
    static func extractBundleID(from profilePath: String) throws -> String? {
        let command = """
        /usr/bin/security cms -D -i "\(profilePath)"
        """
        let result = try ShellExecutor.runWithOutput(command)
        
        guard result.status == 0 else {
            throw NSError(
                domain: "IPASignCraft",
                code: Int(result.status),
                userInfo: [NSLocalizedDescriptionKey: result.output]
            )
        }
        
        guard let data = result.output.data(using: .utf8) else {
            return nil
        }
        
        guard let plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        ) as? [String: Any],
              let entitlements = plist["Entitlements"] as? [String: Any],
              let appIdentifier = entitlements["application-identifier"] as? String
        else {
            return nil
        }
        
        // Format: TEAMID.bundleID
        let parts = appIdentifier.split(separator: ".", maxSplits: 1)
        
        guard parts.count == 2 else { return nil }
        
        return String(parts[1]) // bundle ID or wildcard
    }
}

