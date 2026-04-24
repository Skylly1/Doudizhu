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

        // Rotate modifiers based on day of week
        let dayOfWeek = cal.component(.weekday, from: Date())
        let mods: [DailyChallengeModifier] = {
            switch dayOfWeek {
            case 1: return [.noBombs]           // Sunday: no bombs allowed
            case 2: return [.halfGold]           // Monday: start with half gold
            case 3: return [.extraPlays]         // Tuesday: +2 plays per floor
            case 4: return [.noDiscards]         // Wednesday: no discards
            case 5: return [.doubleScore]        // Thursday: 2x scoring
            case 6: return [.speedRun]           // Friday: 3 plays max per floor
            case 7: return [.bossRush]           // Saturday: every 3rd floor is boss
            default: return []
            }
        }()

        return DailyChallenge(date: Date(), seed: seed, modifiers: mods, bonusGold: 50)
    }

    /// Has today's challenge been attempted?
    static var hasPlayedToday: Bool {
        let key = "dailyChallengeDate"
        guard let lastDate = UserDefaults.standard.string(forKey: key) else { return false }
        let today = Self.todayString
        return lastDate == today
    }

    /// Record that today's challenge was attempted
    static func markPlayed() {
        UserDefaults.standard.set(todayString, forKey: "dailyChallengeDate")
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

    var name: String {
        switch self {
        case .noBombs: return L10n.isEnglish ? "No Bombs" : "禁止炸弹"
        case .halfGold: return L10n.isEnglish ? "Half Gold" : "金币减半"
        case .extraPlays: return L10n.isEnglish ? "Extra Plays" : "额外出牌"
        case .noDiscards: return L10n.isEnglish ? "No Discards" : "禁止换牌"
        case .doubleScore: return L10n.isEnglish ? "Double Score" : "双倍得分"
        case .speedRun: return L10n.isEnglish ? "Speed Run" : "极速挑战"
        case .bossRush: return L10n.isEnglish ? "Boss Rush" : "Boss连战"
        }
    }

    var icon: String {
        switch self {
        case .noBombs: return "💣"
        case .halfGold: return "💰"
        case .extraPlays: return "🃏"
        case .noDiscards: return "🚫"
        case .doubleScore: return "✨"
        case .speedRun: return "⚡"
        case .bossRush: return "⚔️"
        }
    }
}
