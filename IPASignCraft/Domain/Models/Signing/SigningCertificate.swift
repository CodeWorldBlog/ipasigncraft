//
//  SigningCertificate.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 19/03/26.
//

import Foundation

struct SigningCertificate: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let identity: String
    var isEmpty: Bool {
        return self.name.isEmpty
    }
    
    static let dummayCertificate = SigningCertificate(name: "Apple Distribution: Saurav Nagpal", identity: "ABCDEF1234567890ABCDEF1234567890ABCDEF12")
}
