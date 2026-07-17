//
//  IPAInspectionError.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import Foundation

/// Errors thrown during IPA inspection.
enum IPAInspectionError: LocalizedError {

    case fileNotFound

    case invalidIPA

    case extractionFailed

    case appBundleNotFound

    case infoPlistMissing

    // MARK: - LocalizedError

    var errorDescription: String? {

        switch self {

        case .fileNotFound:
            return "The selected IPA file could not be found."

        case .invalidIPA:
            return "The selected file is not a valid IPA."

        case .extractionFailed:
            return "Failed to extract IPA contents."

        case .appBundleNotFound:
            return "No .app bundle was found inside the IPA."

        case .infoPlistMissing:
            return "Info.plist could not be loaded."
        }
    }
}