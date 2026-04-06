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
            plistSection
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

fileprivate extension HomeView {
    // MARK: - Header
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
    
    // MARK: - plist Section Changes Option
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
                    TextField("Key", text: $entry.key)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Value", text: $entry.value)
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
