//
//  CertificatePickerView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 19/03/26.
//

import SwiftUI
import SwiftUI

struct CertificatePickerView: View {

    var title: String = "Certificate"
    let certificates: [SigningCertificate]
    @Binding var selected: SigningCertificate?

    var body: some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Picker("Certificate", selection: $selected) {

                Text("Select Certificate")
                    .tag(SigningCertificate?.none)

                ForEach(certificates) { cert in
                    Text(cert.name)
                        .tag(Optional(cert))
                }
            }
            .pickerStyle(.menu)
        }
    }
}

#Preview {
    CertificatePickerView(
        certificates: [SigningCertificate.dummayCertificate],
        selected: .constant(SigningCertificate.dummayCertificate)
    )
}
