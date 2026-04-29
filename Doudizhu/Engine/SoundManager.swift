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
    case rocketLaunch
    case bossAppear
    case goldCoin
}

// MARK: - BGM 模式

enum BGMMode: Sendable {
    case battle
    case boss
    case shop
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
        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        ) else { return }
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
        case .rocketLaunch:       samples = makeRocketLaunch()
        case .bossAppear:         samples = makeBossAppear()
        case .goldCoin:           samples = makeGoldCoin()
        }

        scheduleBuffer(samples)
    }

    // MARK: - Buffer Scheduling

    private func scheduleBuffer(_ samples: [Float]) {
        guard !samples.isEmpty else { return }
        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        ) else { return }
        let frameCount = AVAudioFrameCount(samples.count)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        guard let channelData = buffer.floatChannelData?[0] else { return }
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

    /// Rocket whoosh + explosion (~400ms)
    private func makeRocketLaunch() -> [Float] {
        let count = Int(sampleRate * 0.4)
        let whoosh: [Float] = (0..<count).map { i in
            let t = Float(i) / Float(sampleRate)
            let freq: Float = 200 + 2000 * t * t  // accelerating rise
            return 0.15 * sinf(2 * .pi * freq * t)
        }
        let noiseBurst = envelope(
            noise(duration: 0.4, amplitude: 0.15),
            attack: 0.01, decay: 0.1, sustain: 0.05, release: 0.25
        )
        return mix([
            envelope(whoosh, attack: 0.01, decay: 0.1, sustain: 0.08, release: 0.22),
            noiseBurst
        ])
    }

    /// Ominous boss entrance (~600ms)
    private func makeBossAppear() -> [Float] {
        let deep = envelope(
            sine(frequency: 80, duration: 0.6, amplitude: 0.35),
            attack: 0.05, decay: 0.1, sustain: 0.15, release: 0.3
        )
        let dissonant = envelope(
            sine(frequency: 113, duration: 0.5, amplitude: 0.15),
            attack: 0.08, decay: 0.1, sustain: 0.1, release: 0.22
        )
        let rumble = envelope(
            noise(duration: 0.6, amplitude: 0.08),
            attack: 0.05, decay: 0.15, sustain: 0.05, release: 0.35
        )
        return mix([deep, dissonant, rumble])
    }

    /// Quick coin collect (~120ms)
    private func makeGoldCoin() -> [Float] {
        let ping = envelope(
            sine(frequency: 2400, duration: 0.12, amplitude: 0.15),
            attack: 0.002, decay: 0.02, sustain: 0.03, release: 0.07
        )
        let harmonic = envelope(
            sine(frequency: 3600, duration: 0.08, amplitude: 0.06),
            attack: 0.002, decay: 0.015, sustain: 0.01, release: 0.05
        )
        return mix([ping, harmonic])
    }

    // MARK: - BGM System

    private var bgmPlayerNode: AVAudioPlayerNode?
    private var bgmTimer: Timer?
    private var isBGMPlaying = false
    private var currentBGMMode: BGMMode = .battle

    /// 开始播放程序化环境 BGM（可指定模式）
    func startBGM(mode: BGMMode = .battle) {
        guard UserDefaults.standard.bool(forKey: "musicEnabled") else { return }
        let modeChanged = currentBGMMode != mode
        currentBGMMode = mode
        if isBGMPlaying && !modeChanged { return }
        if modeChanged && isBGMPlaying { stopBGM() }
        isBGMPlaying = true
        ensureRunning()
        playBGMLoop()
    }

    /// 停止 BGM
    func stopBGM() {
        isBGMPlaying = false
        bgmTimer?.invalidate()
        bgmTimer = nil
        bgmPlayerNode?.stop()
    }

    /// 程序化 BGM — 根据模式选择不同风格
    private func playBGMLoop() {
        guard isBGMPlaying else { return }

        let samples: [Float]
        switch currentBGMMode {
        case .battle: samples = generateBGMPhrase()
        case .boss:   samples = generateBossBGMPhrase()
        case .shop:   samples = generateShopBGMPhrase()
        }
        scheduleBuffer(samples)

        // 循环播放（每个乐句约4秒）
        let phraseDuration = Double(samples.count) / sampleRate
        bgmTimer = Timer.scheduledTimer(withTimeInterval: phraseDuration, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.playBGMLoop()
            }
        }
    }

    /// 生成一个 BGM 乐句（五声音阶 + 随机变化）
    private func generateBGMPhrase() -> [Float] {
        // 中国五声音阶 (宫商角徵羽): C D E G A
        let pentatonic: [Float] = [262, 294, 330, 392, 440, 523, 588, 660]
        let noteDurations: [Float] = [0.4, 0.3, 0.5, 0.6, 0.35, 0.45]

        var phrase: [[Float]] = []
        let noteCount = Int.random(in: 6...9)

        for i in 0..<noteCount {
            let freq = pentatonic.randomElement() ?? 440
            let dur = noteDurations.randomElement() ?? 0.4
            let amp: Float = Float.random(in: 0.03...0.06)

            let note = envelope(
                sine(frequency: freq, duration: dur, amplitude: amp),
                attack: 0.02, decay: 0.05, sustain: 0.5, release: dur * 0.4
            )

            // 偶尔加泛音（古筝效果）
            if i % 3 == 0 {
                let harmonic = envelope(
                    sine(frequency: freq * 2, duration: dur * 0.6, amplitude: amp * 0.25),
                    attack: 0.01, decay: 0.03, sustain: 0.2, release: dur * 0.3
                )
                let maxLen = max(note.count, harmonic.count)
                var padNote = note + [Float](repeating: 0, count: max(0, maxLen - note.count))
                let padHarm = harmonic + [Float](repeating: 0, count: max(0, maxLen - harmonic.count))
                padNote = mix([padNote, padHarm])
                phrase.append(padNote)
            } else {
                phrase.append(note)
            }

            // 随机间隔
            if Bool.random() {
                let silence = [Float](repeating: 0, count: Int(sampleRate * Double(Float.random(in: 0.1...0.25))))
                phrase.append(silence)
            }
        }

        return concat(phrase)
    }

    /// Boss BGM — 低沉、不稳定、带压迫感的暗调五声音阶
    private func generateBossBGMPhrase() -> [Float] {
        let darkScale: [Float] = [131, 147, 165, 196, 220, 262, 294]
        let noteDurations: [Float] = [0.5, 0.6, 0.7, 0.8, 0.45]

        var phrase: [[Float]] = []
        let noteCount = Int.random(in: 5...8)

        for i in 0..<noteCount {
            let freq = darkScale.randomElement() ?? 196
            let dur = noteDurations.randomElement() ?? 0.5
            let amp: Float = Float.random(in: 0.04...0.08)

            let note = envelope(
                sine(frequency: freq, duration: dur, amplitude: amp),
                attack: 0.03, decay: 0.08, sustain: 0.4, release: dur * 0.5
            )

            // 不协和泛音（增加压迫感）
            if i % 2 == 0 {
                let dissonant = envelope(
                    sine(frequency: freq * 1.06, duration: dur * 0.5, amplitude: amp * 0.3),
                    attack: 0.02, decay: 0.05, sustain: 0.15, release: dur * 0.3
                )
                let maxLen = max(note.count, dissonant.count)
                var padNote = note + [Float](repeating: 0, count: max(0, maxLen - note.count))
                let padDiss = dissonant + [Float](repeating: 0, count: max(0, maxLen - dissonant.count))
                padNote = mix([padNote, padDiss])
                phrase.append(padNote)
            } else {
                phrase.append(note)
            }

            // 低频脉动鼓点
            if i % 3 == 0 {
                let drum = envelope(
                    sine(frequency: 55, duration: 0.2, amplitude: 0.06),
                    attack: 0.005, decay: 0.04, sustain: 0.02, release: 0.13
                )
                phrase.append(drum)
            }

            // 较长的不安静默
            let silence = [Float](repeating: 0, count: Int(sampleRate * Double(Float.random(in: 0.15...0.4))))
            phrase.append(silence)
        }

        return concat(phrase)
    }

    /// 商店 BGM — 轻快、明亮的高音区五声音阶
    private func generateShopBGMPhrase() -> [Float] {
        let lightScale: [Float] = [523, 588, 660, 784, 880, 1047]
        let noteDurations: [Float] = [0.25, 0.3, 0.35, 0.2]

        var phrase: [[Float]] = []
        let noteCount = Int.random(in: 7...10)

        for i in 0..<noteCount {
            let freq = lightScale.randomElement() ?? 660
            let dur = noteDurations.randomElement() ?? 0.3
            let amp: Float = Float.random(in: 0.02...0.04)

            let note = envelope(
                sine(frequency: freq, duration: dur, amplitude: amp),
                attack: 0.01, decay: 0.03, sustain: 0.4, release: dur * 0.4
            )

            // 轻盈泛音（风铃效果）
            if i % 2 == 0 {
                let chime = envelope(
                    sine(frequency: freq * 2, duration: dur * 0.4, amplitude: amp * 0.2),
                    attack: 0.005, decay: 0.02, sustain: 0.1, release: dur * 0.2
                )
                let maxLen = max(note.count, chime.count)
                var padNote = note + [Float](repeating: 0, count: max(0, maxLen - note.count))
                let padChime = chime + [Float](repeating: 0, count: max(0, maxLen - chime.count))
                padNote = mix([padNote, padChime])
                phrase.append(padNote)
            } else {
                phrase.append(note)
            }

            // 频繁但短的间隔
            if Bool.random() {
                let silence = [Float](repeating: 0, count: Int(sampleRate * Double(Float.random(in: 0.08...0.18))))
                phrase.append(silence)
            }
        }

        return concat(phrase)
    }
}
