import Foundation

/// Daily Challenge — a curated challenge that changes every day
/// All players get the same seed → same floor sequence + shop items
struct DailyChallenge {
    let date: Date
    let seed: UInt64
    let modifiers: [DailyChallengeModifier]
    let bonusGold: Int

    /// Today's challenge
    static var today: DailyChallenge {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day], from: Date())
        let seed = UInt64(comps.year! * 10000 + comps.month! * 100 + comps.day!)

        // Rotate modifiers based on day of week + week parity
        let dayOfWeek = cal.component(.weekday, from: Date())
        let weekOfYear = cal.component(.weekOfYear, from: Date())
        let isEvenWeek = weekOfYear % 2 == 0
        let mods: [DailyChallengeModifier] = {
            switch dayOfWeek {
            case 1: return [isEvenWeek ? .noBombs : .allOrNothing]
            case 2: return [isEvenWeek ? .halfGold : .goldRush]
            case 3: return [isEvenWeek ? .extraPlays : .giantHand]
            case 4: return [isEvenWeek ? .noDiscards : .tinyDeck]
            case 5: return [isEvenWeek ? .doubleScore : .mirrorMatch]
            case 6: return [isEvenWeek ? .speedRun : .bossRush]
            case 7: return [.bossRush, .speedRun]   // Saturday: double modifier
            default: return []
            }
        }()

        return DailyChallenge(date: Date(), seed: seed, modifiers: mods, bonusGold: 50)
    }

    /// Has today's challenge been completed (won or lost)?
    static var hasCompletedToday: Bool {
        let key = "dailyChallengeCompleted"
        guard let lastDate = UserDefaults.standard.string(forKey: key) else { return false }
        return lastDate == todayString
    }

    /// Is there an in-progress daily challenge that can be resumed?
    static var hasInProgressToday: Bool {
        let startKey = "dailyChallengeStarted"
        guard let startDate = UserDefaults.standard.string(forKey: startKey) else { return false }
        return startDate == todayString && !hasCompletedToday
    }

    /// Has today's challenge been attempted? (backward compat: completed OR started)
    static var hasPlayedToday: Bool {
        hasCompletedToday
    }

    /// Record that today's challenge was started
    static func markStarted() {
        UserDefaults.standard.set(todayString, forKey: "dailyChallengeStarted")
    }

    /// Record that today's challenge was completed (won, failed, or abandoned)
    static func markCompleted() {
        UserDefaults.standard.set(todayString, forKey: "dailyChallengeCompleted")
    }

    /// Record that today's challenge was attempted (legacy, calls markStarted)
    static func markPlayed() {
        markStarted()
    }

    /// Record high score for daily
    static func recordScore(_ score: Int) {
        let key = "dailyBest_\(todayString)"
        let current = UserDefaults.standard.integer(forKey: key)
        if score > current {
            UserDefaults.standard.set(score, forKey: key)
        }
    }

    static var todayBest: Int {
        UserDefaults.standard.integer(forKey: "dailyBest_\(todayString)")
    }

    private static var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}

enum DailyChallengeModifier: String, CaseIterable {
    case noBombs = "no_bombs"
    case halfGold = "half_gold"
    case extraPlays = "extra_plays"
    case noDiscards = "no_discards"
    case doubleScore = "double_score"
    case speedRun = "speed_run"
    case bossRush = "boss_rush"
    // 新增 5 种模式
    case giantHand = "giant_hand"        // 手牌+5张
    case tinyDeck = "tiny_deck"          // 牌堆仅36张
    case allOrNothing = "all_or_nothing" // 只能炸弹/火箭得分
    case goldRush = "gold_rush"          // 金币×3但商店价格×2
    case mirrorMatch = "mirror_match"    // 每层都有Boss修改器

    var name: String {
        switch self {
        case .noBombs: return L10n.isEnglish ? "No Bombs" : "禁止炸弹"
        case .halfGold: return L10n.isEnglish ? "Half Gold" : "金币减半"
        case .extraPlays: return L10n.isEnglish ? "Extra Plays" : "额外出牌"
        case .noDiscards: return L10n.isEnglish ? "No Discards" : "禁止换牌"
        case .doubleScore: return L10n.isEnglish ? "Double Score" : "双倍得分"
        case .speedRun: return L10n.isEnglish ? "Speed Run" : "极速挑战"
        case .bossRush: return L10n.isEnglish ? "Boss Rush" : "Boss连战"
        case .giantHand: return L10n.isEnglish ? "Giant Hand" : "巨人之手"
        case .tinyDeck: return L10n.isEnglish ? "Tiny Deck" : "精简牌组"
        case .allOrNothing: return L10n.isEnglish ? "All or Nothing" : "孤注一掷"
        case .goldRush: return L10n.isEnglish ? "Gold Rush" : "淘金热"
        case .mirrorMatch: return L10n.isEnglish ? "Mirror Match" : "镜像对决"
        }
    }

    var icon: String {
        switch self {
        case .noBombs: return "nosign"
        case .halfGold: return "dollarsign.circle"
        case .extraPlays: return "hand.raised.fill"
        case .noDiscards: return "xmark.circle.fill"
        case .doubleScore: return "sparkles"
        case .speedRun: return "bolt.fill"
        case .bossRush: return "flame.fill"
        case .giantHand: return "hand.wave.fill"
        case .tinyDeck: return "rectangle.stack.fill"
        case .allOrNothing: return "target"
        case .goldRush: return "bitcoinsign.circle.fill"
        case .mirrorMatch: return "arrow.left.arrow.right"
        }
    }
}
