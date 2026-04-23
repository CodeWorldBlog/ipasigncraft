//
//  InfoPlistService.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 08/04/26.
//

import Foundation

struct InfoPlistService {
    static func updateInfoPlist(
        at appURL: URL,
        entries: [PlistKeyValue]
    ) throws {
        let plistURL = appURL.appendingPathComponent("Info.plist")
        guard let plist = NSMutableDictionary(contentsOf: plistURL) else {
            throw NSError(domain: "IPASignCraft", code: 2)
        }
        for entry in entries {
            plist[entry.key] = self.parsePlistValue(entry.value)
        }
        plist.write(to: plistURL, atomically: true)
    }
    
    static func updateBundleID(at appURL: URL, newBundleID: String) throws {
        let plistURL = appURL.appendingPathComponent("Info.plist")
        guard let plist = NSMutableDictionary(contentsOf: plistURL) else {
            throw NSError(domain: "IPASignCraft", code: 1)
        }
        plist["CFBundleIdentifier"] = newBundleID
        plist.write(to: plistURL, atomically: true)
    }
    
    static func parsePlistValue(_ input: String) -> Any {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Bool
        if trimmed.lowercased() == "true" { return true }
        if trimmed.lowercased() == "false" { return false }
        
        // Int
        if let intVal = Int(trimmed) {
            return intVal
        }
        
        // Double
        if let doubleVal = Double(trimmed) {
            return doubleVal
        }
        
        // Array (comma-separated: a,b,c)
        if trimmed.contains(",") {
            return trimmed
                .split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespaces) }
        }
        // Default → String
        return trimmed
    }
}


