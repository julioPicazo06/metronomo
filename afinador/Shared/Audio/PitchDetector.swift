import AVFoundation
import Foundation

// MARK: - PitchDetector
// Main-actor façade. PitchEngine (@unchecked Sendable) owns AVAudioEngine + input tap.
// Frequencies are EMA-smoothed (65/35) then forwarded to TunerModelView.ingest.

final class PitchDetector: PitchDetecting {
    var onFrequency: ((Double) -> Void)?

    private let engine = PitchEngine()
    private var lastPublished: Double?

    func start() throws {
        engine.onFrequency = { [weak self] frequency in
            Task { @MainActor in
                self?.publish(frequency)
            }
        }
        try engine.start()
    }

    func stop() {
        engine.stop()
        lastPublished = nil
    }

    private func publish(_ frequency: Double) {
        let smoothed: Double
        if let lastPublished {
            smoothed = lastPublished * 0.65 + frequency * 0.35
        } else {
            smoothed = frequency
        }
        lastPublished = smoothed
        onFrequency?(smoothed)
    }
}

// MARK: - PitchEngine
// Real-time tap. Do not hop to MainActor inside handle() — only after YIN returns a Hz value.

private final class PitchEngine: @unchecked Sendable {
    var onFrequency: ((Double) -> Void)?
    private let engine = AVAudioEngine()
    private var isRunning = false
    private let bufferSize: AVAudioFrameCount = 4096

    func start() throws {
        guard !isRunning else { return }
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .mixWithOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, _ in
            self?.handle(buffer: buffer, sampleRate: format.sampleRate)
        }
        engine.prepare()
        try engine.start()
        isRunning = true
    }

    func stop() {
        guard isRunning else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        isRunning = false
    }

    private func handle(buffer: AVAudioPCMBuffer, sampleRate: Double) {
        guard let channel = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0 else { return }
        var samples = [Float](repeating: 0, count: frameCount)
        for index in 0..<frameCount {
            samples[index] = channel[index]
        }
        if let frequency = PitchEstimator.frequency(samples: samples, sampleRate: sampleRate) {
            onFrequency?(frequency)
        }
    }
}
