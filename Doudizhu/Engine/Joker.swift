import Foundation

// MARK: - 规则牌（Joker）— 改变玩法规则的核心系统

/// 规则牌稀有度
enum JokerRarity: String, Codable, Hashable {
    case common    = "common"
    case rare      = "rare"
    case legendary = "legendary"

    var displayName: String {
        switch self {
        case .common:    return L10n.rarityCommon
        case .rare:      return L10n.rarityRare
        case .legendary: return L10n.rarityLegendary
        }
    }

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
            name: L10n.jokerGreedyName,
            description: L10n.jokerGreedyDesc,
            effect: .drawAfterPlay,
            icon: "👻",
            rarity: .common
        ),
        Joker(
            name: L10n.jokerChainPlotName,
            description: L10n.jokerChainPlotDesc,
            effect: .doubleComboRate,
            icon: "🔗",
            rarity: .rare
        ),
        Joker(
            name: L10n.jokerEmptyFortName,
            description: L10n.jokerEmptyFortDesc,
            effect: .lowHandBonus,
            icon: "🏯",
            rarity: .rare
        ),
        Joker(
            name: L10n.jokerFireBlazeName,
            description: L10n.jokerFireBlazeDesc,
            effect: .explosiveBonus,
            icon: "🔥",
            rarity: .common
        ),
        Joker(
            name: L10n.jokerRideWaveName,
            description: L10n.jokerRideWaveDesc,
            effect: .sequenceBonus,
            icon: "🌊",
            rarity: .common
        ),
        Joker(
            name: L10n.jokerSiegeName,
            description: L10n.jokerSiegeDesc,
            effect: .highCardBonus,
            icon: "⚔️",
            rarity: .rare
        ),
        Joker(
            name: L10n.jokerSecretPathName,
            description: L10n.jokerSecretPathDesc,
            effect: .extraDiscards,
            icon: "🌙",
            rarity: .common
        ),
        Joker(
            name: L10n.jokerThunderStrikeName,
            description: L10n.jokerThunderStrikeDesc,
            effect: .firstPlayBonus,
            icon: "⚡",
            rarity: .rare
        ),
        Joker(
            name: L10n.jokerSwitcherooName,
            description: L10n.jokerSwitcherooDesc,
            effect: .extraDrawOnDiscard,
            icon: "🎭",
            rarity: .common
        ),
        Joker(
            name: L10n.jokerLastStandName,
            description: L10n.jokerLastStandDesc,
            effect: .lastStandBonus,
            icon: "⛵",
            rarity: .legendary
        ),
        // ── 新增 10 张 ──
        Joker(
            name: L10n.jokerPairMasteryName,
            description: L10n.jokerPairMasteryDesc,
            effect: .pairMastery,
            icon: "💕",
            rarity: .common
        ),
        Joker(
            name: L10n.jokerTripleThreatName,
            description: L10n.jokerTripleThreatDesc,
            effect: .tripleThreat,
            icon: "🌀",
            rarity: .rare
        ),
        Joker(
            name: L10n.jokerGoldRushName,
            description: L10n.jokerGoldRushDesc,
            effect: .goldRush,
            icon: "💰",
            rarity: .rare
        ),
        Joker(
            name: L10n.jokerSecondWindName,
            description: L10n.jokerSecondWindDesc,
            effect: .secondWind,
            icon: "💫",
            rarity: .legendary
        ),
        Joker(
            name: L10n.jokerCardCounterName,
            description: L10n.jokerCardCounterDesc,
            effect: .cardCounter,
            icon: "🧠",
            rarity: .rare
        ),
        Joker(
            name: L10n.jokerLuckyDrawName,
            description: L10n.jokerLuckyDrawDesc,
            effect: .luckyDraw,
            icon: "🐟",
            rarity: .common
        ),
        Joker(
            name: L10n.jokerScoreSurgeName,
            description: L10n.jokerScoreSurgeDesc,
            effect: .scoreSurge,
            icon: "📈",
            rarity: .rare
        ),
        Joker(
            name: L10n.jokerMiniHandName,
            description: L10n.jokerMiniHandDesc,
            effect: .miniHandBonus,
            icon: "🎯",
            rarity: .common
        ),
        Joker(
            name: L10n.jokerMultiKillName,
            description: L10n.jokerMultiKillDesc,
            effect: .multiKill,
            icon: "⚡",
            rarity: .rare
        ),
        Joker(
            name: L10n.jokerShieldBreakerName,
            description: L10n.jokerShieldBreakerDesc,
            effect: .shieldBreaker,
            icon: "🗡️",
            rarity: .legendary
        ),
        // ── 第三批 10 张 ──
        Joker(
            name: L10n.jokerCriticalHitName,
            description: L10n.jokerCriticalHitDesc,
            effect: .criticalHit,
            icon: "🎲",
            rarity: .rare
        ),
        Joker(
            name: L10n.jokerInsuranceName,
            description: L10n.jokerInsuranceDesc,
            effect: .insurance,
            icon: "🛡️",
            rarity: .rare
        ),
        Joker(
            name: L10n.jokerCollectorName,
            description: L10n.jokerCollectorDesc,
            effect: .collector,
            icon: "🎴",
            rarity: .common
        ),
        Joker(
            name: L10n.jokerNightOwlName,
            description: L10n.jokerNightOwlDesc,
            effect: .nightOwl,
            icon: "🦉",
            rarity: .common
        ),
        Joker(
            name: L10n.jokerEarlyBirdName,
            description: L10n.jokerEarlyBirdDesc,
            effect: .earlyBird,
            icon: "🐦",
            rarity: .common
        ),
        Joker(
            name: L10n.jokerMiserName,
            description: L10n.jokerMiserDesc,
            effect: .miser,
            icon: "🏦",
            rarity: .rare
        ),
        Joker(
            name: L10n.jokerGamblerName,
            description: L10n.jokerGamblerDesc,
            effect: .gambler,
            icon: "🎰",
            rarity: .legendary
        ),
        Joker(
            name: L10n.jokerPhoenixName,
            description: L10n.jokerPhoenixDesc,
            effect: .phoenix,
            icon: "🔥",
            rarity: .legendary
        ),
        Joker(
            name: L10n.jokerDragonName,
            description: L10n.jokerDragonDesc,
            effect: .dragon,
            icon: "🐉",
            rarity: .legendary
        ),
        Joker(
            name: L10n.jokerTideTurnerName,
            description: L10n.jokerTideTurnerDesc,
            effect: .tideTurner,
            icon: "🌀",
            rarity: .rare
        ),
    ]
}
