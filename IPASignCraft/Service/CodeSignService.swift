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
        infoPlistChanges: [PlistKeyValue],
        entitlementUpdates: [EntitlementEntry]
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
        try InfoPlistService.updateBundleID(at: appURL, newBundleID: newBundleID)
        try InfoPlistService.updateInfoPlist(at: appURL, entries: infoPlistChanges)
        try updateExtensions(at: appURL, newBundleID: newBundleID)
       
        // 🔍 Debug (optional but powerful)
        try? ShellExecutor.run("grep -R '\(newBundleID)' '\(appPath)' || true")
        
        // 5. Inject provisioning profile
        try ShellExecutor.run("cp '\(profilePath)' '\(appPath)/embedded.mobileprovision'")
        
        // 🔥 6. Prepare entitlements
        let entitlementsPath = try EntitlementService.prepareEntitlements(
            appPath: appPath,
            updates: entitlementUpdates,
            outputDir: tempPath
        )
        
        
        // 7. Remove old signatures
        try self.removeOldSignatures(at: appPath)
        
        // 8. Sign correctly (inside → out)
        try self.signAppBundle(appPath: appPath, certificate: certificate, entitlementsPath: entitlementsPath)
        
        // 9. Repack IPA
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
    
    func signAppBundle(
        appPath: String,
        certificate: String,
        entitlementsPath: String
    ) throws {
        
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
        
        // 2. Sign Extensions (⚠️ usually WITHOUT entitlements)
        if fm.fileExists(atPath: pluginsPath) {
            let plugins = try fm.contentsOfDirectory(atPath: pluginsPath)
            
            for plugin in plugins {
                let fullPath = "\(pluginsPath)/\(plugin)"
                try ShellExecutor.run("""
                codesign --force --sign "\(certificate)" "\(fullPath)"
                """)
            }
        }
        
        try ShellExecutor.run("""
        codesign --force \
        --sign "\(certificate)" \
        --entitlements "\(entitlementsPath)" \
        "\(appPath)"
        """)
    }
}

//Mark - Update Entitlements
fileprivate extension CodeSignService {
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
}
