import SwiftUI

/// Available stroboscopic visualization modes
enum StrobeMode: String, CaseIterable {
    case rings = "Rings"
    case plasma = "Plasma"
    case starburst = "Starburst"
    case wave = "Wave"

    var next: StrobeMode {
        let all = StrobeMode.allCases
        let idx = all.firstIndex(of: self)!
        return all[(idx + 1) % all.count]
    }
}

/// Stroboscopic visualizer that reacts to the music's rhythm.
struct StrobeEffectsView: View {
    let spectrumData: [Float]
    let theme: Theme
    let mode: StrobeMode
    @State private var phase: Double = 0
    @State private var beatFlash: Double = 0

    /// Overall energy from the spectrum (0...1)
    private var energy: Double {
        guard !spectrumData.isEmpty else { return 0 }
        return Double(spectrumData.reduce(0, +)) / Double(spectrumData.count)
    }

    /// Bass energy from low-frequency bands (0...1)
    private var bassEnergy: Double {
        let bassCount = min(8, spectrumData.count)
        guard bassCount > 0 else { return 0 }
        return Double(spectrumData.prefix(bassCount).reduce(0, +)) / Double(bassCount)
    }

    /// Treble energy from high-frequency bands (0...1)
    private var trebleEnergy: Double {
        let trebleCount = min(8, spectrumData.count)
        guard trebleCount > 0 else { return 0 }
        return Double(spectrumData.suffix(trebleCount).reduce(0, +)) / Double(trebleCount)
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let time = timeline.date.timeIntervalSinceReferenceDate

                switch mode {
                case .rings:
                    drawRings(context: context, size: size, center: center, time: time)
                case .plasma:
                    drawPlasma(context: context, size: size, time: time)
                case .starburst:
                    drawStarburst(context: context, size: size, center: center, time: time)
                case .wave:
                    drawWave(context: context, size: size, time: time)
                }

                // Beat flash overlay
                if bassEnergy > 0.55 {
                    let flashOpacity = (bassEnergy - 0.55) * 2.0
                    context.fill(
                        Path(CGRect(origin: .zero, size: size)),
                        with: .color(theme.visualizerColor.opacity(flashOpacity * 0.3))
                    )
                }
            }
        }
        .background(theme.displayBackground)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    // MARK: - Rings Mode

    private func drawRings(context: GraphicsContext, size: CGSize, center: CGPoint, time: Double) {
        let maxRadius = min(size.width, size.height) / 2
        let ringCount = 6

        for i in 0..<ringCount {
            let bandIndex = min(i * (spectrumData.count / ringCount), spectrumData.count - 1)
            let magnitude = spectrumData.isEmpty ? Float(0) : spectrumData[bandIndex]

            let baseRadius = maxRadius * Double(i + 1) / Double(ringCount)
            let pulseRadius = baseRadius * (0.6 + Double(magnitude) * 0.5)

            let hueShift = Double(i) / Double(ringCount)
            let rotation = time * (0.3 + Double(i) * 0.15) + Double(magnitude) * 2.0

            let path = Path { p in
                let segments = 60
                for s in 0...segments {
                    let angle = (Double(s) / Double(segments)) * .pi * 2.0 + rotation
                    let wobble = sin(angle * 3.0 + time * 2.0) * Double(magnitude) * maxRadius * 0.1
                    let r = pulseRadius + wobble

                    let point = CGPoint(
                        x: center.x + cos(angle) * r,
                        y: center.y + sin(angle) * r
                    )

                    if s == 0 {
                        p.move(to: point)
                    } else {
                        p.addLine(to: point)
                    }
                }
                p.closeSubpath()
            }

            let color1 = theme.visualizerColor
            let color2 = theme.visualizerColorSecondary
            let opacity = 0.3 + Double(magnitude) * 0.7

            context.stroke(
                path,
                with: .color(interpolateColor(color1, color2, amount: hueShift).opacity(opacity)),
                lineWidth: 1.5 + Double(magnitude) * 2.0
            )
        }
    }

    // MARK: - Plasma Mode

    private func drawPlasma(context: GraphicsContext, size: CGSize, time: Double) {
        let cellSize: CGFloat = 8
        let cols = Int(size.width / cellSize) + 1
        let rows = Int(size.height / cellSize) + 1

        for row in 0..<rows {
            for col in 0..<cols {
                let x = Double(col) / Double(cols)
                let y = Double(row) / Double(rows)

                let bandIndex = min(col * spectrumData.count / max(cols, 1), spectrumData.count - 1)
                let magnitude = spectrumData.isEmpty ? Float(0) : spectrumData[max(0, bandIndex)]

                let v1 = sin(x * 6.0 + time * 1.5 + Double(magnitude) * 4.0)
                let v2 = sin(y * 8.0 + time * 1.2)
                let v3 = sin((x + y) * 5.0 + time * 0.8)
                let plasma = (v1 + v2 + v3) / 3.0

                let normalizedPlasma = (plasma + 1.0) / 2.0
                let energyBoost = normalizedPlasma * (0.3 + energy * 0.7)

                let rect = CGRect(
                    x: CGFloat(col) * cellSize,
                    y: CGFloat(row) * cellSize,
                    width: cellSize,
                    height: cellSize
                )

                let color = interpolateColor(
                    theme.visualizerColor,
                    theme.visualizerColorSecondary,
                    amount: normalizedPlasma
                ).opacity(energyBoost)

                context.fill(Path(rect), with: .color(color))
            }
        }
    }

    // MARK: - Starburst Mode

    private func drawStarburst(context: GraphicsContext, size: CGSize, center: CGPoint, time: Double) {
        let rayCount = spectrumData.isEmpty ? 32 : spectrumData.count
        let maxLength = min(size.width, size.height) / 2

        // Draw concentric pulse circles
        let pulseCount = 3
        for p in 0..<pulseCount {
            let pulsePhase = fmod(time * 0.8 + Double(p) * 0.33, 1.0)
            let pulseRadius = pulsePhase * maxLength
            let pulseOpacity = (1.0 - pulsePhase) * bassEnergy

            let circle = Path(ellipseIn: CGRect(
                x: center.x - pulseRadius,
                y: center.y - pulseRadius,
                width: pulseRadius * 2,
                height: pulseRadius * 2
            ))

            context.stroke(
                circle,
                with: .color(theme.visualizerColorSecondary.opacity(pulseOpacity * 0.5)),
                lineWidth: 1.5
            )
        }

        // Draw rays
        for i in 0..<rayCount {
            let angle = (Double(i) / Double(rayCount)) * .pi * 2.0
            let magnitude = spectrumData.isEmpty ? Float(0.1) : spectrumData[i]

            let rayLength = maxLength * (0.15 + Double(magnitude) * 0.85)
            let rotation = time * 0.3

            let startAngle = angle + rotation
            let innerRadius = maxLength * 0.08
            let start = CGPoint(
                x: center.x + cos(startAngle) * innerRadius,
                y: center.y + sin(startAngle) * innerRadius
            )
            let end = CGPoint(
                x: center.x + cos(startAngle) * rayLength,
                y: center.y + sin(startAngle) * rayLength
            )

            let progress = Double(i) / Double(rayCount)
            let color = interpolateColor(
                theme.visualizerColor,
                theme.visualizerColorSecondary,
                amount: progress
            )

            let path = Path { p in
                p.move(to: start)
                p.addLine(to: end)
            }

            context.stroke(
                path,
                with: .color(color.opacity(0.4 + Double(magnitude) * 0.6)),
                lineWidth: 1.5 + Double(magnitude) * 2.5
            )
        }
    }

    // MARK: - Wave Mode

    private func drawWave(context: GraphicsContext, size: CGSize, time: Double) {
        let waveCount = 4

        for w in 0..<waveCount {
            let waveOffset = Double(w) * 0.25
            let yCenter = size.height * (0.25 + Double(w) * 0.18)
            let progress = Double(w) / Double(waveCount)
            let color = interpolateColor(
                theme.visualizerColor,
                theme.visualizerColorSecondary,
                amount: progress
            )

            let path = Path { p in
                let steps = Int(size.width)
                for s in 0...steps {
                    let x = CGFloat(s)
                    let normalizedX = Double(s) / Double(steps)

                    // Map x position to spectrum band
                    let bandIndex = min(Int(normalizedX * Double(spectrumData.count)), spectrumData.count - 1)
                    let magnitude = spectrumData.isEmpty ? Float(0.1) : spectrumData[max(0, bandIndex)]

                    let wave1 = sin(normalizedX * .pi * 4.0 + time * (1.5 + waveOffset) + Double(magnitude) * 3.0)
                    let wave2 = sin(normalizedX * .pi * 7.0 - time * (0.8 + waveOffset))
                    let combined = (wave1 * 0.6 + wave2 * 0.4) * Double(magnitude)

                    let amplitude = size.height * 0.12 * (0.5 + energy * 1.0)
                    let y = yCenter + combined * amplitude

                    if s == 0 {
                        p.move(to: CGPoint(x: x, y: y))
                    } else {
                        p.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }

            let opacity = 0.3 + energy * 0.5 + Double(waveCount - w) * 0.05
            context.stroke(
                path,
                with: .color(color.opacity(opacity)),
                lineWidth: 1.5 + energy * 1.5
            )
        }
    }

    // MARK: - Helpers

    private func interpolateColor(_ c1: Color, _ c2: Color, amount: Double) -> Color {
        let nsC1 = NSColor(c1)
        let nsC2 = NSColor(c2)

        guard let rgb1 = nsC1.usingColorSpace(.sRGB),
              let rgb2 = nsC2.usingColorSpace(.sRGB) else { return c1 }

        return Color(
            red: Double(rgb1.redComponent + (rgb2.redComponent - rgb1.redComponent) * CGFloat(amount)),
            green: Double(rgb1.greenComponent + (rgb2.greenComponent - rgb1.greenComponent) * CGFloat(amount)),
            blue: Double(rgb1.blueComponent + (rgb2.blueComponent - rgb1.blueComponent) * CGFloat(amount))
        )
    }
}
