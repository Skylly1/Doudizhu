import Foundation

// MARK: - 成就系统
// REVENUE-TODO: [P2] 加入「成就展示柜」— 付费用户可在主页展示已解锁成就徽章（社交货币→口碑传播）
// REVENUE-TODO: [P3] 部分高阶成就仅付费用户可解锁 — 激励免费用户升级

struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: Int

    /// 成就分类
    enum Category: String, CaseIterable, Codable {
        case progress = "progress"
        case scoring  = "scoring"
        case mastery  = "mastery"
        case style    = "style"

        var displayName: String {
            switch self {
            case .progress: return L10n.isEnglish ? "Adventure" : "冒险"
            case .scoring:  return L10n.isEnglish ? "Scoring" : "得分"
            case .mastery:  return L10n.isEnglish ? "Mastery" : "精通"
            case .style:    return L10n.isEnglish ? "Style" : "风格"
            }
        }
    }

    let category: Category
}

// MARK: - 预设成就

extension Achievement {
    static let all: [Achievement] = [
        // 冒险
        Achievement(id: "first_win",       name: L10n.achievementFirstWinName,       description: L10n.achievementFirstWinDesc,       icon: "leaf.fill", requirement: 1, category: .progress),
        Achievement(id: "mid_run",         name: L10n.achievementMidRunName,         description: L10n.achievementMidRunDesc,         icon: "bolt.shield.fill", requirement: 5, category: .progress),
        Achievement(id: "full_clear",      name: L10n.achievementFullClearName,      description: L10n.achievementFullClearDesc,      icon: "trophy.fill", requirement: 15, category: .progress),
        Achievement(id: "games_10",        name: L10n.achievementGames10Name,        description: L10n.achievementGames10Desc,        icon: "gamecontroller.fill", requirement: 10, category: .progress),
        Achievement(id: "games_50",        name: L10n.achievementGames50Name,        description: L10n.achievementGames50Desc,        icon: "suit.spade.fill", requirement: 50, category: .progress),

        // 得分
        Achievement(id: "score_500",       name: L10n.achievementScore500Name,       description: L10n.achievementScore500Desc,       icon: "chart.line.uptrend.xyaxis", requirement: 500, category: .scoring),
        Achievement(id: "score_2000",      name: L10n.achievementScore2000Name,      description: L10n.achievementScore2000Desc,      icon: "flame.fill", requirement: 2000, category: .scoring),
        Achievement(id: "score_5000",      name: L10n.achievementScore5000Name,      description: L10n.achievementScore5000Desc,      icon: "star.fill", requirement: 5000, category: .scoring),
        Achievement(id: "single_200",      name: L10n.achievementSingle200Name,      description: L10n.achievementSingle200Desc,      icon: "burst.fill", requirement: 200, category: .scoring),
        Achievement(id: "single_500",      name: L10n.achievementSingle500Name,      description: L10n.achievementSingle500Desc,      icon: "sparkle", requirement: 500, category: .scoring),

        // 精通
        Achievement(id: "combo_5",         name: L10n.achievementCombo5Name,         description: L10n.achievementCombo5Desc,         icon: "link", requirement: 5, category: .mastery),
        Achievement(id: "bombs_10",        name: L10n.achievementBombs10Name,        description: L10n.achievementBombs10Desc,        icon: "circle.circle.fill", requirement: 10, category: .mastery),
        Achievement(id: "rockets_5",       name: L10n.achievementRockets5Name,       description: L10n.achievementRockets5Desc,       icon: "arrow.up.circle.fill", requirement: 5, category: .mastery),
        Achievement(id: "jokers_collect_5", name: L10n.achievementJokersCollect5Name, description: L10n.achievementJokersCollect5Desc, icon: "rectangle.stack.fill", requirement: 5, category: .mastery),

        // 风格
        Achievement(id: "no_discard_win",  name: L10n.achievementNoDiscardWinName,   description: L10n.achievementNoDiscardWinDesc,   icon: "sparkles", requirement: 1, category: .style),
        Achievement(id: "gold_300",        name: L10n.achievementGold300Name,        description: L10n.achievementGold300Desc,        icon: "dollarsign.circle.fill", requirement: 300, category: .style),
        Achievement(id: "wins_5",          name: L10n.achievementWins5Name,          description: L10n.achievementWins5Desc,          icon: "crown.fill", requirement: 5, category: .style),

        // 挑战等级
        Achievement(id: "ascension_1",     name: L10n.achievementAscension1Name,     description: L10n.achievementAscension1Desc,     icon: "arrow.up.circle.fill", requirement: 1, category: .progress),
        Achievement(id: "ascension_5",     name: L10n.achievementAscension5Name,     description: L10n.achievementAscension5Desc,     icon: "arrow.up.forward.circle.fill", requirement: 5, category: .progress),
        Achievement(id: "ascension_10",    name: L10n.achievementAscension10Name,    description: L10n.achievementAscension10Desc,    icon: "seal.fill", requirement: 10, category: .progress),

        // 每日挑战
        Achievement(id: "daily_streak_3",  name: L10n.achievementDailyStreak3Name,   description: L10n.achievementDailyStreak3Desc,   icon: "flame.fill", requirement: 3, category: .mastery),
        Achievement(id: "daily_streak_7",  name: L10n.achievementDailyStreak7Name,   description: L10n.achievementDailyStreak7Desc,   icon: "flame.circle.fill", requirement: 7, category: .mastery),
        Achievement(id: "daily_streak_30", name: L10n.achievementDailyStreak30Name,  description: L10n.achievementDailyStreak30Desc,  icon: "calendar.badge.checkmark", requirement: 30, category: .mastery),

        // 构筑精通
        Achievement(id: "builds_3",        name: L10n.achievementBuilds3Name,        description: L10n.achievementBuilds3Desc,        icon: "square.stack.3d.up.fill", requirement: 3, category: .style),
        Achievement(id: "builds_9",        name: L10n.achievementBuilds9Name,        description: L10n.achievementBuilds9Desc,        icon: "star.circle.fill", requirement: 9, category: .style),

        // 牌型精通
        Achievement(id: "straights_20",    name: L10n.achievementStraights20Name,    description: L10n.achievementStraights20Desc,    icon: "arrow.right.circle.fill", requirement: 20, category: .mastery),
        Achievement(id: "bombs_50",        name: L10n.achievementBombs50Name,        description: L10n.achievementBombs50Desc,        icon: "circle.circle.fill", requirement: 50, category: .mastery),

        // 得分里程碑
        Achievement(id: "score_10000",     name: L10n.achievementScore10000Name,     description: L10n.achievementScore10000Desc,     icon: "star.square.fill", requirement: 10000, category: .scoring),
        Achievement(id: "single_1000",     name: L10n.achievementSingle1000Name,     description: L10n.achievementSingle1000Desc,     icon: "wand.and.stars", requirement: 1000, category: .scoring),
    ]

