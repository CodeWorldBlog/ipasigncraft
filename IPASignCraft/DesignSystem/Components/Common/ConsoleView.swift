//
//  ConsoleView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 09/06/26.
//

import SwiftUI

/// A reusable console/logs component for displaying terminal-style output.
///
/// Features:
/// - Displays monospaced log text
/// - Dark background with green text (terminal style)
/// - Clear button to reset logs
/// - Scrollable content area
/// - Customizable title and icon
struct ConsoleView: View {

    // MARK: - Properties

    /// Title displayed in the header
    let title: String

    /// SF Symbol icon name
    let icon: String

    /// Log content to display
    @Binding var logContent: String

    /// Callback when clear button is tapped
    var onClear: (() -> Void)?

    // MARK: - Body

    var body: some View {

        AppCard {

            VStack(spacing: Spacing.sm) {

                // Header with title and clear button
                HStack {

                    Label(title, systemImage: icon)
                        .font(AppFont.body)

                    Spacer()

                    Button("Clear") {

                        logContent = ""
                        onClear?()
                    }
                    .font(AppFont.secondary)
                }

                Divider()
                    .opacity(0.3)

                // Console output
                ScrollView {

                    Text(logContent.isEmpty ? "No logs yet" : logContent)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Spacing.base)
                }
                .frame(maxHeight: 260)
                .background(Color.black.opacity(0.9))
                .cornerRadius(8)
                .foregroundColor(.green)
            }
        }
    }
}

// MARK: - Preview

#Preview {

    @State var sampleLogs = "Initializing inspection...\nLoading IPA file...\nAnalyzing bundle...\n✓ Inspection complete"

    return ConsoleView(
        title: "Console",
        icon: "terminal",
        logContent: $sampleLogs
    )
}
