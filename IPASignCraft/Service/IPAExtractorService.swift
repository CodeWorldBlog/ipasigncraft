//
//  IPAExtractorService.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 16/03/26.
//

import Foundation

struct IPAExtractorService {
    static func extractIPA(at ipaURL: URL, to workspace: URL) throws -> URL {
        let payloadURL = workspace.appendingPathComponent("Payload")
        
        try FileManager.default.createDirectory(at: payloadURL, withIntermediateDirectories: true)
        // unzip IPA → Payload
        try unzip(ipaURL, to: workspace)
        
        guard let appURL = try FileManager.default
            .contentsOfDirectory(at: payloadURL, includingPropertiesForKeys: nil)
            .first(where: { $0.pathExtension == "app" }) else {
            throw IPASignCraftError.ipaNotFound(path: ipaURL.path())
        }
        return appURL
    }
    
    static func unzip(_ ipaURL: URL, to destination: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = [
            ipaURL.path,
            "-d",
            destination.path
        ]
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            throw NSError(domain: "Unzip failed", code: Int(process.terminationStatus))
        }
    }
}
