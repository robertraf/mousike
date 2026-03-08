import SwiftUI

struct VisualizerView: View {
    let spectrumData: [Float]
    let theme: Theme

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<spectrumData.count, id: \.self) { index in
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(barGradient(for: index, height: geometry.size.height))
                            .frame(height: CGFloat(spectrumData[index]) * geometry.size.height)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func barGradient(for index: Int, height: CGFloat) -> LinearGradient {
        let progress = CGFloat(index) / CGFloat(spectrumData.count)
        let color1 = theme.visualizerColor
        let color2 = theme.visualizerColorSecondary

        return LinearGradient(
            colors: [
                interpolate(color1, color2, amount: progress),
                interpolate(color1, color2, amount: progress).opacity(0.7)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func interpolate(_ c1: Color, _ c2: Color, amount: CGFloat) -> Color {
        let nsC1 = NSColor(c1)
        let nsC2 = NSColor(c2)

        guard let rgb1 = nsC1.usingColorSpace(.sRGB),
              let rgb2 = nsC2.usingColorSpace(.sRGB) else { return c1 }

        return Color(
            red: Double(rgb1.redComponent + (rgb2.redComponent - rgb1.redComponent) * amount),
            green: Double(rgb1.greenComponent + (rgb2.greenComponent - rgb1.greenComponent) * amount),
            blue: Double(rgb1.blueComponent + (rgb2.blueComponent - rgb1.blueComponent) * amount)
        )
    }
}
