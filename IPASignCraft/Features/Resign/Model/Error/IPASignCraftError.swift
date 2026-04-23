//
//  IPASignCraftError.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 07/04/26.
//

import Foundation

enum IPASignCraftError: Error {
    
    // MARK: - Extraction
    case ipaNotFound(path: String)
    case extractionFailed(reason: String)
    
    // MARK: - Shell Execution
    
    case shellCommandFailed(command: String, output: String)
    case invalidShellOutput
    
    // MARK: - Entitlements
    
    case entitlementExtractionFailed
    case entitlementInvalidFormat
    case entitlementMergeFailed
    case missingRequiredEntitlement(key: String)
    case entitlementWriteFailed(path: String)
    
    // MARK: - Signing
    
    case signingFailed(reason: String)
    case certificateNotFound(name: String)
    case provisioningProfileMissing
    case provisioningMismatch(reason: String)
    
    // MARK: - App Structure
    
    case appBundleNotFound
    case frameworksNotFound
    case invalidAppStructure(reason: String)
    
    // MARK: - Validation
    
    case validationFailed(reason: String)
    case tamperedOrInvalidSignature
    
    // MARK: - Packaging
    
    case repackagingFailed(reason: String)
    
    // MARK: - Unknown
    
    case unknown(Error)
}
