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
        switch self {
        case .bannedPattern: return "📜 官府禁令"
        case .escalating:    return "👑 皇家特权"
        case .scoringDecay:  return "🔥 双重压制"
        case .timeLimit:     return "⏳ 时不我待"
        case .greedyTax:     return "💰 贪婪税"
        case .noDiscard:     return "🚫 背水一战"
        }
    }
    
    var description: String {
        switch self {
        case .bannedPattern: return "禁用一种随机牌型（顺子/炸弹/飞机三选一）"
        case .escalating:    return "目标分数每次出牌后增加5%"
        case .scoringDecay:  return "每次出牌后，下次出牌得分-10%"
        case .timeLimit:     return "出牌次数比正常少1次"
        case .greedyTax:     return "每次出牌扣10金币"
        case .noDiscard:     return "本关无法换牌"
        }
    }
    
    var nameEN: String {
        switch self {
        case .bannedPattern: return "📜 Imperial Ban"
        case .escalating:    return "👑 Royal Privilege"
        case .scoringDecay:  return "🔥 Double Suppression"
        case .timeLimit:     return "⏳ Time Pressure"
        case .greedyTax:     return "💰 Greed Tax"
        case .noDiscard:     return "🚫 No Retreat"
        }
    }
    
    var descriptionEN: String {
        switch self {
        case .bannedPattern: return "One random pattern type is banned"
        case .escalating:    return "Target score increases 5% after each play"
        case .scoringDecay:  return "Each play scores 10% less than the previous"
        case .timeLimit:     return "1 fewer play than normal"
        case .greedyTax:     return "Each play costs 10 gold"
        case .noDiscard:     return "Cannot swap cards this floor"
        }
    }
}

/// 某一局Boss关的活跃修改器状态
class BossState: @unchecked Sendable {
    var modifiers: [BossModifier]
    var bannedPatternType: PatternType?   // 被禁用的牌型（如果有bannedPattern修改器）
    var escalationCount: Int = 0           // 已出牌次数（用于escalating计算）
    var decayCount: Int = 0                // 已出牌次数（用于scoringDecay计算）
    
    init(modifiers: [BossModifier]) {
        self.modifiers = modifiers
        // 如果有禁令修改器，随机选一个牌型禁用
        if modifiers.contains(.bannedPattern) {
            let bannable: [PatternType] = [.straight, .bomb, .plane]
            bannedPatternType = bannable.randomElement()
        }
    }
    
    var hasBannedPattern: Bool { modifiers.contains(.bannedPattern) }
    var hasEscalating: Bool { modifiers.contains(.escalating) }
    var hasScoringDecay: Bool { modifiers.contains(.scoringDecay) }
    var hasGreedyTax: Bool { modifiers.contains(.greedyTax) }
}
