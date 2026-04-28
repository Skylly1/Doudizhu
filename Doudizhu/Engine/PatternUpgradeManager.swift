import Foundation

// MARK: - 牌型升级系统（Meta Progression）

/// 管理每种牌型的永久升级等级，提供额外 chips/mult 加成
@MainActor
final class PatternUpgradeManager: ObservableObject {
    static let shared = PatternUpgradeManager()

    /// 每种牌型的升级等级（0 = 未升级）
    @Published var levels: [PatternType: Int] = [:]

    private let storageKey = "pattern_upgrade_levels"

    private init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([String: Int].self, from: data) {
            var result: [PatternType: Int] = [:]
            for (key, val) in saved {
                if let pt = PatternType(rawValue: key) {
                    result[pt] = val
                }
            }
            levels = result
        }
    }

    // MARK: - 查询

    /// 升级提供的额外 chips 加成
    func chipBonus(for type: PatternType) -> Int {
        let level = levels[type] ?? 0
        return level * 5  // 每级 +5 chips
    }

    /// 升级提供的额外 mult 加成
    func multBonus(for type: PatternType) -> Double {
        let level = levels[type] ?? 0
        return Double(level) * 0.2  // 每级 +0.2 mult
    }

    /// 获取当前升级等级
    func level(for type: PatternType) -> Int {
        levels[type] ?? 0
    }

    /// 升级所需金币
    func upgradeCost(for type: PatternType) -> Int {
        let currentLevel = levels[type] ?? 0
        return 50 + currentLevel * 30  // 50, 80, 110, ...
    }

    /// 是否还能继续升级
    func canUpgrade(_ type: PatternType) -> Bool {
        (levels[type] ?? 0) < Self.maxLevel
    }

    /// 最大等级
    static let maxLevel = 5
    /// 每级增加的 chips
    static let chipPerLevel = 5
    /// 每级增加的 mult
    static let multPerLevel = 0.2

    // MARK: - 修改

    /// 升级牌型（返回是否成功）
    @discardableResult
    func upgrade(_ type: PatternType) -> Bool {
        let current = levels[type] ?? 0
        guard current < Self.maxLevel else { return false }
        levels[type] = current + 1
        save()
        return true
    }

    /// 重置所有升级（调试用）
    func resetAll() {
        levels.removeAll()
        save()
    }

    // MARK: - 持久化

    private func save() {
        var dict: [String: Int] = [:]
        for (key, val) in levels {
            dict[key.rawValue] = val
        }
        if let data = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
