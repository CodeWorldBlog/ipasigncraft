//
//  EntitlementEntry.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 06/04/26.
//

import Foundation

enum EntitlementValue {
    case string(String)
    case bool(Bool)
    case array([String])
}

struct EntitlementEntry: Identifiable {
    let id = UUID()
    var key: String = ""
    var value: EntitlementValue = .string("")
}
