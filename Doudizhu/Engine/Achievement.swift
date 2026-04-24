import Foundation

// MARK: - 成就系统

struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: Int

    /// 成就分类
    enum Category: String, CaseIterable, Codable {
        case progress = "冒险"
        case scoring  = "得分"
        case mastery  = "精通"
        case style    = "风格"
    }

    let category: Category
}

// MARK: - 预设成就

extension Achievement {
    static let all: [Achievement] = [
        // 冒险
        Achievement(id: "first_win",       name: "初出茅庐",   description: "首次通关第1层",       icon: "🌱", requirement: 1, category: .progress),
        Achievement(id: "mid_run",         name: "渐入佳境",   description: "到达第5层",           icon: "⚔️", requirement: 5, category: .progress),
        Achievement(id: "full_clear",      name: "斗破乾坤",   description: "首次通关全部8层",      icon: "🏆", requirement: 8, category: .progress),
        Achievement(id: "games_10",        name: "常客",       description: "累计游戏10局",         icon: "🎮", requirement: 10, category: .progress),
        Achievement(id: "games_50",        name: "老牌手",     description: "累计游戏50局",         icon: "🃏", requirement: 50, category: .progress),

        // 得分
        Achievement(id: "score_500",       name: "小试牛刀",   description: "单局累计500分",        icon: "💯", requirement: 500, category: .scoring),
        Achievement(id: "score_2000",      name: "一骑当千",   description: "单局累计2000分",       icon: "🔥", requirement: 2000, category: .scoring),
        Achievement(id: "score_5000",      name: "登峰造极",   description: "单局累计5000分",       icon: "⭐", requirement: 5000, category: .scoring),
        Achievement(id: "single_200",      name: "一击必杀",   description: "单次出牌得分≥200",     icon: "💥", requirement: 200, category: .scoring),
        Achievement(id: "single_500",      name: "天崩地裂",   description: "单次出牌得分≥500",     icon: "☄️", requirement: 500, category: .scoring),

        // 精通
        Achievement(id: "combo_5",         name: "连击大师",   description: "达成5连击",            icon: "🔗", requirement: 5, category: .mastery),
        Achievement(id: "bombs_10",        name: "爆破专家",   description: "累计使用10次炸弹",     icon: "💣", requirement: 10, category: .mastery),
        Achievement(id: "rockets_5",       name: "火箭狂人",   description: "累计使用5次火箭",      icon: "🚀", requirement: 5, category: .mastery),
        Achievement(id: "jokers_collect_5", name: "规则收藏家", description: "单局装备5张规则牌",    icon: "🎴", requirement: 5, category: .mastery),

        // 风格
        Achievement(id: "no_discard_win",  name: "完美牌局",   description: "不换牌通过一层",       icon: "✨", requirement: 1, category: .style),
        Achievement(id: "gold_300",        name: "富甲一方",   description: "持有300+金币",         icon: "💰", requirement: 300, category: .style),
        Achievement(id: "wins_5",          name: "常胜将军",   description: "累计通关5次",           icon: "👑", requirement: 5, category: .style),
    ]
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
        return true
    }

    /// 清除最新解锁提示
    func dismissLatest() {
        latestUnlock = nil
    }

    var progress: (unlocked: Int, total: Int) {
        (unlockedIds.count, Achievement.all.count)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(unlockedIds) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
