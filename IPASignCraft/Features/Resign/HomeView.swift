//
//  ContentView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 16/03/26.
//

import SwiftUI


struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            headerSection
            Divider()
            inputSection
            
            if viewModel.state.useCustomBundleID {
                bundleIDSection
            }
            
            advancedOptionsSection
            
            Divider()
            certificateSection
            actionSection
            Divider()
            logSection
        }
        .padding(24)
        .frame(width: 520)
    }
}

// MARK: - Header
fileprivate extension HomeView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("IPASignCraft").font(.largeTitle).fontWeight(.semibold)
            Text("Craft a new signature for your IPA") .foregroundColor(.secondary)
        }
    }
    
    var inputSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            FileDropView(
                title: "Drop IPA File",
                filePath: Binding(
                    get: { viewModel.state.ipaPath },
                    set: { viewModel.updateIPAPath($0) }
                )
            )

            FilePickerView(
                title: "Provision Profile", supportedTypes: [".mobileprovision"],
                filePath: Binding(
                    get: { viewModel.state.profilePath },
                    set: { viewModel.updateProfilePath($0) }
                )
            )
        }
    }
    
    var certificateSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle("Use custom certificate (.p12)", isOn: $viewModel.state.useCustomCert)
            if viewModel.state.useCustomCert {
                customCertificateView
            } else {
                savedCertificateView
            }
        }
    }
    
    // MARK: - App Bundle ID
    var bundleIDSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text("Bundle ID: ")
                    .bold()
                Text(viewModel.state.bundleID)
            }
        }
    }
    
    // MARK: - Custom Certificate
    var customCertificateView: some View {
        VStack(alignment: .leading, spacing: 10) {
            FilePickerView( title: "Select .p12", supportedTypes: [".p12"], filePath: $viewModel.state.p12Path )
            SecureField("Password", text: $viewModel.state.p12Password) .textFieldStyle(.roundedBorder)
        }
    }
    // MARK: - Saved Certificat
    var savedCertificateView: some View {
        CertificatePickerView(certificates: self.viewModel.state.certificates, selected: $viewModel.state.selectedCertificate)
    }
    
    // MARK: - Actions private
    var actionSection: some View {
        HStack {
            Spacer()
            Button("Resign IPA") {
                viewModel.resign()
            }.buttonStyle(.borderedProminent).controlSize(.large).disabled(!viewModel.state.isResignEnabled)
            
        }
    }
}

// MARK: - Advance Section
fileprivate extension HomeView {
    // MARK: - Advanced Options Section
    var advancedOptionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Advanced Options")
                .font(.headline)
            
            // MARK: - Info.plist Toggle + Section
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Modify Info.plist", isOn: $viewModel.state.enablePlistEditing)
                
                if viewModel.state.enablePlistEditing {
                    plistSection
                        .padding(.leading, 8)
                }
            }
            
            // MARK: - Entitlement Toggle + Section
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Modify Entitlements", isOn: $viewModel.state.enableEntitlementEditing)
                
                if viewModel.state.enableEntitlementEditing {
                    entitlementSection
                        .padding(.leading, 8)
                }
            }
        }
    }
    
    // MARK: Info Plist
    var plistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Info.plist Modifications")
                    .font(.headline)
                Spacer()
                Button("+ Add") {
                    viewModel.addPlistEntry()
                }
            }
            
            ForEach($viewModel.state.plistEntries) { $entry in
                HStack {
                    TextField("e.g. NSCameraUsageDescription", text: $entry.key)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("e.g. This app needs camera access", text: $entry.value)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        viewModel.removePlistEntry(entry.id)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
    
    // MARK: Entitlement Section
    var entitlementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack {
                Text("Entitlement Modifications")
                    .font(.headline)
                
                Spacer()
                
                Menu("Add Capability") {
                    Button("Push Notifications") {
                        viewModel.addEntitlementPreset(.pushNotifications)
                    }
                    
                    Button("App Groups") {
                        viewModel.addEntitlementPreset(.appGroups)
                    }
                    
                    Button("Keychain Sharing") {
                        viewModel.addEntitlementPreset(.keychainSharing)
                    }
                }
                
                Button("+ Add") {
                    viewModel.addEntitlementEntry()
                }
            }
            
            // Hint
            Text("Example: aps-environment → development")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Entries
            ForEach($viewModel.state.entitlementEntries) { $entry in
                VStack(alignment: .leading, spacing: 8) {
                    
                    HStack {
                        // Key
                        TextField("e.g. aps-environment", text: $entry.key)
                            .textFieldStyle(.roundedBorder)
                        
                        // Type Picker
                        EntitlementTypePicker(entry: $entry)
                        
                        // Delete
                        Button {
                            viewModel.removeEntitlementEntry(entry.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    
                    // Value Input (dynamic)
                    entitlementValueInput(for: $entry)
                }
            }
        }
    }
    
    
    @ViewBuilder
    func entitlementValueInput(for entry: Binding<EntitlementEntry>) -> some View {
        switch entry.wrappedValue.value {
            
        case .string(let value):
            TextField("Value", text: Binding(
                get: { value },
                set: { entry.wrappedValue.value = .string($0) }
            ))
            .textFieldStyle(.roundedBorder)
            
        case .bool(let value):
            Toggle("Enabled", isOn: Binding(
                get: { value },
                set: { entry.wrappedValue.value = .bool($0) }
            ))
            
        case .array(let values):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(values.indices, id: \.self) { index in
                    HStack {
                        TextField("Item \(index + 1)", text: Binding(
                            get: { values[index] },
                            set: { newValue in
                                var updated = values
                                updated[index] = newValue
                                entry.wrappedValue.value = .array(updated)
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        
                        Button {
                            var updated = values
                            updated.remove(at: index)
                            entry.wrappedValue.value = .array(updated)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                    }
                }
                
                Button("+ Add Item") {
                    if case .array(let values) = entry.wrappedValue.value {
                        entry.wrappedValue.value = .array(values + [""])
                    }
                }
            }
        }
    }
}

// MARK: - Log Section
fileprivate extension HomeView {
    var logSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Logs")
                .font(.headline)

            ScrollView {
                Text(viewModel.state.log)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(.body, design: .monospaced))
            }
            .frame(height: 180)
            .padding(10)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(8)
        }
    }
}

#Preview {
    HomeView()
}
