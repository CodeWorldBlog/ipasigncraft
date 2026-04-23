//
//  CertificateInput.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 23/04/26.
//

import Foundation

enum CertificateRequest {
    case saved(SigningCertificate)           // from your stored certs
    case p12(url: URL, password: String)
}
