import AVFoundation

// MARK: - 音效事件枚举

enum GameSound: Sendable {
    case cardTap
    case cardPlay
    case cardDiscard
    case bombExplosion
    case comboHit(level: Int)
    case scoreUp
    case shopBuy
    case floorClear
    case floorFail
    case victory
    case buttonTap
    case achievementUnlock
}

// MARK: - 程序化音效管理器

@MainActor
final class SoundManager {
    static let shared = SoundManager()

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Self.enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.enabledKey) }
    }

    var volume: Float {
        get { UserDefaults.standard.float(forKey: Self.volumeKey) }
        set {
            let clamped = min(1.0, max(0.0, newValue))
            UserDefaults.standard.set(clamped, forKey: Self.volumeKey)
            engine.mainMixerNode.outputVolume = clamped
        }
    }

    private static let enabledKey = "soundEnabled"
    private static let volumeKey  = "soundVolume"

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let sampleRate: Double = 44100

    private init() {
        // Register defaults so first launch has sound on at 0.5 volume
        UserDefaults.standard.register(defaults: [
            Self.enabledKey: true,
            Self.volumeKey: Float(0.5)
        ])

        setupEngine()
    }

    // MARK: - Engine Setup

    private func setupEngine() {
        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        )!
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = UserDefaults.standard.float(forKey: Self.volumeKey)

        do {
            try engine.start()
            playerNode.play()
        } catch {
            // Engine start failure — sounds will be silent
        }
    }

    private func ensureRunning() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
            playerNode.play()
        } catch { /* silent fallback */ }
    }

    // MARK: - Public API

    func play(_ sound: GameSound) {
        guard isEnabled else { return }
        ensureRunning()

        let samples: [Float]
        switch sound {
        case .cardTap:            samples = makeCardTap()
        case .cardPlay:           samples = makeCardPlay()
        case .cardDiscard:        samples = makeCardDiscard()
        case .bombExplosion:      samples = makeBombExplosion()
        case .comboHit(let lvl):  samples = makeComboHit(level: lvl)
        case .scoreUp:            samples = makeScoreUp()
        case .shopBuy:            samples = makeShopBuy()
        case .floorClear:         samples = makeFloorClear()
        case .floorFail:          samples = makeFloorFail()
        case .victory:            samples = makeVictory()
        case .buttonTap:          samples = makeButtonTap()
        case .achievementUnlock:  samples = makeAchievementUnlock()
        }

        scheduleBuffer(samples)
    }

    // MARK: - Buffer Scheduling

    private func scheduleBuffer(_ samples: [Float]) {
        guard !samples.isEmpty else { return }
        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        )!
        let frameCount = AVAudioFrameCount(samples.count)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        let channelData = buffer.floatChannelData![0]
        for i in 0..<samples.count {
            channelData[i] = samples[i]
        }

        playerNode.scheduleBuffer(buffer, completionHandler: nil)
    }

    // MARK: - Waveform Primitives

    /// Sine wave at given frequency for given duration
    private func sine(frequency: Float, duration: Float, amplitude: Float = 1.0) -> [Float] {
        let count = Int(sampleRate * Double(duration))
        return (0..<count).map { i in
            let t = Float(i) / Float(sampleRate)
            return amplitude * sinf(2 * .pi * frequency * t)
        }
    }

    /// Apply ADSR envelope to raw samples
    private func envelope(
        _ samples: [Float],
        attack: Float,
        decay: Float,
        sustain: Float,
        release: Float
    ) -> [Float] {
        let total = samples.count
        let a = Int(attack * Float(sampleRate))
        let d = Int(decay * Float(sampleRate))
        let r = Int(release * Float(sampleRate))
        let s = max(0, total - a - d - r)

        return samples.enumerated().map { i, sample in
            let gain: Float
            if i < a {
                gain = Float(i) / max(Float(a), 1)
            } else if i < a + d {
                let progress = Float(i - a) / max(Float(d), 1)
                gain = 1.0 - progress * (1.0 - sustain)
            } else if i < a + d + s {
                gain = sustain
            } else {
                let progress = Float(i - a - d - s) / max(Float(r), 1)
                gain = sustain * (1.0 - progress)
            }
            return sample * gain
        }
    }

    /// White noise burst
    private func noise(duration: Float, amplitude: Float = 1.0) -> [Float] {
        let count = Int(sampleRate * Double(duration))
        return (0..<count).map { _ in
            Float.random(in: -amplitude...amplitude)
        }
    }

    /// Mix multiple sample arrays (must be same length or will use shortest)
    private func mix(_ layers: [[Float]]) -> [Float] {
        guard let maxLen = layers.map(\.count).max(), maxLen > 0 else { return [] }
        return (0..<maxLen).map { i in
            layers.reduce(Float(0)) { sum, layer in
                sum + (i < layer.count ? layer[i] : 0)
            }
        }
    }

    /// Concatenate sample arrays
    private func concat(_ segments: [[Float]]) -> [Float] {
        segments.flatMap { $0 }
    }

    // MARK: - Sound Designs

    /// Quick soft click (~50ms)
    private func makeCardTap() -> [Float] {
        let raw = sine(frequency: 1800, duration: 0.05, amplitude: 0.15)
        return envelope(raw, attack: 0.002, decay: 0.015, sustain: 0.0, release: 0.03)
    }

    /// Card slap/place (~150ms)
    private func makeCardPlay() -> [Float] {
        let thud = envelope(
            sine(frequency: 220, duration: 0.15, amplitude: 0.3),
            attack: 0.003, decay: 0.04, sustain: 0.1, release: 0.1
        )
        let click = envelope(
            noise(duration: 0.15, amplitude: 0.12),
            attack: 0.001, decay: 0.02, sustain: 0.0, release: 0.02
        )
        return mix([thud, click])
    }

    /// Shuffle/whoosh (~200ms)
    private func makeCardDiscard() -> [Float] {
        let count = Int(sampleRate * 0.2)
        let raw: [Float] = (0..<count).map { i in
            let t = Float(i) / Float(sampleRate)
            let freq = 400 + 800 * t  // rising sweep
            return 0.1 * sinf(2 * .pi * freq * t)
        }
        let noisePart = envelope(
            noise(duration: 0.2, amplitude: 0.08),
            attack: 0.01, decay: 0.05, sustain: 0.02, release: 0.12
        )
        return mix([
            envelope(raw, attack: 0.01, decay: 0.05, sustain: 0.02, release: 0.12),
            noisePart
        ])
    }

    /// Deep boom (~300ms)
    private func makeBombExplosion() -> [Float] {
        let boom = envelope(
            sine(frequency: 60, duration: 0.3, amplitude: 0.5),
            attack: 0.005, decay: 0.08, sustain: 0.15, release: 0.17
        )
        let mid = envelope(
            sine(frequency: 120, duration: 0.25, amplitude: 0.25),
            attack: 0.003, decay: 0.06, sustain: 0.05, release: 0.14
        )
        let crack = envelope(
            noise(duration: 0.3, amplitude: 0.2),
            attack: 0.002, decay: 0.03, sustain: 0.02, release: 0.05
        )
        return mix([boom, mid, crack])
    }

    /// Rising tone scaled by combo level (~200ms)
    private func makeComboHit(level: Int) -> [Float] {
        let baseFreq: Float = 500 + Float(min(level, 8)) * 80
        let raw = envelope(
            sine(frequency: baseFreq, duration: 0.2, amplitude: 0.25),
            attack: 0.005, decay: 0.04, sustain: 0.1, release: 0.1
        )
        let harmonic = envelope(
            sine(frequency: baseFreq * 1.5, duration: 0.15, amplitude: 0.1),
            attack: 0.005, decay: 0.03, sustain: 0.02, release: 0.09
        )
        return mix([raw, harmonic])
    }

    /// Cheerful ascending ding (~250ms)
    private func makeScoreUp() -> [Float] {
        let ding = envelope(
            sine(frequency: 880, duration: 0.25, amplitude: 0.2),
            attack: 0.003, decay: 0.05, sustain: 0.08, release: 0.12
        )
        let shimmer = envelope(
            sine(frequency: 1760, duration: 0.15, amplitude: 0.08),
            attack: 0.003, decay: 0.03, sustain: 0.02, release: 0.09
        )
        return mix([ding, shimmer])
    }

    /// Cash register / coin (~200ms)
    private func makeShopBuy() -> [Float] {
        let coin1 = envelope(
            sine(frequency: 1200, duration: 0.1, amplitude: 0.2),
            attack: 0.002, decay: 0.02, sustain: 0.05, release: 0.05
        )
        let coin2 = envelope(
            sine(frequency: 1500, duration: 0.1, amplitude: 0.2),
            attack: 0.002, decay: 0.02, sustain: 0.05, release: 0.05
        )
        return concat([coin1, coin2])
    }

    /// Victory fanfare — ascending 3-note arpeggio (~500ms)
    private func makeFloorClear() -> [Float] {
        // C5 → E5 → G5
        let note1 = envelope(
            sine(frequency: 523, duration: 0.16, amplitude: 0.2),
            attack: 0.005, decay: 0.03, sustain: 0.1, release: 0.02
        )
        let note2 = envelope(
            sine(frequency: 659, duration: 0.16, amplitude: 0.2),
            attack: 0.005, decay: 0.03, sustain: 0.1, release: 0.02
        )
        let note3 = envelope(
            sine(frequency: 784, duration: 0.2, amplitude: 0.25),
            attack: 0.005, decay: 0.03, sustain: 0.1, release: 0.06
        )
        return concat([note1, note2, note3])
    }

    /// Descending sad tone (~400ms)
    private func makeFloorFail() -> [Float] {
        let count = Int(sampleRate * 0.4)
        let raw: [Float] = (0..<count).map { i in
            let t = Float(i) / Float(sampleRate)
            let freq: Float = 440 - 200 * t  // descending
            return 0.2 * sinf(2 * .pi * freq * t)
        }
        return envelope(raw, attack: 0.01, decay: 0.08, sustain: 0.1, release: 0.22)
    }

    /// Grand victory — 5-note ascending arpeggio (~800ms)
    private func makeVictory() -> [Float] {
        // C5 → E5 → G5 → C6 → E6
        let freqs: [Float] = [523, 659, 784, 1047, 1319]
        let segments = freqs.enumerated().map { index, freq in
            let dur: Float = index == freqs.count - 1 ? 0.24 : 0.14
            let amp: Float = 0.15 + Float(index) * 0.02
            return envelope(
                sine(frequency: freq, duration: dur, amplitude: amp),
                attack: 0.005, decay: 0.03, sustain: 0.08, release: 0.02
            )
        }
        return concat(segments)
    }

    /// Very subtle UI tap (~50ms)
    private func makeButtonTap() -> [Float] {
        let raw = sine(frequency: 1400, duration: 0.04, amplitude: 0.1)
        return envelope(raw, attack: 0.002, decay: 0.01, sustain: 0.0, release: 0.025)
    }

    /// Sparkle/chime (~400ms)
    private func makeAchievementUnlock() -> [Float] {
        let chime1 = envelope(
            sine(frequency: 1047, duration: 0.15, amplitude: 0.18),
            attack: 0.003, decay: 0.03, sustain: 0.06, release: 0.06
        )
        let chime2 = envelope(
            sine(frequency: 1319, duration: 0.12, amplitude: 0.18),
            attack: 0.003, decay: 0.03, sustain: 0.04, release: 0.05
        )
        let shimmer = envelope(
            sine(frequency: 2093, duration: 0.2, amplitude: 0.12),
            attack: 0.005, decay: 0.04, sustain: 0.04, release: 0.11
        )
        // chime1 → chime2, with shimmer layered on chime2
        let part1 = chime1
        var part2 = chime2
        // Pad shimmer to match chime2 length then mix
        let maxLen = max(part2.count, shimmer.count)
        part2 += [Float](repeating: 0, count: max(0, maxLen - part2.count))
        var shimmerPadded = shimmer
        shimmerPadded += [Float](repeating: 0, count: max(0, maxLen - shimmerPadded.count))
        let combined = mix([part2, shimmerPadded])
        return concat([part1, combined])
    }
}