    /// 成就分类对应的图标颜色
    var iconColor: (icon: String, color: String) {
        switch category {
        case .progress: return (icon, "cyan")
        case .scoring:  return (icon, "gold")
        case .mastery:  return (icon, "flame")
        case .style:    return (icon, "legendary")
        }
    }
}

// MARK: - 成就追踪器

/// 成就追踪器
@MainActor final class AchievementTracker: ObservableObject {
    static let shared = AchievementTracker()

    @Published var unlockedIds: Set<String> = []
    @Published var latestUnlock: Achievement? = nil

    private let key = "unlocked_achievements"

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            unlockedIds = ids
        }
    }

    func isUnlocked(_ id: String) -> Bool {
        unlockedIds.contains(id)
    }

    /// 尝试解锁成就，返回是否新解锁
    @discardableResult
    func tryUnlock(_ id: String) -> Bool {
        guard !unlockedIds.contains(id) else { return false }
        unlockedIds.insert(id)
        save()
        if let ach = Achievement.all.first(where: { $0.id == id }) {
            latestUnlock = ach
        }

        // Joker tier unlocks
        if id == "full_clear" || id == "mid_run" {
            JokerUnlockManager.unlockAllRare()
        }
        if id == "full_clear" {
            JokerUnlockManager.unlockAllLegendary()
        }

        ReviewManager.recordAchievementUnlocked()

        return true
    }

    /// 清除最新解锁提示
    func dismissLatest() {
        latestUnlock = nil
    }

    var progress: (unlocked: Int, total: Int) {
        (unlockedIds.count, Achievement.all.count)
    }

    /// 重置所有成就进度
    func resetAll() {
        unlockedIds.removeAll()
        latestUnlock = nil
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(unlockedIds) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
