import Foundation

/// Boss 关卡规则修改器 — 每个Boss有独特规则改变游戏策略
enum BossModifier: String, CaseIterable, Codable {
    case bannedPattern      // 禁用一种随机牌型
    case escalating         // 目标分数每次出牌后+5%
    case scoringDecay       // 每次出牌得分递减10%
    case timeLimit          // 无实际计时，但出牌次数-1
    case greedyTax          // 每次出牌扣10金币
    case noDiscard          // 禁止换牌（已由floor config的0弃牌实现，这里作为显示标记）
    
    var name: String {
        let isEn = L10n.isEnglish
        switch self {
        case .bannedPattern: return isEn ? "📜 Imperial Ban" : "📜 官府禁令"
        case .escalating:    return isEn ? "👑 Royal Privilege" : "👑 皇家特权"
        case .scoringDecay:  return isEn ? "🔥 Double Suppression" : "🔥 双重压制"
        case .timeLimit:     return isEn ? "⏳ Time Pressure" : "⏳ 时不我待"
        case .greedyTax:     return isEn ? "💰 Greed Tax" : "💰 贪婪税"
        case .noDiscard:     return isEn ? "🚫 No Retreat" : "🚫 背水一战"
        }
    }
    
    var description: String {
        let isEn = L10n.isEnglish
        switch self {
        case .bannedPattern: return isEn ? "One random pattern type is banned" : "禁用一种随机牌型（顺子/炸弹/飞机三选一）"
        case .escalating:    return isEn ? "Target score increases 5% after each play" : "目标分数每次出牌后增加5%"
        case .scoringDecay:  return isEn ? "Each play scores 10% less than the previous" : "每次出牌后，下次出牌得分-10%"
        case .timeLimit:     return isEn ? "1 fewer play than normal" : "出牌次数比正常少1次"
        case .greedyTax:     return isEn ? "Each play costs 10 gold" : "每次出牌扣10金币"
        case .noDiscard:     return isEn ? "Cannot swap cards this floor" : "本关无法换牌"
        }
    }
}

/// 某一局Boss关的活跃修改器状态
struct BossState {
    let modifiers: [BossModifier]
    let bannedPatternType: PatternType?
    var escalationCount: Int = 0           // 已出牌次数（用于escalating计算）
    var decayCount: Int = 0                // 已出牌次数（用于scoringDecay计算）
    
    init(modifiers: [BossModifier]) {
        self.modifiers = modifiers
        // 如果有禁令修改器，随机选一个牌型禁用
        if modifiers.contains(.bannedPattern) {
            let bannable: [PatternType] = [.straight, .bomb, .plane]
            bannedPatternType = bannable.randomElement()
        } else {
            bannedPatternType = nil
        }
    }
    
    var hasBannedPattern: Bool { modifiers.contains(.bannedPattern) }
    var hasEscalating: Bool { modifiers.contains(.escalating) }
    var hasScoringDecay: Bool { modifiers.contains(.scoringDecay) }
    var hasGreedyTax: Bool { modifiers.contains(.greedyTax) }
}
