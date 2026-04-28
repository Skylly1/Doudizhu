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
        Achievement(id: "first_win",       name: "初出茅庐",   description: "首次通关第1层",       icon: "leaf.fill", requirement: 1, category: .progress),
        Achievement(id: "mid_run",         name: "渐入佳境",   description: "到达第5层",           icon: "bolt.shield.fill", requirement: 5, category: .progress),
        Achievement(id: "full_clear",      name: "斗破乾坤",   description: "首次通关全部关卡",      icon: "trophy.fill", requirement: 15, category: .progress),
        Achievement(id: "games_10",        name: "常客",       description: "累计游戏10局",         icon: "gamecontroller.fill", requirement: 10, category: .progress),
        Achievement(id: "games_50",        name: "老牌手",     description: "累计游戏50局",         icon: "suit.spade.fill", requirement: 50, category: .progress),

        // 得分
        Achievement(id: "score_500",       name: "小试牛刀",   description: "单局累计500分",        icon: "chart.line.uptrend.xyaxis", requirement: 500, category: .scoring),
        Achievement(id: "score_2000",      name: "一骑当千",   description: "单局累计2000分",       icon: "flame.fill", requirement: 2000, category: .scoring),
        Achievement(id: "score_5000",      name: "登峰造极",   description: "单局累计5000分",       icon: "star.fill", requirement: 5000, category: .scoring),
        Achievement(id: "single_200",      name: "一击必杀",   description: "单次出牌得分≥200",     icon: "burst.fill", requirement: 200, category: .scoring),
        Achievement(id: "single_500",      name: "天崩地裂",   description: "单次出牌得分≥500",     icon: "sparkle", requirement: 500, category: .scoring),

        // 精通
        Achievement(id: "combo_5",         name: "连击大师",   description: "达成5连击",            icon: "link", requirement: 5, category: .mastery),
        Achievement(id: "bombs_10",        name: "爆破专家",   description: "累计使用10次炸弹",     icon: "circle.circle.fill", requirement: 10, category: .mastery),
        Achievement(id: "rockets_5",       name: "火箭狂人",   description: "累计使用5次火箭",      icon: "arrow.up.circle.fill", requirement: 5, category: .mastery),
        Achievement(id: "jokers_collect_5", name: "规则收藏家", description: "单局装备5张规则牌",    icon: "rectangle.stack.fill", requirement: 5, category: .mastery),

        // 风格
        Achievement(id: "no_discard_win",  name: "完美牌局",   description: "不换牌通过一层",       icon: "sparkles", requirement: 1, category: .style),
        Achievement(id: "gold_300",        name: "富甲一方",   description: "持有300+金币",         icon: "dollarsign.circle.fill", requirement: 300, category: .style),
        Achievement(id: "wins_5",          name: "常胜将军",   description: "累计通关5次",           icon: "crown.fill", requirement: 5, category: .style),

        // 挑战等级
        Achievement(id: "ascension_1",     name: "初入挑战",   description: "达到挑战等级1",         icon: "arrow.up.circle.fill", requirement: 1, category: .progress),
        Achievement(id: "ascension_5",     name: "挑战强者",   description: "达到挑战等级5",         icon: "arrow.up.forward.circle.fill", requirement: 5, category: .progress),
        Achievement(id: "ascension_10",    name: "绝世高手",   description: "达到挑战等级10",        icon: "seal.fill", requirement: 10, category: .progress),

        // 每日挑战
        Achievement(id: "daily_streak_3",  name: "三日不辍",   description: "每日挑战连续3天",       icon: "flame.fill", requirement: 3, category: .mastery),
        Achievement(id: "daily_streak_7",  name: "周周坚持",   description: "每日挑战连续7天",       icon: "flame.circle.fill", requirement: 7, category: .mastery),
        Achievement(id: "daily_streak_30", name: "月度传奇",   description: "每日挑战连续30天",      icon: "calendar.badge.checkmark", requirement: 30, category: .mastery),

        // 构筑精通
        Achievement(id: "builds_3",        name: "多面手",     description: "使用3种不同构筑通关",    icon: "square.stack.3d.up.fill", requirement: 3, category: .style),
        Achievement(id: "builds_9",        name: "全能大师",   description: "使用所有9种构筑通关",    icon: "star.circle.fill", requirement: 9, category: .style),

        // 牌型精通
        Achievement(id: "straights_20",    name: "顺子达人",   description: "累计打出20次顺子",      icon: "arrow.right.circle.fill", requirement: 20, category: .mastery),
        Achievement(id: "bombs_50",        name: "炸弹狂魔",   description: "累计使用50次炸弹",      icon: "circle.circle.fill", requirement: 50, category: .mastery),

        // 得分里程碑
        Achievement(id: "score_10000",     name: "万分俱乐部", description: "单局累计10000分",       icon: "star.square.fill", requirement: 10000, category: .scoring),
        Achievement(id: "single_1000",     name: "毁天灭地",   description: "单次出牌得分≥1000",     icon: "wand.and.stars", requirement: 1000, category: .scoring),
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
