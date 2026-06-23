//
//  KeyValueRow.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import SwiftUI

/// Reusable key-value row used throughout
/// the IPA Inspector feature.
///
/// Example:
/// Bundle Identifier → com.company.app
///
/// Designed to provide a consistent
/// metadata presentation style.
struct KeyValueRow: View {

    // MARK: - Properties

    /// Left-side label/title.
    let key: String

    /// Right-side displayed value.
    let value: String

    // MARK: - Body

    var body: some View {

        HStack(alignment: .top) {

            Text(key)
                .foregroundStyle(.secondary)
                .frame(width: 180, alignment: .leading)

            Text(value)
                .textSelection(.enabled)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {

    KeyValueRow(
        key: "Bundle Identifier",
        value: "com.company.app"
    )
    .padding()
}