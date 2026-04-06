//
//  CodeSignService.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 16/03/26.
//

import Foundation

struct CodeSignService {
    
    func resignIPA(
        ipaPath: String,
        profilePath: String,
        certificate: String,
        newBundleID: String,
        infoPlistChanges: [PlistKeyValue]
    ) async throws -> String {
        
        // 1. Create temp folder
        let tempPath = try createTempDirectory(for: ipaPath)
        
        // 2. Extract IPA
        try IPAExtractorService.extractIPA(at: ipaPath, to: tempPath)
        
        // 3. Locate Payload/App
        let payloadPath = try getPayloadPath(from: tempPath)
        let apps = try FileManager.default.contentsOfDirectory(atPath: payloadPath)
        
        guard let app = apps.first(where: { $0.hasSuffix(".app") }) else {
            throw NSError(domain: "AppNotFound", code: 1)
        }
        
        let appPath = "\(payloadPath)/\(app)"
        let appURL = URL(fileURLWithPath: appPath)
        
        // 🔥 4. Update Bundle ID (VERY IMPORTANT)
        try updateBundleID(at: appURL, newBundleID: newBundleID)
        try updateExtensions(at: appURL, newBundleID: newBundleID)
        try updateInfoPlist(at: appURL, entries: infoPlistChanges)
        // 🔍 Debug (optional but powerful)
        try? ShellExecutor.run("grep -R '\(newBundleID)' '\(appPath)' || true")
        
        // 5. Inject provisioning profile
        try ShellExecutor.run("cp '\(profilePath)' '\(appPath)/embedded.mobileprovision'")
        
        // 6. Remove old signatures
        try self.removeOldSignatures(at: appPath)
        
        // 7. Sign correctly (inside → out)
        try self.signAppBundle(appPath: appPath, certificate: certificate)
        
        // 8. Repack IPA
        let ipaOutput = "\(tempPath)/resigned.ipa"
        try ShellExecutor.run("""
        ditto -c -k --sequesterRsrc --keepParent "\(tempPath)/Payload" "\(ipaOutput)"
        """)
        return ipaOutput
    }
}

//MARK: - App sign Process
fileprivate extension CodeSignService {
    func removeOldSignatures(at appPath: String) throws {
        try ShellExecutor.run("rm -rf '\(appPath)/_CodeSignature'")
        try ShellExecutor.run("find '\(appPath)' -name '_CodeSignature' -type d -exec rm -rf {} +")
    }
    
    func signAppBundle(appPath: String, certificate: String) throws {
        let fm = FileManager.default
        
        let frameworksPath = "\(appPath)/Frameworks"
        let pluginsPath = "\(appPath)/PlugIns"
        
        // 1. Sign Frameworks
        if fm.fileExists(atPath: frameworksPath) {
            let frameworks = try fm.contentsOfDirectory(atPath: frameworksPath)
            
            for framework in frameworks {
                let fullPath = "\(frameworksPath)/\(framework)"
                try ShellExecutor.run("""
                    codesign --force --sign "\(certificate)" "\(fullPath)"
                    """)
            }
        }
        
        // 2. Sign Extensions
        if fm.fileExists(atPath: pluginsPath) {
            let plugins = try fm.contentsOfDirectory(atPath: pluginsPath)
            
            for plugin in plugins {
                let fullPath = "\(pluginsPath)/\(plugin)"
                try ShellExecutor.run("""
                    codesign --force --sign "\(certificate)" "\(fullPath)"
                    """)
            }
        }
        
        // 3. Sign Main App LAST
        try ShellExecutor.run("""
            codesign --force --sign "\(certificate)" "\(appPath)"
            """)
    }
}

//Mark - Update Entitlements
fileprivate extension CodeSignService {
    func updateBundleID(at appURL: URL, newBundleID: String) throws {
        let plistURL = appURL.appendingPathComponent("Info.plist")
        guard let plist = NSMutableDictionary(contentsOf: plistURL) else {
            throw NSError(domain: "IPASignCraft", code: 1)
        }
        plist["CFBundleIdentifier"] = newBundleID
        plist.write(to: plistURL, atomically: true)
    }
    
    func updateExtensions(at appURL: URL, newBundleID: String) throws {
        let pluginsURL = appURL.appendingPathComponent("PlugIns")
        
        guard FileManager.default.fileExists(atPath: pluginsURL.path) else { return }
        
        let extensions = try FileManager.default.contentsOfDirectory(at: pluginsURL,
                                                                     includingPropertiesForKeys: nil)
        
        for ext in extensions where ext.pathExtension == "appex" {
            let plistURL = ext.appendingPathComponent("Info.plist")
            
            guard let plist = NSMutableDictionary(contentsOf: plistURL),
                  let oldBundleID = plist["CFBundleIdentifier"] as? String else { continue }
            
            // Preserve suffix (recommended)
            if let suffix = oldBundleID.split(separator: ".").last {
                plist["CFBundleIdentifier"] = "\(newBundleID).\(suffix)"
            } else {
                plist["CFBundleIdentifier"] = newBundleID
            }
            
            plist.write(to: plistURL, atomically: true)
        }
    }
    
    func updateInfoPlist(
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
}

//Mark - Helper Method
fileprivate extension CodeSignService {
    func getPayloadPath(from tempURL: String) throws -> String {
        let ipaURL = URL(fileURLWithPath: tempURL)
        let payloadURL = ipaURL.appendingPathComponent("Payload")
        
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(
            atPath: payloadURL.path,
            isDirectory: &isDir
        )
        
        guard exists && isDir.boolValue else {
            throw NSError(
                domain: "IPASignCraft",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Payload folder not found after extraction"]
            )
        }
        
        return payloadURL.path
    }
    
    func createTempDirectory(for ipaPath: String) throws -> String {
        
        let ipaURL = URL(fileURLWithPath: ipaPath)
        let baseDir = ipaURL.deletingLastPathComponent()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss_SSS"
        
        let tempURL = baseDir.appendingPathComponent("IPASignCraft_\(formatter.string(from: Date()))")
        
        try FileManager.default.createDirectory(
            at: tempURL,
            withIntermediateDirectories: true
        )
        
        return tempURL.path
    }
    
    func parsePlistValue(_ input: String) -> Any {
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
