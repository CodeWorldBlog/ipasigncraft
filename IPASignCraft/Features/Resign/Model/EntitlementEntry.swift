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
    case array([EntitlementValue])
}

struct EntitlementEntry: Identifiable {
    let id = UUID()
    var key: String
    var value: EntitlementValue
}

extension EntitlementValue {
    func toAny() -> Any {
        switch self {
        case .string(let value): return value
        case .bool(let value): return value
        case .array(let values): return values.map { $0.toAny() }
        }
    }
}

extension EntitlementValue {
    
    static func from(any: Any) -> EntitlementValue? {
        switch any {
        case let value as String:
            return .string(value)
        case let value as Bool:
            return .bool(value)
        case let array as [Any]:
            return .array(array.compactMap { from(any: $0) })
        default:
            return nil
        }
    }
}
