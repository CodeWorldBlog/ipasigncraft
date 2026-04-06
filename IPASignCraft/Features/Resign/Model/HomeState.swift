//
//  HomeState.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 20/03/26.
//

import Foundation

struct HomeState {
    var ipaPath: String = ""
    var profilePath: String = ""
    var useCustomBundleID: Bool = false
    var bundleID: String = ""
    var plistEntries: [PlistKeyValue] = []
    
    var useCustomCert: Bool = false
    var p12Path: String = ""
    var p12Password: String = ""
    var selectedCertificate: SigningCertificate?
    var certificates: [SigningCertificate] = []
    
    var log: String = ""
    
    var isLoading: Bool = false
    
    var errorMessage: String?
    var showUnlockPrompt: Bool = false
    // MARK: - Validation
    var isResignEnabled: Bool {
        let hasIPA = !ipaPath.isEmpty
        let hasProfile = !profilePath.isEmpty
        let hasCertificate = (selectedCertificate?.isEmpty == false)
        
        
        return hasIPA && hasProfile && hasCertificate && !isLoading
    }
}

struct PlistKeyValue: Identifiable {
    let id = UUID()
    var key: String = ""
    var value: String = ""
}
