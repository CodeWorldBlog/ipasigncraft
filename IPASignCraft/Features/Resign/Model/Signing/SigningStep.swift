//
//  SigningStep.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 23/04/26.
//


enum SigningStep: String, CaseIterable {
    case idle
    case extracting = "Extract IPA"
    case validating = "Validate Files"
    case applyingCert = "Apply Certificate"
    case embeddingProfile = "Embed Profile"
    case signing = "Code Sign"
    case repackaging = "Repackage IPA"

    case completed = "Completed"
}
