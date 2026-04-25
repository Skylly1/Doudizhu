import Foundation

/// Boss 关卡规则修改器 — 每个Boss有独特规则改变游戏策略
enum BossModifier: String, CaseIterable, Codable {
    case bannedPattern      // 禁用一种随机牌型
    case escalating         // 目标分数每次出牌后+5%
    case scoringDecay       // 每次出牌得分递减10%
    case timeLimit          // 无实际计时，但出牌次数-1
    case greedyTax          // 每次出牌扣10金币
    case noDiscard          // 禁止换牌（已由floor config的0弃牌实现，这里作为显示标记）
    case scoreCap           // 封顶令 — 单次出牌得分上限为目标分60%
    case handShrink         // 缩手缩脚 — 手牌减少2张（发8张而非10张）
    case jokerSilence       // 封印术 — 随机封印一张规则牌
    // 新增 6 种 Boss 修改器
    case blindDraw          // 盲抽 — 手牌全部面朝下，出牌后才能看到
    case pairTax            // 成双税 — 对子得分减半
    case comboBreaker       // 破连 — 无法累积连击
    case goldDrain          // 漏金 — 每回合自动扣 5 金币
    case reverseOrder       // 倒序 — 小牌得分更高，大牌得分降低
    case phantomCards       // 幻影牌 — 随机 2 张手牌无法被选中
    
    var systemIcon: String {
        switch self {
        case .bannedPattern:  return "scroll.fill"
        case .escalating:     return "crown.fill"
        case .scoringDecay:   return "flame.fill"
        case .timeLimit:      return "hourglass"
        case .greedyTax:      return "dollarsign.circle.fill"
        case .noDiscard:      return "nosign"
        case .scoreCap:       return "lock.fill"
        case .handShrink:     return "hand.raised.fill"
        case .jokerSilence:   return "speaker.slash.fill"
        case .blindDraw:      return "eye.slash.fill"
        case .pairTax:        return "equal.circle.fill"
        case .comboBreaker:   return "xmark.circle.fill"
        case .goldDrain:      return "drop.triangle.fill"
        case .reverseOrder:   return "arrow.up.arrow.down"
        case .phantomCards:   return "questionmark.circle.fill"
        }
    }
    
    var name: String {
        let isEn = L10n.isEnglish
        switch self {
        case .bannedPattern: return isEn ? "Imperial Ban" : "官府禁令"
        case .escalating:    return isEn ? "Royal Privilege" : "皇家特权"
        case .scoringDecay:  return isEn ? "Double Suppression" : "双重压制"
        case .timeLimit:     return isEn ? "Time Pressure" : "时不我待"
        case .greedyTax:     return isEn ? "Greed Tax" : "贪婪税"
        case .noDiscard:     return isEn ? "No Retreat" : "背水一战"
        case .scoreCap:      return isEn ? "Score Cap" : "封顶令"
        case .handShrink:    return isEn ? "Hand Shrink" : "缩手缩脚"
        case .jokerSilence:  return isEn ? "Joker Silence" : "封印术"
        case .blindDraw:     return isEn ? "Blind Draw" : "盲抽"
        case .pairTax:       return isEn ? "Pair Tax" : "成双税"
        case .comboBreaker:  return isEn ? "Combo Breaker" : "破连"
        case .goldDrain:     return isEn ? "Gold Drain" : "漏金"
        case .reverseOrder:  return isEn ? "Reverse Order" : "倒序乾坤"
        case .phantomCards:  return isEn ? "Phantom Cards" : "幻影牌"
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
        case .scoreCap:      return isEn ? "Single play score capped at 60% of target" : "单次出牌得分上限为目标分的60%"
        case .handShrink:    return isEn ? "Hand size reduced by 2 cards" : "手牌减少2张（发8张）"
        case .jokerSilence:  return isEn ? "One random Joker is silenced this floor" : "随机封印一张规则牌本关无效"
        case .blindDraw:     return isEn ? "Cards are face-down until played" : "手牌面朝下，出牌后才翻开"
        case .pairTax:       return isEn ? "Pairs score 50% less" : "对子得分减半"
        case .comboBreaker:  return isEn ? "Combo multiplier is disabled" : "无法累积连击加成"
        case .goldDrain:     return isEn ? "Lose 5 gold each turn" : "每回合自动扣5金币"
        case .reverseOrder:  return isEn ? "Lower ranks score higher, higher ranks score lower" : "小牌得分更高，大牌得分降低"
        case .phantomCards:  return isEn ? "2 random cards cannot be selected" : "随机2张手牌无法被选中"
        }
    }
}

/// 某一局Boss关的活跃修改器状态
struct BossState {
    let modifiers: [BossModifier]
    let bannedPatternType: PatternType?
    var escalationCount: Int = 0           // 已出牌次数（用于escalating计算）
    var decayCount: Int = 0                // 已出牌次数（用于scoringDecay计算）
    var silencedJokerIndex: Int?           // 被封印的规则牌索引（用于jokerSilence）
    var phantomCardIds: Set<UUID> = []     // 幻影牌ID集合（无法被选中）
    
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
