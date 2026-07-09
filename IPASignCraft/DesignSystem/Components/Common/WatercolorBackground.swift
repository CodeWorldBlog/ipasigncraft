import SwiftUI

/// Reusable watercolor background used across multiple screens.
struct WatercolorBackground: View {

    var body: some View {
        GeometryReader { geo in
            Image("homeBgWatercolor")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .overlay(Color.white.opacity(0.6))
        }
    }
}

#Preview {
    WatercolorBackground()
}
