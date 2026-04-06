//
//  HomeState.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 20/03/26.
//

import Foundation

struct HomeState {
    
    // MARK: - Input Files
    
    /// Selected IPA file path
    var ipaPath: String = ""
    
    /// Selected provisioning profile path
    var profilePath: String = ""
    
    
    // MARK: - App Identity
    
    /// Whether user wants to override bundle identifier
    var useCustomBundleID: Bool = false
    
    /// Bundle identifier (original or overridden)
    var bundleID: String = ""
    
    
    // MARK: - Advanced Options
    
    /// Enable Info.plist modification
    var enablePlistEditing: Bool = false
    
    /// Enable Entitlement modification
    var enableEntitlementEditing: Bool = false
    
    
    // MARK: - Info.plist Modifications
    
    /// User-provided plist key-value entries
    var plistEntries: [PlistKeyValue] = []
    
    
    // MARK: - Entitlement Modifications
    
    /// (Prepared for next step – even if not fully used yet)
    var entitlementEntries: [EntitlementEntry] = []
    
    
    // MARK: - Certificate Configuration
    
    /// Toggle between saved and custom certificate
    var useCustomCert: Bool = false
    
    /// Path to custom .p12 certificate
    var p12Path: String = ""
    
    /// Password for .p12
    var p12Password: String = ""
    
    /// Selected saved certificate
    var selectedCertificate: SigningCertificate?
    
    /// Available certificates
    var certificates: [SigningCertificate] = []
    
    
    // MARK: - Execution State
    
    /// Indicates resign process is running
    var isLoading: Bool = false
    
    
    // MARK: - UI State
    
    /// Error message to display
    var errorMessage: String?
    
    /// Whether unlock prompt should be shown
    var showUnlockPrompt: Bool = false
    
    
    // MARK: - Logs
    
    /// Execution logs
    var log: String = ""
    
    
    // MARK: - Validation
    var isResignEnabled: Bool {
        let hasIPA = !ipaPath.isEmpty
        let hasProfile = !profilePath.isEmpty
        
        let hasCertificate: Bool = {
            if useCustomCert {
                return !p12Path.isEmpty && !p12Password.isEmpty
            } else {
                return selectedCertificate != nil
            }
        }()
        
        return hasIPA && hasProfile && hasCertificate && !isLoading
    }
}
