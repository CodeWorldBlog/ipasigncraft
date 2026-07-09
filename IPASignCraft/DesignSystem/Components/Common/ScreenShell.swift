import SwiftUI

/// A small screen shell that provides a background and scrollable centered content area.
/// Use this to standardize page layout across screens.
struct ScreenShell<Content: View>: View {

    private let background: AnyView
    private let content: () -> Content

    init<B: View>(background: B = WatercolorBackground(), @ViewBuilder content: @escaping () -> Content) {
        self.background = AnyView(background)
        self.content = content
    }

    var body: some View {
        ZStack {
            background

            ScrollView {
                content()
            }
        }
    }
}

#Preview {
    ScreenShell {
        VStack {
            Text("Screen Shell")
        }
        .frame(maxWidth: 800)
    }
}
