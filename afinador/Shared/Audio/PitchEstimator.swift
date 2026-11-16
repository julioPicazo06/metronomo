import Foundation

// MARK: - PitchEstimator
// YIN pitch detection. Pure DSP, no AVAudioEngine — unit-tested with a 440 Hz sine.
// Returns nil if RMS is too low (silence) or the CMNDF minimum is too high (noise).
// Debug: if 440 sine fails, check buffer length (>= 4096) and sampleRate.

enum PitchEstimator: Sendable {
    nonisolated static func frequency(
        samples: [Float],
        sampleRate: Double,
        minHz: Double = 70,
        maxHz: Double = 1400
    ) -> Double? {
        let count = samples.count
        guard count > 32, sampleRate > 0 else { return nil }

        var squareSum: Float = 0
        for sample in samples {
            squareSum += sample * sample
        }
        let rms = sqrt(squareSum / Float(count))
        if rms < 0.01 { return nil }

        let tauMin = max(2, Int((sampleRate / maxHz).rounded(.down)))
        let tauMax = min(count / 2 - 1, Int((sampleRate / minHz).rounded(.up)))
        guard tauMax > tauMin + 2 else { return nil }

        var difference = [Float](repeating: 0, count: tauMax + 1)
        for tau in tauMin...tauMax {
            var sum: Float = 0
            let limit = count - tau
            for index in 0..<limit {
                let delta = samples[index] - samples[index + tau]
                sum += delta * delta
            }
            difference[tau] = sum
        }

        var cmndf = [Float](repeating: 1, count: tauMax + 1)
        var running: Float = 0
        for tau in 1...tauMax {
            running += difference[tau]
            if running > 0 {
                cmndf[tau] = difference[tau] * Float(tau) / running
            }
        }

        let threshold: Float = 0.15
        var tauEstimate = 0
        var tau = tauMin
        while tau <= tauMax {
            if cmndf[tau] < threshold {
                while tau + 1 <= tauMax, cmndf[tau + 1] < cmndf[tau] {
                    tau += 1
                }
                tauEstimate = tau
                break
            }
            tau += 1
        }

        if tauEstimate == 0 {
            var minimum = Float.greatestFiniteMagnitude
            for candidate in tauMin...tauMax where cmndf[candidate] < minimum {
                minimum = cmndf[candidate]
                tauEstimate = candidate
            }
            if minimum > 0.45 { return nil }
        }

        let previous = cmndf[max(tauEstimate - 1, 1)]
        let center = cmndf[tauEstimate]
        let next = cmndf[min(tauEstimate + 1, tauMax)]
        let denominator = 2 * (2 * center - next - previous)
        let refined: Double
        if denominator != 0 {
            refined = Double(tauEstimate) + Double(next - previous) / Double(denominator)
        } else {
            refined = Double(tauEstimate)
        }

        guard refined > 0 else { return nil }
        let hz = sampleRate / refined
        guard hz.isFinite, hz >= minHz, hz <= maxHz else { return nil }
        return hz
    }
}
