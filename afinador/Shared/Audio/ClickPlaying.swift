import Foundation

// MARK: - ClickPlaying
// Metronome audio port. onBeat(beat, isAccent) hops to MainActor for the pulse dots.
// update(...) hot-swaps BPM/signature while running without a restart click.

protocol ClickPlaying: AnyObject {
    func start(
        bpm: Int,
        beatsPerMeasure: Int,
        clicksPerBeat: Int,
        sound: ClickSound,
        onBeat: @escaping (_ beat: Int, _ isAccent: Bool) -> Void
    )
    func stop()
    func update(bpm: Int, beatsPerMeasure: Int, clicksPerBeat: Int, sound: ClickSound)
}
