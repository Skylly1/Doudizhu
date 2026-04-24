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
    // 原始 10 种
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
    // 新增 10 种
    case pairMastery        // 成双成对: 对子得分×2
    case tripleThreat       // 三生万物: 三带类牌型+50%
    case goldRush           // 点石成金: 每次出牌额外获得 5 金币
    case secondWind         // 回光返照: 每关获得 1 次额外出牌机会
    case cardCounter        // 心算如飞: 出牌张数≥5时+40%
    case luckyDraw          // 锦鲤附体: 换牌后从牌堆最后取（底牌更好）
    case scoreSurge         // 厚积薄发: 当前层得分≥目标50%时+30%
    case miniHandBonus      // 精打细算: 出3张以下的牌型+60%
    case multiKill          // 连环杀: 连击≥3时额外+20%
    case shieldBreaker      // 破甲: 单次出牌≥100分时，下次出牌+25%
    // 第三批 10 种
    case criticalHit        // 暴击之手: 10%概率双倍得分
    case insurance          // 保险单: 失败时保留50%分数
    case collector          // 同花顺缘: 同花色5张+50分
    case nightOwl           // 夜枭: 后半程(8-15关)得分+20%
    case earlyBird          // 先声夺人: 每关第一手+100分
    case miser              // 守财奴: 每持有50金币+5%得分
    case gambler            // 赌徒之心: 随机±30%得分(期望+5%)
    case phoenix            // 浴火凤凰: 每局可复活一次
    case dragon             // 神龙摆尾: 连击达到5时下一手3倍
    case tideTurner         // 逆转乾坤: 得分<目标30%时+50%
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
        // ── 原始 10 张 ──
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
        // ── 新增 10 张 ──
        Joker(
            name: "成双成对",
            description: "对子得分×2",
            effect: .pairMastery,
            icon: "💕",
            rarity: .common
        ),
        Joker(
            name: "三生万物",
            description: "三带类牌型得分+50%",
            effect: .tripleThreat,
            icon: "🌀",
            rarity: .rare
        ),
        Joker(
            name: "点石成金",
            description: "每次出牌额外获得 5 金币",
            effect: .goldRush,
            icon: "💰",
            rarity: .rare
        ),
        Joker(
            name: "回光返照",
            description: "每关额外获得 1 次出牌机会",
            effect: .secondWind,
            icon: "💫",
            rarity: .legendary
        ),
        Joker(
            name: "心算如飞",
            description: "出牌≥5张时得分+40%",
            effect: .cardCounter,
            icon: "🧠",
            rarity: .rare
        ),
        Joker(
            name: "锦鲤附体",
            description: "换牌改从牌堆底部取（底牌运气更好）",
            effect: .luckyDraw,
            icon: "🐟",
            rarity: .common
        ),
        Joker(
            name: "厚积薄发",
            description: "当前层得分≥目标50%时，出牌+30%",
            effect: .scoreSurge,
            icon: "📈",
            rarity: .rare
        ),
        Joker(
            name: "精打细算",
            description: "出3张及以下的牌型+60%",
            effect: .miniHandBonus,
            icon: "🎯",
            rarity: .common
        ),
        Joker(
            name: "连环杀",
            description: "连击≥3时额外+20%加成",
            effect: .multiKill,
            icon: "⚡",
            rarity: .rare
        ),
        Joker(
            name: "破甲",
            description: "上次出牌≥100分时，本次+25%",
            effect: .shieldBreaker,
            icon: "🗡️",
            rarity: .legendary
        ),
        // ── 第三批 10 张 ──
        Joker(
            name: "暴击之手",
            description: "10%概率双倍得分",
            effect: .criticalHit,
            icon: "🎲",
            rarity: .rare
        ),
        Joker(
            name: "保险单",
            description: "失败时保留50%分数",
            effect: .insurance,
            icon: "🛡️",
            rarity: .rare
        ),
        Joker(
            name: "同花顺缘",
            description: "同花色出5张以上+50分",
            effect: .collector,
            icon: "🎴",
            rarity: .common
        ),
        Joker(
            name: "夜枭",
            description: "后半程(8-15关)得分+20%",
            effect: .nightOwl,
            icon: "🦉",
            rarity: .common
        ),
        Joker(
            name: "先声夺人",
            description: "每关第一手出牌+100分",
            effect: .earlyBird,
            icon: "🐦",
            rarity: .common
        ),
        Joker(
            name: "守财奴",
            description: "每持有50金币，得分+5%",
            effect: .miser,
            icon: "🏦",
            rarity: .rare
        ),
        Joker(
            name: "赌徒之心",
            description: "随机±30%得分（期望+5%）",
            effect: .gambler,
            icon: "🎰",
            rarity: .legendary
        ),
        Joker(
            name: "浴火凤凰",
            description: "每局游戏可复活一次",
            effect: .phoenix,
            icon: "🔥",
            rarity: .legendary
        ),
        Joker(
            name: "神龙摆尾",
            description: "连击达到5时，下一手3倍得分",
            effect: .dragon,
            icon: "🐉",
            rarity: .legendary
        ),
        Joker(
            name: "逆转乾坤",
            description: "得分低于目标30%时，出牌+50%",
            effect: .tideTurner,
            icon: "🌀",
            rarity: .rare
        ),
    ]
}
