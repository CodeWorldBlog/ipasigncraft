//
//  IPAExtractorService.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 16/03/26.
//

import Foundation

struct IPAExtractorService {
    static func extractIPA(at path: String, to destinationPath: String) throws {
        
        let process = Process()
        process.launchPath = "/usr/bin/unzip"
        process.arguments = [path, "-d", destinationPath]
        
        try process.run()
        process.waitUntilExit()
    }
}
