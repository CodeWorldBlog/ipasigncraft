//
//  SigningStep.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 23/04/26.
//


enum SigningStep: CaseIterable {
    case idle
    case preparing
    case extracting
    case modifying
    case embeddingProfile
    case removeOldSign
    case applyingCert
    case signing
    case repackaging
    case completed
}
