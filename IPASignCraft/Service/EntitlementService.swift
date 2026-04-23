//
//  EntitlementService.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 07/04/26.
//

import Foundation

struct EntitlementService {
    
    static func prepareEntitlements(
        appPath: String,
        updates: [EntitlementEntry],
        outputDir: String
    ) throws -> String {
        
        // 1. Extract existing
        let existingRaw = try self.extractRaw(from: appPath)
        
        // 2. Convert to model
        let existing = convertToModel(existingRaw)
        
        // 3. Convert updates
        let updateDict = Dictionary(uniqueKeysWithValues: updates.map {
            ($0.key, $0.value)
        })
        
        // 4. Merge
        let merged = merge(base: existing, updates: updateDict)
    
        // 5. Convert back to plist format
        let final = merged.mapValues { $0.toAny() }
        
        // 6. Write
        let path = "\(outputDir)/entitlements.plist"
        try write(final, to: path)
        
        return path
    }
}

private extension EntitlementService {
    static func extractRaw(from appPath: String) throws -> [String: Any] {
        
        let result = try ShellExecutor.runWithOutput("""
        /usr/bin/codesign -d --entitlements :- "\(appPath)"
        """)
        
        guard let data = result.output.data(using: .utf8) else {
            throw IPASignCraftError.entitlementExtractionFailed
        }
        
        let plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        )
        
        return plist as? [String: Any] ?? [:]
    }
}

private extension EntitlementService {
    static func convertToModel(
        _ raw: [String: Any]
    ) -> [String: EntitlementValue] {
        
        raw.compactMapValues {
            EntitlementValue.from(any: $0)
        }
    }
}

private extension EntitlementService {
    static func merge(
        base: [String: EntitlementValue],
        updates: [String: EntitlementValue]
    ) -> [String: EntitlementValue] {
        
        var result = base
        
        for (key, newValue) in updates {
            
            if case .array(let newArray) = newValue,
               case .array(let existingArray)? = result[key] {
                
                let combined = existingArray + newArray
                result[key] = .array(removeDuplicates(combined))
                
            } else {
                result[key] = newValue
            }
        }
        
        return result
    }
    
    static func removeDuplicates(
        _ array: [EntitlementValue]
    ) -> [EntitlementValue] {
        
        var seen = Set<String>()
        
        return array.filter {
            let key = "\($0)"
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
    }
}

private extension EntitlementService {
    static func write(
        _ plist: [String: Any],
        to path: String
    ) throws {
        
        let data = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0
        )
        
        try data.write(to: URL(fileURLWithPath: path))
    }
}
