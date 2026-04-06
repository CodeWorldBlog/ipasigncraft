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

    // MARK: - Resign
    func resign() {
        guard let selectedCertificate = state.selectedCertificate else {
            state.log = "Invalid Certificate...\n"
            return
        }
        state.log = "Starting resign process...\n"
        Task {
            do {
                let result = try await resignService.resignIPA(
                    ipaPath: state.ipaPath,
                    profilePath: state.profilePath,
                    certificate: selectedCertificate.name,
                    newBundleID: state.bundleID,
                    infoPlistChanges: state.plistEntries
                )
                state.log += "Finished\nOutput: \(result)\n"

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
