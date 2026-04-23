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
        ZStack {
            homeBackground
            HStack(alignment: .top, spacing: 24) {
                // LEFT SIDE
                leftSection
                // RIGHT SIDE
                rightSection
                    .frame(width: 300)
            }
            .padding(.horizontal)
        }
    }
}

//MARK: - Input Section
private extension HomeView {
    var leftSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                ipaCard
                provisionSection
                advancedSection
                certificateSection
                actionSection
            }
            .padding(50)
            .frame(maxWidth: 680)
        }
    }
}

//MARK: - output Section
fileprivate extension HomeView {
    var rightSection: some View {
        VStack(spacing: 20) {
            progressSection
            logsSection
            Spacer()
        }
        .padding(.top, 30)
    }
}

// MARK: - Background
private extension HomeView {
    /// Watercolor background with soft white overlay
    /// Keeps UI readable while preserving aesthetic
    var homeBackground: some View {
        GeometryReader { geo in
            Image("homeBgWatercolor")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
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
}

fileprivate extension HomeView {
    var ipaCard: some View {
        Card {
            // MARK: - Section Title
            Label("IPA File", systemImage: "doc")
            // MARK: - Optional Hint (keeps UI friendly)
            Text("Select or drop the IPA you want to re-sign")
                .font(.caption)
                .foregroundColor(.secondary)
            // MARK: - Drop Zone
            FileDropView(
                title: "IPA File",
                filePath: Binding(
                    get: { viewModel.state.ipaPath },
                    set: { viewModel.updateIPAPath($0) }
                )
            )
            
            // MARK: - File Info (only when selected)
            if !viewModel.state.ipaPath.isEmpty {
                ipaInfoRow
            }
        }
    }
    
    var ipaInfoRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.fill")
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text((viewModel.state.ipaPath as NSString).lastPathComponent)
                    .font(.caption)
                    .lineLimit(1)
                Text("Ready for signing")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

fileprivate extension HomeView {
    
    var provisionSection: some View {
        Card {
            // MARK: - Section Title
            Label("Provisioning Profile", systemImage: "shield")
            // MARK: - Hint
            Text("Select the provisioning profile to embed")
                .font(.caption)
                .foregroundColor(.secondary)
            // MARK: - Picker
            FilePickerView(
                title: "Select Profile",
                supportedTypes: [".mobileprovision"],
                filePath: Binding(
                    get: { viewModel.state.profilePath },
                    set: { viewModel.updateProfilePath($0) }
                )
            )
            
            // MARK: - Selected File Info
            if !viewModel.state.profilePath.isEmpty {
                provisionInfoRow
            }
        }
    }
    
    var provisionInfoRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text((viewModel.state.profilePath as NSString).lastPathComponent)
                    .font(.caption)
                    .lineLimit(1)
                provisionBundleID
                Text("Profile ready")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    // MARK: - App Bundle ID
    var provisionBundleID: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text("Bundle ID: ")
                    .bold()
                Text(viewModel.state.bundleID)
            }
        }
    }
}

// MARK: - Advance Section
fileprivate extension HomeView {
    // MARK: - Advanced Options Section
    var advancedSection: some View {
        Card {
            // MARK: - Title
            Label("Advanced Options", systemImage: "slider.horizontal.3")
            
            Text("Customize Info.plist and entitlements if needed")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 20) {
                // MARK: - Info.plist Section
                advancedToggleSection(
                    title: "Modify Info.plist",
                    isOn: $viewModel.state.enablePlistEditing
                ) {
                    plistSection
                }
                
                Divider().opacity(0.2)
                
                // MARK: - Entitlement Section
                advancedToggleSection(
                    title: "Modify Entitlements",
                    isOn: $viewModel.state.enableEntitlementEditing
                ) {
                    entitlementSection
                }
            }
        }
    }
}

fileprivate extension HomeView {
    var plistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("Info.plist Modifications")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("+ Add") {
                    viewModel.addPlistEntry()
                }
            }
            
            ForEach($viewModel.state.plistEntries) { $entry in
                HStack(spacing: 10) {
                    
                    TextField("Key", text: $entry.key)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Value", text: $entry.value)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        viewModel.removePlistEntry(entry.id)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(10)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
        }
    }
}

