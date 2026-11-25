import AVFoundation
import Foundation

// MARK: - ClickPlayer
// Main-actor façade over ClickEngine (locked mutable state + AVAudioPlayerNode).

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
// Mutable scheduling state is guarded by `lock` so start/update/stop and the detached loop share one writer protocol.

private final class ClickEngine: @unchecked Sendable {
    private let audioEngine = AVAudioEngine()
    private let node = AVAudioPlayerNode()
    private let lock = NSLock()
    private let format: AVAudioFormat?

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
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)
        self.format = format
        if let format {
            audioEngine.connect(node, to: audioEngine.mainMixerNode, format: format)
        }
    }

    func start(
        bpm: Int,
        beatsPerMeasure: Int,
        clicksPerBeat: Int,
        sound: ClickSound,
        onBeat: @escaping (Int, Bool) -> Void
    ) {
        stop()
        guard format != nil else { return }

        lock.lock()
        self.bpm = Tempo.clamped(bpm)
        self.beatsPerMeasure = max(1, beatsPerMeasure)
        self.clicksPerBeat = max(1, clicksPerBeat)
        self.sound = sound
        self.onBeat = onBeat
        self.beat = 1
        self.clickIndex = 0
        lock.unlock()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            if !audioEngine.isRunning {
                try audioEngine.start()
            }
            node.play()
            lock.lock()
            isRunning = true
            lock.unlock()
            scheduleLoop()
        } catch {
            lock.lock()
            isRunning = false
            lock.unlock()
        }
    }

    func update(bpm: Int, beatsPerMeasure: Int, clicksPerBeat: Int, sound: ClickSound) {
        lock.lock()
        self.bpm = Tempo.clamped(bpm)
        self.beatsPerMeasure = max(1, beatsPerMeasure)
        self.clicksPerBeat = max(1, clicksPerBeat)
        self.sound = sound
        lock.unlock()
    }

    func stop() {
        schedulerTask?.cancel()
        schedulerTask = nil
        lock.lock()
        isRunning = false
        lock.unlock()
        node.stop()
        if audioEngine.isRunning {
            audioEngine.pause()
        }
    }

    private func scheduleLoop() {
        schedulerTask = Task.detached { [weak self] in
            while let self, !Task.isCancelled {
                let snapshot = self.snapshotForTick()
                guard snapshot.isRunning else { break }

                if snapshot.sound != .mute {
                    self.playClick(sound: snapshot.sound, isAccent: snapshot.isAccent)
                }
                if snapshot.isBeat {
                    snapshot.onBeat?(snapshot.beat, snapshot.isAccent)
                }

                self.advanceCounters(
                    clicksPerBeat: snapshot.clicksPerBeat,
                    beatsPerMeasure: snapshot.beatsPerMeasure
                )

                let nanos = UInt64((60.0 / Double(snapshot.bpm) / Double(snapshot.clicksPerBeat)) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanos)
            }
        }
    }

    private struct TickSnapshot {
        let isRunning: Bool
        let bpm: Int
        let beatsPerMeasure: Int
        let clicksPerBeat: Int
        let sound: ClickSound
        let beat: Int
        let isBeat: Bool
        let isAccent: Bool
        let onBeat: ((Int, Bool) -> Void)?
    }

    private func snapshotForTick() -> TickSnapshot {
        lock.lock()
        defer { lock.unlock() }
        let isBeat = clickIndex == 0
        let isAccent = isBeat && beat == 1
        return TickSnapshot(
            isRunning: isRunning,
            bpm: bpm,
            beatsPerMeasure: beatsPerMeasure,
            clicksPerBeat: clicksPerBeat,
            sound: sound,
            beat: beat,
            isBeat: isBeat,
            isAccent: isAccent,
            onBeat: onBeat
        )
    }

    private func advanceCounters(clicksPerBeat: Int, beatsPerMeasure: Int) {
        lock.lock()
        defer { lock.unlock() }
        clickIndex += 1
        if clickIndex >= clicksPerBeat {
            clickIndex = 0
            beat += 1
            if beat > beatsPerMeasure {
                beat = 1
            }
        }
    }

    private func playClick(sound: ClickSound, isAccent: Bool) {
        guard let buffer = Self.makeBuffer(sound: sound, isAccent: isAccent) else { return }
        node.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }

    private static func makeBuffer(sound: ClickSound, isAccent: Bool) -> AVAudioPCMBuffer? {
        let sampleRate = 44_100.0
        let duration = isAccent ? 0.04 : 0.03
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return nil }
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
