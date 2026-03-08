import AVFoundation
import Accelerate

/// Analyzes audio output to produce spectrum data for the visualizer.
final class SpectrumAnalyzer {
    private let bufferSize: Int = 1024
    private let fftSetup: vDSP_DFT_Setup?

    var magnitudes: [Float] = Array(repeating: 0, count: 32)

    init() {
        fftSetup = vDSP_DFT_zop_CreateSetup(nil, vDSP_Length(bufferSize), .FORWARD)
    }

    deinit {
        if let setup = fftSetup {
            vDSP_DFT_DestroySetup(setup)
        }
    }

    /// Process an audio buffer and return normalized magnitude bands.
    func process(buffer: AVAudioPCMBuffer) -> [Float] {
        guard let channelData = buffer.floatChannelData?[0] else {
            return magnitudes
        }

        let frameCount = Int(buffer.frameLength)
        let count = min(frameCount, bufferSize)

        var realPart = [Float](repeating: 0, count: bufferSize)
        var imagPart = [Float](repeating: 0, count: bufferSize)
        var realOut = [Float](repeating: 0, count: bufferSize)
        var imagOut = [Float](repeating: 0, count: bufferSize)

        // Apply Hann window
        var window = [Float](repeating: 0, count: count)
        vDSP_hann_window(&window, vDSP_Length(count), Int32(vDSP_HANN_NORM))

        vDSP_vmul(channelData, 1, window, 1, &realPart, 1, vDSP_Length(count))

        // Perform FFT
        if let setup = fftSetup {
            vDSP_DFT_Execute(setup, realPart, imagPart, &realOut, &imagOut)
        }

        // Calculate magnitudes
        let bandCount = 32
        let bandSize = (bufferSize / 2) / bandCount
        var bands = [Float](repeating: 0, count: bandCount)

        for i in 0..<bandCount {
            var sumSquared: Float = 0
            let start = i * bandSize
            let end = min(start + bandSize, bufferSize / 2)
            for j in start..<end {
                let magnitude = sqrt(realOut[j] * realOut[j] + imagOut[j] * imagOut[j])
                sumSquared += magnitude
            }
            let avg = sumSquared / Float(end - start)
            // Convert to dB and normalize
            let db = 20 * log10(max(avg, 1e-6))
            bands[i] = max(0, min(1, (db + 60) / 60))
        }

        // Smooth with previous values
        for i in 0..<bandCount {
            magnitudes[i] = magnitudes[i] * 0.6 + bands[i] * 0.4
        }

        return magnitudes
    }

    /// Generate simulated spectrum data for when no audio is playing.
    func generateIdle() -> [Float] {
        for i in 0..<magnitudes.count {
            magnitudes[i] = max(0, magnitudes[i] - Float.random(in: 0.02...0.05))
        }
        return magnitudes
    }
}
