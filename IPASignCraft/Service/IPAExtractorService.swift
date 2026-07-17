//
//  IPAExtractorService.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 16/03/26.
//

import Foundation

struct IPAExtractorService {
    static func extractIPA(at ipaURL: URL, to workspace: URL) throws -> URL {
        // unzip IPA → creates Payload automatically
        try unzip(ipaURL, to: workspace)
        
        let payloadURL = workspace.appendingPathComponent("Payload")
        
        guard let appURL = try FileManager.default
            .contentsOfDirectory(at: payloadURL, includingPropertiesForKeys: nil)
            .first(where: { $0.pathExtension == "app" }) else {
            throw IPASignCraftError.ipaNotFound(path: ipaURL.path())
        }
        return appURL
    }
    
    static func unzip(_ ipaURL: URL, to destination: URL) throws {
        
        // Verify IPA file exists and is readable
        guard FileManager.default.fileExists(atPath: ipaURL.path) else {
            throw IPASignCraftError.ipaNotFound(path: ipaURL.path)
        }
        
        // Verify destination directory exists
        if !FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.createDirectory(
                at: destination,
                withIntermediateDirectories: true
            )
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = [
            ipaURL.path,
            "-d",
            destination.path
        ]
        
        // Capture stderr for better error messages
        let errorPipe = Pipe()
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            
            throw IPASignCraftError.extractionFailed(reason: errorMessage)
        }
    }
}