fileprivate extension HomeView {
    var entitlementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Entitlement Modifications")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Menu("Add Capability") {
                    Button("Push Notifications") {
                        viewModel.addEntitlementPreset(.pushNotifications(environment: .production))
                    }
                    
                    Button("App Groups") {
                        viewModel.addEntitlementPreset(.appGroups(groupID: ""))
                    }
                    
                    Button("Keychain Sharing") {
                        viewModel.addEntitlementPreset(.keychainSharing(bundleID: ""))
                    }
                }
                
                Button("+ Add") {
                    viewModel.addEntitlementEntry()
                }
            }
            
            Text("Example: aps-environment → development")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach($viewModel.state.entitlementEntries) { $entry in
                VStack(alignment: .leading, spacing: 8) {
                    
                    HStack(spacing: 10) {
                        
                        TextField("Key", text: $entry.key)
                            .textFieldStyle(.roundedBorder)
                        
                        EntitlementTypePicker(entry: $entry)
                        
                        Button {
                            viewModel.removeEntitlementEntry(entry.id)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    entitlementValueInput(for: $entry)
                }
                .padding(10)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
        }
    }
    
    @ViewBuilder
    func entitlementValueInput(for entry: Binding<EntitlementEntry>) -> some View {
        
        switch entry.wrappedValue.value {
            
        case .string:
            stringInput(for: entry)
            
        case .bool:
            boolInput(for: entry)
            
        case .array(let values):
            arrayInput(for: entry, values: values)
        }
    }
    
    private func stringInput(for entry: Binding<EntitlementEntry>) -> some View {
        TextField(
            "Value",
            text: Binding(
                get: {
                    if case .string(let value) = entry.wrappedValue.value {
                        return value
                    }
                    return ""
                },
                set: { newValue in
                    entry.wrappedValue.value = .string(newValue)
                }
            )
        )
        .textFieldStyle(.roundedBorder)
    }
    
    private func boolInput(for entry: Binding<EntitlementEntry>) -> some View {
        Toggle(
            "Enabled",
            isOn: Binding(
                get: {
                    if case .bool(let value) = entry.wrappedValue.value {
                        return value
                    }
                    return false
                },
                set: { newValue in
                    entry.wrappedValue.value = .bool(newValue)
                }
            )
        )
    }
    
    private func arrayInput(
        for entry: Binding<EntitlementEntry>,
        values: [EntitlementValue]
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            ForEach(values.indices, id: \.self) { index in
                HStack(spacing: 8) {
                    
                    TextField(
                        "Item \(index + 1)",
                        text: Binding(
                            get: {
                                if case .string(let str) = values[index] {
                                    return str
                                }
                                return ""
                            },
                            set: { newValue in
                                var updated = values
                                updated[index] = .string(newValue)
                                entry.wrappedValue.value = .array(updated)
                            }
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    
                    Button {
                        var updated = values
                        updated.remove(at: index)
                        entry.wrappedValue.value = .array(updated)
                    } label: {
                        Image(systemName: "minus.circle")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            
            Button("+ Add Item") {
                if case .array(let values) = entry.wrappedValue.value {
                    entry.wrappedValue.value = .array(values + [.string("")])
                }
            }
            .font(.caption)
        }
    }
}

fileprivate extension HomeView {
    func advancedToggleSection<Content: View>(
        title: String,
        isOn: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Toggle(title, isOn: isOn)
            
            if isOn.wrappedValue {
                content()
                    .padding(.leading, 10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: -  Certificate Section
fileprivate extension HomeView {
    var certificateSection: some View {
        Card {
            // MARK: - Title
            Label("Certificate", systemImage: "key")
            
            Text("Choose a saved certificate or provide a custom .p12 file")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                
                Toggle("Use custom certificate (.p12)", isOn: $viewModel.state.useCustomCert)
                
                if viewModel.state.useCustomCert {
                    customCertificateView
                        .padding(.leading, 10)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    savedCertificateView
                        .padding(.leading, 10)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
    
    var customCertificateView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Certificate")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            FilePickerView(
                title: "Select .p12",
                supportedTypes: [".p12"],
                filePath: $viewModel.state.p12Path
            )
            
            SecureField("Password", text: $viewModel.state.p12Password)
                .textFieldStyle(.roundedBorder)
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
    
    var savedCertificateView: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Saved Certificates")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            CertificatePickerView(
                certificates: viewModel.state.certificates,
                selected: $viewModel.state.selectedCertificate
            )
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

// MARK: - Actions Section
fileprivate extension HomeView {
    var actionSection: some View {
        Card {
            // MARK: - Title
            Label("Action", systemImage: "bolt")
            // MARK: - Status Hint
            Text(actionStatusText)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // MARK: - Button
            Button {
                viewModel.resign()
            } label: {
                Text(viewModel.state.isSigning ? "Signing..." : "Re-sign IPA")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.85),
                        Color.orange.opacity(0.85)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(!viewModel.state.isResignEnabled || viewModel.state.isSigning)
        }
    }
    
    var actionStatusText: String {
        if viewModel.state.isSigning {
            return "Signing in progress..."
        }
        
        if viewModel.state.isResignEnabled {
            return "Ready to re-sign IPA"
        } else {
            return "Select required inputs to enable signing"
        }
    }
}

fileprivate extension HomeView {
    var progressSection: some View {
        Card {
            Label("Signing Status", systemImage: "waveform.path.ecg")
            
            VStack(alignment: .leading, spacing: 14) {
                
                ProgressView(value: viewModel.state.progress)

                ForEach(SigningStep.allCases.filter { $0 != .idle }, id: \.self) { step in
                    statusRow(
                        step.rawValue,
                        done: viewModel.state.isStepCompleted(step)
                    )
                }
            }
        }
    }
    
    func statusRow(_ title: String, done: Bool) -> some View {
        HStack {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundColor(done ? .green : .gray)

            Text(title)
                .font(.caption)

            Spacer()
        }
    }
}

// MARK: - Log Section
fileprivate extension HomeView {
    var logsSection: some View {
        Card {
            HStack {
                Label("Logs", systemImage: "terminal")
                Spacer()
                Button("Clear") {
                    
                }
            }
            
            ScrollView {
                Text(viewModel.state.log)
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(height: 260)
            .background(Color.black.opacity(0.9))
            .cornerRadius(10)
            .foregroundColor(.green)
        }
    }
}

#Preview {
    HomeView()
}
