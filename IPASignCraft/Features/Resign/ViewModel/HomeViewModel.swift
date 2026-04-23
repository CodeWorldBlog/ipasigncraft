import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var state = HomeState()
    private let resignService = CodeSignService()

    init() {
        loadSigningIdentity()
    }

    // MARK: - Load Certificates

    func loadSigningIdentity() {
        Task {
            await loadCertificates()
        }
    }

    private func loadCertificates() async {

        state.isLoading = true

        do {
            let certs = try KeychainService.fetchCertificates()

            state.certificates = certs

            if state.selectedCertificate == nil {
                state.selectedCertificate = certs.first
            }

        } catch KeychainError.locked {
            state.showUnlockPrompt = true
        } catch {
            state.errorMessage = error.localizedDescription
        }

        state.isLoading = false
    }

    // MARK: - Unlock

    func unlockKeychain(password: String) {

        Task {
            do {
                let certs = try KeychainService.fetchCertificatesAfterUnlock(password: password)

                state.certificates = certs
                state.selectedCertificate = certs.first
                state.showUnlockPrompt = false

            } catch {
                state.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Update Inputs
    func updateIPAPath(_ path: String) {
        state.ipaPath = path
    }

    func updateProfilePath(_ path: String) {
        state.profilePath = path
        if let bundleID = self.bundleIdentifier(forProfileAtPath: path) {
            state.bundleID = bundleID
            state.useCustomBundleID = true
        }
    }
    
    func addPlistEntry() {
        state.plistEntries.append(PlistKeyValue())
    }

    func removePlistEntry(_ id: UUID) {
        state.plistEntries.removeAll { $0.id == id }
    }
    
    func addEntitlementPreset(_ type: EntitlementPreset) {
        
        let newEntry: EntitlementEntry
        
        switch type {
            
        case .pushNotifications(let env):
            newEntry = EntitlementEntry(
                key: "aps-environment",
                value: .string(env.rawValue)
            )
            
        case .appGroups(let groupID):
            newEntry = EntitlementEntry(
                key: "com.apple.security.application-groups",
                value: .array([.string(groupID)])
            )
            
        case .keychainSharing(let bundleID):
            newEntry = EntitlementEntry(
                key: "keychain-access-groups",
                value: .array([
                    .string("$(AppIdentifierPrefix)\(bundleID)")
                ])
            )
        }
        
        if let index = state.entitlementEntries.firstIndex(where: { $0.key == newEntry.key }) {
            
            let existing = state.entitlementEntries[index]
            
            if case .array(let oldArray) = existing.value,
               case .array(let newArray) = newEntry.value {
                
                let merged = oldArray + newArray
                state.entitlementEntries[index].value = .array(merged)
                
            } else {
                state.entitlementEntries[index] = newEntry
            }
            
        } else {
            state.entitlementEntries.append(newEntry)
        }
    }
    
    func addEntitlementEntry(
        key: String = "",
        value: EntitlementValue = .string("")
    ) {
        state.entitlementEntries.append(
            EntitlementEntry(key: key, value: value)
        )
    }
    
    func removeEntitlementEntry(_ id: UUID) {
        state.entitlementEntries.removeAll { $0.id == id }
    }

    // MARK: - Resign
    func resign() {
        guard let selectedCertificate = state.selectedCertificate else {
            state.log = "Invalid Certificate...\n"
            return
        }
        self.state.isSigning = true
        state.log = "Starting resign process...\n"
        Task {
            do {
                let result = try await resignService.resignIPA(
                    ipaPath: state.ipaPath,
                    profilePath: state.profilePath,
                    certificate: selectedCertificate.name,
                    newBundleID: state.bundleID,
                    infoPlistChanges: state.plistEntries,
                    entitlementUpdates: state.entitlementEntries
                )
                DispatchQueue.main.async {
                    self.state.isSigning = false
                    self.state.log += "Finished\nOutput: \(result)\n"
                }
            } catch {
                state.log += "Error: \(error.localizedDescription)\n"
            }
        }
    }
}

fileprivate extension HomeViewModel {
    func bundleIdentifier(forProfileAtPath path: String) -> String? {
        do {
             return try ProvisionExtractService.extractBundleID(from: path)
        } catch {
            state.log += "Error: \(error.localizedDescription)\n"
        }
        return nil
    }
}
