//
//  IPAInspectorState.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 09/06/26.
//

import Foundation

/// Encapsulates all state for the IPA Inspector feature.
///
/// This state object is owned by the view model
/// and published to views for reactive updates.
@Observable
final class IPAInspectorState {

    // MARK: - File Selection State

    /// Currently selected IPA file URL.
    var selectedIPAURL: URL?

    // MARK: - Inspection State

    /// Currently loaded inspection result.
    var inspection: IPAInspection?

    /// Indicates whether inspection is currently running.
    var isLoading = false

    /// Human-readable error message shown in UI
    /// when inspection fails.
    var errorMessage: String?

    /// Currently selected inspector section.
    ///
    /// Used by parent navigation/menu.
    var selectedSection: IPAInspectorSection = .overview

    /// Log output for inspection process.
    var log: String = ""

    // MARK: - Initialization

    init() {}
}
