//
//  ShellExecutor.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 17/03/26.
//

import Foundation

struct ShellExecutor {

    // Simple fire-and-forget (your existing use case)
    static func run(_ command: String) throws {
        let result = try runWithOutput(command)

        if result.status != 0 {
            throw NSError(
                domain: "ShellError",
                code: Int(result.status),
                userInfo: [NSLocalizedDescriptionKey: result.output]
            )
        }
    }

    // Full control (used by KeychainService)
    static func runWithOutput(_ command: String) throws -> ShellResult {

        let process = Process()
        let pipe = Pipe()

        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]

        process.standardOutput = pipe
        process.standardError = pipe

        process.launch()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        return ShellResult(
            output: output,
            status: process.terminationStatus
        )
    }
}

struct ShellResult {
    let output: String
    let status: Int32
}
