//
//  File.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 06/04/26.
//

import Foundation

enum EntitlementPreset {
    case pushNotifications(environment: APSEnvironment)
    case appGroups(groupID: String)
    case keychainSharing(bundleID: String)
}

enum APSEnvironment: String {
    case development
    case production
}

extension EntitlementPreset {
    func toEntries() -> [EntitlementEntry] {
        switch self {
            
        case .pushNotifications(let environment):
            return [
                EntitlementEntry(
                    key: "aps-environment",
                    value: .string(environment.rawValue)
                )
            ]
            
        case .appGroups(let groupID):
            return [
                EntitlementEntry(
                    key: "com.apple.security.application-groups",
                    value: .array(
                        groupID.isEmpty ? [] : [.string(groupID)]
                    )
                )
            ]
        case .keychainSharing(let bundleID):
            return [
                EntitlementEntry(
                    key: "keychain-access-groups",
                    value: .array(
                        bundleID.isEmpty ? [] : [.string(bundleID)]
                    )
                )
            ]
        }
    }
}
