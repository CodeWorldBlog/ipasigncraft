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
    var isEmpty: Bool {
        return self.name.isEmpty
    }
    
    static let dummayCertificate = SigningCertificate(name: "Apple Distribution: Saurav Nagpal")
}
