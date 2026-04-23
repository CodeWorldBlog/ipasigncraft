//
//  SigningStep.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 23/04/26.
//


enum SigningStep: String, CaseIterable {
    case idle
    case preparing = "Start Preparing"
    case extracting = "Extract IPA"
    case modifying = "Modifying IPA"
    case embeddingProfile = "Embed Profile"
    case removeOldSign = "Remove Old Sign"
    case applyingCert = "Apply Certificate"
    case signing = "Code Sign"
    case repackaging = "Repackage IPA"

    case completed = "Completed"
}
