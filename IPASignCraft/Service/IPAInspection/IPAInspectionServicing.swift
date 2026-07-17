//
//  IPAInspectionServicing.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import Foundation

/// Defines the contract for IPA inspection services.
///
/// Purpose:
/// Abstract the inspection pipeline behind
/// a protocol so the UI layer does not depend
/// directly on concrete inspection implementations.
///
/// Benefits:
/// - easier testing
/// - mock implementations
/// - dependency injection
/// - future extensibility
///
/// Typical responsibilities of conforming types:
/// - extract IPA contents
/// - parse Info.plist
/// - inspect binary architectures
/// - validate signatures
/// - parse entitlements
/// - scan frameworks
///
/// Example implementations:
/// - IPAInspectionService
/// - MockIPAInspectionService
protocol IPAInspectionServicing {

    /// Runs the complete IPA inspection pipeline.
    ///
    /// Expected flow:
    /// 1. Extract IPA
    /// 2. Locate .app bundle
    /// 3. Parse metadata
    /// 4. Analyze binary
    /// 5. Inspect frameworks
    /// 6. Build IPAInspection model
    ///
    /// - Parameter url:
    ///   Local IPA file URL selected by the user.
    ///
    /// - Returns:
    ///   Fully constructed inspection result.
    ///
    /// - Throws:
    ///   Inspection-related errors such as:
    ///   - invalid IPA
    ///   - extraction failure
    ///   - missing app bundle
    ///   - parsing failures
    func inspectIPA(
        at url: URL
    ) async throws -> IPAInspection
}
