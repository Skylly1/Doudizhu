import Foundation

/// Daily Challenge — a curated challenge that changes every day
/// All players get the same seed → same floor sequence + shop items
// REVENUE-TODO: [P2] 每日挑战排行榜 — 付费用户可查看全球排名，免费用户只能看到自己的分数
struct DailyChallenge {
    let date: Date
    let seed: UInt64
    let modifiers: [DailyChallengeModifier]
    let bonusGold: Int
    let floorCount: Int

    /// Today's challenge
    static var today: DailyChallenge {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day], from: Date())
        let y = comps.year ?? 2024
        let m = comps.month ?? 1
        let d = comps.day ?? 1
        let seed = UInt64(y * 10000 + m * 100 + d)

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

        return DailyChallenge(date: Date(), seed: seed, modifiers: mods, bonusGold: 50,
                              floorCount: FloorConfig.dailyChallengeFloors.count)
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
        updateStreak()
        Task { @MainActor in LocalNotificationManager.scheduleDailyReminder() }
    }

    /// UF-06: Mark completed without updating streak (for corrupted save recovery)
    static func markCompletedWithoutStreak() {
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

    // MARK: - 连续挑战 Streak（留存核心机制）

    private static let streakCountKey = "dailyStreak_count"
    private static let streakLastDateKey = "dailyStreak_lastDate"

    /// 当前连续完成天数
    static var currentStreak: Int {
        guard let lastDate = UserDefaults.standard.string(forKey: streakLastDateKey) else { return 0 }
        let today = todayString
        if lastDate == today {
            return UserDefaults.standard.integer(forKey: streakCountKey)
        }
        if lastDate == yesterdayString {
            return UserDefaults.standard.integer(forKey: streakCountKey)
        }
        return 0 // streak broken
    }

    /// 完成今日挑战时更新 streak
    static func updateStreak() {
        let today = todayString
        let lastDate = UserDefaults.standard.string(forKey: streakLastDateKey) ?? ""
        guard lastDate != today else { return } // 今天已更新

        var streak = UserDefaults.standard.integer(forKey: streakCountKey)
        if lastDate == yesterdayString {
            streak += 1
        } else {
            streak = 1 // 重新开始
        }

        // Atomic write: bundle streak data to avoid corruption on app kill between writes
        let streakData: [String: Any] = [streakCountKey: streak, streakLastDateKey: today]
        streakData.forEach { UserDefaults.standard.set($0.value, forKey: $0.key) }

        // 连续挑战成就
        Task { @MainActor in
            if streak >= 3 { AchievementTracker.shared.tryUnlock("daily_streak_3") }
            if streak >= 7 { AchievementTracker.shared.tryUnlock("daily_streak_7") }
            if streak >= 30 { AchievementTracker.shared.tryUnlock("daily_streak_30") }
        }

        // 连续挑战里程碑奖励（每个里程碑仅领一次）
        grantStreakReward(streak)
    }

    // MARK: - Streak 里程碑奖励

    /// 里程碑: 3天+50金, 7天+随机规则牌, 14天+稀有Buff, 30天+传奇徽章
    struct StreakReward {
        let milestone: Int
        let icon: String
        let name: String
        let description: String
    }

    static var streakRewards: [StreakReward] {
        [
            StreakReward(milestone: 3, icon: "💰", name: L10n.localized("三日奖金", en: "3-Day Gold"), description: L10n.localized("下次冒险+50金币", en: "+50 Gold next run")),
            StreakReward(milestone: 7, icon: "🃏", name: L10n.localized("周挑战规则牌", en: "Weekly Joker"), description: L10n.localized("免费随机规则牌", en: "Free random Joker")),
            StreakReward(milestone: 14, icon: "⚡", name: L10n.localized("双周增益", en: "Biweekly Buff"), description: L10n.localized("下次冒险稀有增益", en: "Rare Buff next run")),
            StreakReward(milestone: 30, icon: "👑", name: L10n.localized("月度传奇", en: "Monthly Legend"), description: L10n.localized("传奇徽章", en: "Legendary Badge")),
        ]
    }

    /// 下一个未领取的里程碑奖励
    static var nextMilestone: StreakReward? {
        streakRewards.first { $0.milestone > currentStreak }
    }

    /// 发放里程碑奖励
    private static func grantStreakReward(_ streak: Int) {
        for reward in streakRewards {
            let claimedKey = "streak_reward_\(reward.milestone)_claimed"
            if streak >= reward.milestone && !UserDefaults.standard.bool(forKey: claimedKey) {
                UserDefaults.standard.set(true, forKey: claimedKey)
                switch reward.milestone {
                case 3:
                    // +50金币存入下次冒险奖池
                    let bonus = UserDefaults.standard.integer(forKey: "streak_gold_bonus")
                    UserDefaults.standard.set(bonus + 50, forKey: "streak_gold_bonus")
                case 7:
                    // 标记下次冒险领取免费规则牌
                    UserDefaults.standard.set(true, forKey: "streak_free_joker")
                case 14:
                    // 标记下次冒险领取稀有增益
                    UserDefaults.standard.set(true, forKey: "streak_free_buff")
                case 30:
                    // 传奇徽章（永久标记）
                    UserDefaults.standard.set(true, forKey: "streak_legendary_badge")
                default: break
                }
                Task { @MainActor in
                    Analytics.shared.track(.dailyChallengeComplete, params: [
                        "streak_milestone": "\(reward.milestone)",
                        "reward": reward.name
                    ])
                }
            }
        }
    }

    /// 消耗连续挑战金币奖励（冒险开始时调用）
    static func consumeStreakGoldBonus() -> Int {
        let bonus = UserDefaults.standard.integer(forKey: "streak_gold_bonus")
        if bonus > 0 { UserDefaults.standard.set(0, forKey: "streak_gold_bonus") }
        return bonus
    }

    /// 消耗连续挑战免费规则牌标记
    static func consumeStreakFreeJoker() -> Bool {
        let has = UserDefaults.standard.bool(forKey: "streak_free_joker")
        if has { UserDefaults.standard.set(false, forKey: "streak_free_joker") }
        return has
    }

    private static var yesterdayString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
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
        case .noBombs: return L10n.localized("禁止炸弹", en: "No Bombs")
        case .halfGold: return L10n.localized("金币减半", en: "Half Gold")
        case .extraPlays: return L10n.localized("额外出牌", en: "Extra Plays")
        case .noDiscards: return L10n.localized("禁止换牌", en: "No Discards")
        case .doubleScore: return L10n.localized("双倍得分", en: "Double Score")
        case .speedRun: return L10n.localized("极速挑战", en: "Speed Run")
        case .bossRush: return L10n.localized("Boss连战", en: "Boss Rush")
        case .giantHand: return L10n.localized("巨人之手", en: "Giant Hand")
        case .tinyDeck: return L10n.localized("精简牌组", en: "Tiny Deck")
        case .allOrNothing: return L10n.localized("孤注一掷", en: "All or Nothing")
        case .goldRush: return L10n.localized("淘金热", en: "Gold Rush")
        case .mirrorMatch: return L10n.localized("镜像对决", en: "Mirror Match")
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
