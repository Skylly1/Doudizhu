import Foundation

// MARK: - 规则牌（Joker）— 改变玩法规则的核心系统

/// 规则牌稀有度
enum JokerRarity: String, Codable, Hashable {
    case common    = "普通"
    case rare      = "稀有"
    case legendary = "传说"

    var color: String {
        switch self {
        case .common:    return "green"
        case .rare:      return "blue"
        case .legendary: return "purple"
        }
    }
}

/// 规则牌效果类型
enum JokerEffect: String, Codable, Hashable {
    case drawAfterPlay      // 贪心鬼: 出牌后从牌堆抽1张
    case doubleComboRate    // 连环计: 连击加成翻倍 (15%→30%/级)
    case lowHandBonus       // 空城计: 手牌≤5张时得分×1.5
    case explosiveBonus     // 火烧连营: 炸弹/火箭得分×2
    case sequenceBonus      // 顺势而为: 顺子/连对得分×2
    case highCardBonus      // 四面楚歌: 手牌中每张2或A，得分+10%
    case extraDiscards      // 暗度陈仓: 每关换牌次数+2
    case firstPlayBonus     // 一鸣惊人: 每关第一次出牌得分×2.5
    case extraDrawOnDiscard // 偷梁换柱: 换牌时多抽1张
    case lastStandBonus     // 破釜沉舟: 最后1次出牌机会时得分×3
}

/// 规则牌
struct Joker: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let effect: JokerEffect
    let icon: String
    let rarity: JokerRarity

    init(name: String, description: String, effect: JokerEffect, icon: String, rarity: JokerRarity = .common) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.effect = effect
        self.icon = icon
        self.rarity = rarity
    }
}

// MARK: - 最大装备数

extension Joker {
    static let maxSlots = 5
}

// MARK: - 预设规则牌库

extension Joker {
    static let allJokers: [Joker] = [
        Joker(
            name: "贪心鬼",
            description: "出牌后从牌堆额外抽1张牌",
            effect: .drawAfterPlay,
            icon: "👻",
            rarity: .common
        ),
        Joker(
            name: "连环计",
            description: "连击加成翻倍（15%→30%/级）",
            effect: .doubleComboRate,
            icon: "🔗",
            rarity: .rare
        ),
        Joker(
            name: "空城计",
            description: "手牌≤5张时，所有得分×1.5",
            effect: .lowHandBonus,
            icon: "🏯",
            rarity: .rare
        ),
        Joker(
            name: "火烧连营",
            description: "炸弹和火箭得分×2",
            effect: .explosiveBonus,
            icon: "🔥",
            rarity: .common
        ),
        Joker(
            name: "顺势而为",
            description: "顺子和连对得分×2",
            effect: .sequenceBonus,
            icon: "🌊",
            rarity: .common
        ),
        Joker(
            name: "四面楚歌",
            description: "手牌中每张2或A，得分+10%",
            effect: .highCardBonus,
            icon: "⚔️",
            rarity: .rare
        ),
        Joker(
            name: "暗度陈仓",
            description: "每关换牌次数+2",
            effect: .extraDiscards,
            icon: "🌙",
            rarity: .common
        ),
        Joker(
            name: "一鸣惊人",
            description: "每关第一次出牌得分×2.5",
            effect: .firstPlayBonus,
            icon: "⚡",
            rarity: .rare
        ),
        Joker(
            name: "偷梁换柱",
            description: "换牌时多抽1张牌",
            effect: .extraDrawOnDiscard,
            icon: "🎭",
            rarity: .common
        ),
        Joker(
            name: "破釜沉舟",
            description: "最后1次出牌机会时得分×3",
            effect: .lastStandBonus,
            icon: "⛵",
            rarity: .legendary
        ),
    ]
}
