import AVFoundation
import Foundation
import UIKit

// MARK: - ClickPlayer
// Main-actor façade over ClickEngine (detached scheduling loop + AVAudioPlayerNode).

final class ClickPlayer: ClickPlaying {
    private let engine = ClickEngine()

    func start(
        bpm: Int,
        beatsPerMeasure: Int,
        clicksPerBeat: Int,
        sound: ClickSound,
        onBeat: @escaping (Int, Bool) -> Void
    ) {
        engine.start(
            bpm: bpm,
            beatsPerMeasure: beatsPerMeasure,
            clicksPerBeat: clicksPerBeat,
            sound: sound,
            onBeat: { beat, isAccent in
                Task { @MainActor in
                    onBeat(beat, isAccent)
                }
            }
        )
    }

    func update(bpm: Int, beatsPerMeasure: Int, clicksPerBeat: Int, sound: ClickSound) {
        engine.update(bpm: bpm, beatsPerMeasure: beatsPerMeasure, clicksPerBeat: clicksPerBeat, sound: sound)
    }

    func stop() {
        engine.stop()
    }
}

// MARK: - ClickEngine
// Sleeps 60/bpm/clicksPerBeat between clicks. Downbeat (beat 1, click 0) is louder / higher Hz.

private final class ClickEngine: @unchecked Sendable {
    private let audioEngine = AVAudioEngine()
    private let node = AVAudioPlayerNode()
    private var isRunning = false
    private var schedulerTask: Task<Void, Never>?
    private var beat = 1
    private var clickIndex = 0
    private var bpm = Tempo.default
    private var beatsPerMeasure = 4
    private var clicksPerBeat = 1
    private var sound: ClickSound = .click
    private var onBeat: ((Int, Bool) -> Void)?

    init() {
        audioEngine.attach(node)
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        audioEngine.connect(node, to: audioEngine.mainMixerNode, format: format)
    }

    func start(
        bpm: Int,
        beatsPerMeasure: Int,
        clicksPerBeat: Int,
        sound: ClickSound,
        onBeat: @escaping (Int, Bool) -> Void
    ) {
        stop()
        self.bpm = Tempo.clamped(bpm)
        self.beatsPerMeasure = max(1, beatsPerMeasure)
        self.clicksPerBeat = max(1, clicksPerBeat)
        self.sound = sound
        self.onBeat = onBeat
        self.beat = 1
        self.clickIndex = 0

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            if !audioEngine.isRunning {
                try audioEngine.start()
            }
            node.play()
            isRunning = true
            scheduleLoop()
        } catch {
            isRunning = false
        }
    }

    func update(bpm: Int, beatsPerMeasure: Int, clicksPerBeat: Int, sound: ClickSound) {
        self.bpm = Tempo.clamped(bpm)
        self.beatsPerMeasure = max(1, beatsPerMeasure)
        self.clicksPerBeat = max(1, clicksPerBeat)
        self.sound = sound
    }

    func stop() {
        schedulerTask?.cancel()
        schedulerTask = nil
        isRunning = false
        node.stop()
        if audioEngine.isRunning {
            audioEngine.pause()
        }
    }

    private func scheduleLoop() {
        schedulerTask = Task.detached { [weak self] in
            while let self, self.isRunning, !Task.isCancelled {
                let isAccent = self.clickIndex == 0 && self.beat == 1
                let isBeat = self.clickIndex == 0
                if self.sound != .mute {
                    self.playClick(isAccent: isAccent)
                }
                if isBeat {
                    self.onBeat?(self.beat, isAccent)
                }

                self.clickIndex += 1
                if self.clickIndex >= self.clicksPerBeat {
                    self.clickIndex = 0
                    self.beat += 1
                    if self.beat > self.beatsPerMeasure {
                        self.beat = 1
                    }
                }

                let nanos = UInt64((60.0 / Double(self.bpm) / Double(self.clicksPerBeat)) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanos)
            }
        }
    }

    private func playClick(isAccent: Bool) {
        guard let buffer = Self.makeBuffer(sound: sound, isAccent: isAccent) else { return }
        node.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }

    private static func makeBuffer(sound: ClickSound, isAccent: Bool) -> AVAudioPCMBuffer? {
        let sampleRate = 44_100.0
        let duration = isAccent ? 0.04 : 0.03
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        guard let channel = buffer.floatChannelData?[0] else { return nil }

        let frequency: Double
        switch sound {
        case .click:
            frequency = isAccent ? 1_800 : 1_200
        case .wood:
            frequency = isAccent ? 900 : 600
        case .beep:
            frequency = isAccent ? 1_000 : 700
        case .mute:
            return nil
        }

        let amplitude: Float = isAccent ? 0.55 : 0.32
        for index in 0..<Int(frameCount) {
            let time = Double(index) / sampleRate
            let envelope = Float(exp(-time * 70))
            channel[index] = Float(sin(2 * Double.pi * frequency * time)) * amplitude * envelope
        }
        return buffer
    }
}

// MARK: - HapticPlayer
// UIImpactFeedbackGenerator. Gated by AppSettingsStore.hapticsEnabled in the ModelViews.

final class HapticPlayer: HapticPlaying {
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)

    func playInTune() {
        medium.impactOccurred()
    }

    func playClick(isAccent: Bool) {
        if isAccent {
            medium.impactOccurred(intensity: 1)
        } else {
            light.impactOccurred(intensity: 0.7)
        }
    }
}
