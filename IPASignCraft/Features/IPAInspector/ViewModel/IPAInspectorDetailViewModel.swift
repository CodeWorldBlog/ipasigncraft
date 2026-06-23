//
//  IPAInspectorDetailViewModel.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import Foundation
import Combine

/// ViewModel responsible for managing
/// IPA inspection state and loading flow.
///
/// Responsibilities:
/// - open IPA files
/// - trigger inspection pipeline
/// - expose loading/error states
/// - provide inspection result to UI
@MainActor
final class IPAInspectorDetailViewModel: ObservableObject {
    
    // MARK: - Published State
    
    /// Centralized state object for IPA Inspector.
    @Published var state = IPAInspectorState()
    
    // MARK: - Dependencies
    
    private let inspectionService: IPAInspectionServicing
    
    // MARK: - Initialization
    
    init(
        inspectionService: IPAInspectionServicing = IPAInspectionService()
    ) {
        self.inspectionService = inspectionService
    }
    
    // MARK: - Public Methods
    
    /// Opens and inspects an IPA file.
    func inspectIPA(at url: URL) {
        
        state.selectedIPAURL = url
        
        Task {
            
            await runInspection(for: url)
        }
    }
    
    /// Clears currently loaded inspection.
    func resetInspection() {
        
        state.inspection = nil
        state.errorMessage = nil
        state.selectedSection = .overview
        state.selectedIPAURL = nil
        state.log = ""
    }
    
    /// Clears inspection logs.
    func clearLogs() {
        
        state.log = ""
    }
}

private extension IPAInspectorDetailViewModel {

    /// Logs a message with timestamp.
    func addLog(_ message: String) {

        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logEntry = "[\(timestamp)] \(message)"
        
        if state.log.isEmpty {
            state.log = logEntry
        } else {
            state.log.append("\n\(logEntry)")
        }
    }

    /// Executes the inspection pipeline.
    func runInspection(
        for url: URL
    ) async {

        state.isLoading = true
        state.errorMessage = nil
        addLog("Starting inspection...")

        defer {
            state.isLoading = false
        }

        do {

            addLog("Loading IPA file: \((url.lastPathComponent))")
            
            let result = try await inspectionService.inspectIPA(
                at: url
            )

            state.inspection = result
            addLog("✓ Inspection completed successfully")

        } catch {

            state.errorMessage = error.localizedDescription
            addLog("✗ Inspection failed: \(error.localizedDescription)")
        }
    }
}
