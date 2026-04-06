//
//  SwiftUIView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 06/04/26.
//

import SwiftUI

enum EntitlementValueType: String {
    case string
    case bool
    case array
}

struct EntitlementTypePicker: View {
    @Binding var entry: EntitlementEntry
    
    var body: some View {
        Picker("", selection: Binding<EntitlementValueType>(
            get: {
                switch entry.value {
                case .string: return .string
                case .bool: return .bool
                case .array: return .array
                }
            },
            set: { newType in
                switch newType {
                case .string:
                    entry.value = .string("")
                case .bool:
                    entry.value = .bool(false)
                case .array:
                    entry.value = .array([""])
                }
            }
        )) {
            Text("String").tag(EntitlementValueType.string)
            Text("Bool").tag(EntitlementValueType.bool)
            Text("Array").tag(EntitlementValueType.array)
        }
        .pickerStyle(.menu)
    }
}


#Preview {
    @Previewable @State var entry = EntitlementEntry(
        key: "aps-environment",
        value: .string("development")
    )
    return EntitlementTypePicker(entry: $entry)
}
