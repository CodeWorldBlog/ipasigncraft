//
//  HomeState.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 20/03/26.
//

import Foundation

enum CertificateMode {
    case keychain
    case custom
}

struct HomeState {
    
    // MARK: - Input Files
    
    /// Selected IPA file path
    var ipaURL: URL?
    
    /// Selected provisioning profile path
    var profileURL: URL?
    
    
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
    
    /// Selection between keychian and custom certificate
    var certMode: CertificateMode = .keychain
    
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
    
    /// Indicates Advance  Option Expand/Collapse
    var isAdvancedExpanded = false
    
    // MARK: - UI State
    
    /// Error message to display
    var errorMessage: String?
    
    /// Whether unlock prompt should be shown
    var showUnlockPrompt: Bool = false
    // MARK: - Logs
    
    /// Execution logs
    var log: String = ""
    
    // MARK: - Signing Steps
    var progress: Double = 0.0
    var currentStep: SigningStep = .idle
    
    // MARK: - Validation
    var isSigning: Bool = false
    var isResignEnabled: Bool {
        let hasIPA = (ipaURL != nil)
        let hasProfile = (profileURL != nil)
        
        let hasCertificate: Bool = {
            if self.certMode == .custom {
                return !p12Path.isEmpty && !p12Password.isEmpty
            } else {
                return selectedCertificate != nil
            }
        }()
        
        return hasIPA && hasProfile && hasCertificate && !isLoading
    }
}

extension HomeState {
    func isStepCompleted(_ step: SigningStep) -> Bool {
        switch step {
        case .preparing: return progress >= 0.5
        case .extracting: return progress >= 0.15
        case .modifying: return progress >= 0.30
        case .embeddingProfile: return progress >= 0.5
        case .removeOldSign: return progress >= 0.65
        case .applyingCert: return progress >= 0.8
        case .signing: return progress >= 0.9
        case .repackaging: return progress >= 1.0
        default: return false
        }
    }
}

