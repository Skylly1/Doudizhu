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
    // 引擎 Jokers (Legendary)
    case shadowClone        // 影分身: Every play counts as 2 combos
    case cosmicShift        // 乾坤大挪移: Swap chips and mult values
    case infiniteLoop       // 无限循环: If exactly 0 cards left after play, refill hand from draw pile
    case bloodPact          // 血契: +3.0 mult but hand size permanently -1
    case fortuneWheel       // 命运之轮: Each Joker slot adds +0.5 mult
    // 第五批 10 种 — 高级策略
    case bombChain          // 连锁爆破: 炸弹后下一手+50%
    case handOverflow       // 爆手牌: 手牌>8张时+20%
    case patternVariety     // 博采众长: 本层使用过3+种不同牌型后+30%
    case goldConverter      // 金石为开: 每50金币转化+15筹码
    case trashToTreasure    // 化腐为奇: 弃牌后下一手+40%
    case kingSlayer         // 弑君者: 包含K的牌型+25%
    case aceHigh            // 以A为尊: 包含A的牌型+20筹码
    case planeBonus         // 展翅高飞: 飞机类牌型+80%
    case straightFlush      // 同花连珠: 顺子且同花色时×3
    case endgameSurge       // 终局冲刺: 最后2次出牌机会+40%
    // 第六批 15 种 — 牌面/花色策略
    case heartCollector     // 红心猎手: 含♥牌时+0.3 mult
    case spadeEdge          // 黑锋之刃: 含♠牌时+15 chips
    case diamondMiner       // 钻石矿工: 含♦牌时过关额外+10金币
    case clubShield         // 梅花护盾: 含♣牌时弃牌不减combo
    case fullHouse          // 满堂红: 三带二+1.0 mult
    case smallBlind         // 小盲注: 第2关前+50% mult
    case bigBlind           // 大盲注: 第8关后+0.6 mult
    case recycler           // 回收大师: 弃牌时每张+5 chips到下一手
    case perfectHand        // 完美之手: 出5张牌且全部同花色时×4
    case doubleDown         // 加倍下注: 连续出相同牌型时+0.5 mult
    case jokerStacker       // 叠叠乐: 每多1张Joker, chips+10
    case goldDigger         // 掘金者: 金币≥100时+1.0 mult
    case mirrorImage        // 镜像: 对子牌型 chips 翻倍
    case chainLightning     // 连锁闪电: combo≥4时全牌型+0.6 mult
    case zenMaster          // 禅定大师: 不弃牌通关时+2.0 mult（该关首次出牌就生效）
}

// MARK: - SF Symbol 图标映射

extension JokerEffect {
    /// SF Symbol 图标名（替代 emoji，统一视觉风格）
    var systemIcon: String {
        switch self {
        case .drawAfterPlay:      return "hand.point.up.fill"
        case .doubleComboRate:    return "link"
        case .lowHandBonus:       return "building.columns.fill"
        case .explosiveBonus:     return "flame.fill"
        case .sequenceBonus:      return "water.waves"
        case .highCardBonus:      return "shield.lefthalf.filled"
        case .extraDiscards:      return "moon.fill"
        case .firstPlayBonus:     return "bolt.fill"
        case .extraDrawOnDiscard: return "theatermasks.fill"
        case .lastStandBonus:     return "flag.fill"
        case .pairMastery:        return "heart.fill"
        case .tripleThreat:       return "hurricane"
        case .goldRush:           return "dollarsign.circle.fill"
        case .secondWind:         return "wind"
        case .cardCounter:        return "brain"
        case .luckyDraw:          return "fish.fill"
        case .scoreSurge:         return "chart.line.uptrend.xyaxis"
        case .miniHandBonus:      return "target"
        case .multiKill:          return "bolt.horizontal.fill"
        case .shieldBreaker:      return "shield.slash.fill"
        case .criticalHit:        return "dice.fill"
        case .insurance:          return "shield.fill"
        case .collector:          return "rectangle.stack.fill"
        case .nightOwl:           return "moon.stars.fill"
        case .earlyBird:          return "sunrise.fill"
        case .miser:              return "banknote.fill"
        case .gambler:            return "dice"
        case .phoenix:            return "flame.circle.fill"
        case .dragon:             return "star.fill"
        case .tideTurner:         return "arrow.triangle.2.circlepath"
        case .shadowClone:        return "person.2.fill"
        case .cosmicShift:        return "arrow.left.arrow.right"
        case .infiniteLoop:       return "infinity"
        case .bloodPact:          return "drop.fill"
        case .fortuneWheel:       return "arrow.clockwise.circle.fill"
        case .bombChain:          return "sparkles"
        case .handOverflow:       return "hand.raised.fill"
        case .patternVariety:     return "wand.and.stars"
        case .goldConverter:      return "testtube.2"
        case .trashToTreasure:    return "arrow.3.trianglepath"
        case .kingSlayer:         return "crown.fill"
        case .aceHigh:            return "a.circle.fill"
        case .planeBonus:         return "airplane"
        case .straightFlush:      return "diamond.fill"
        case .endgameSurge:       return "timer"
        case .heartCollector:     return "suit.heart.fill"
        case .spadeEdge:          return "suit.spade.fill"
        case .diamondMiner:       return "suit.diamond.fill"
        case .clubShield:         return "suit.club.fill"
        case .fullHouse:          return "house.fill"
        case .smallBlind:         return "eye.slash"
        case .bigBlind:           return "circle.inset.filled"
        case .recycler:           return "arrow.2.squarepath"
        case .perfectHand:        return "sparkle"
        case .doubleDown:         return "arrow.uturn.down.circle.fill"
        case .jokerStacker:       return "square.stack.3d.up.fill"
        case .goldDigger:         return "hammer.fill"
        case .mirrorImage:        return "rectangle.on.rectangle"
        case .chainLightning:     return "bolt.circle.fill"
        case .zenMaster:          return "leaf.fill"
        }
    }
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
        // ── Engine Jokers (Legendary) ──
        Joker(
            name: L10n.isEnglish ? "Shadow Clone" : "影分身",
            description: L10n.isEnglish ? "Every play counts as 2 combos" : "每次出牌视为连击×2",
            effect: .shadowClone,
            icon: "👥",
            rarity: .legendary
        ),
        Joker(
            name: L10n.isEnglish ? "Cosmic Shift" : "乾坤大挪移",
            description: L10n.isEnglish ? "Swap chips and mult" : "交换筹码与倍率",
            effect: .cosmicShift,
            icon: "🌀",
            rarity: .legendary
        ),
        Joker(
            name: L10n.isEnglish ? "Infinite Loop" : "无限循环",
            description: L10n.isEnglish ? "Empty hand? Refill from discard" : "手牌打完自动补满",
            effect: .infiniteLoop,
            icon: "♾️",
            rarity: .legendary
        ),
        Joker(
            name: L10n.isEnglish ? "Blood Pact" : "血契",
            description: L10n.isEnglish ? "+3.0 mult, but hand size -1" : "+3.0倍率，但手牌-1",
            effect: .bloodPact,
            icon: "🩸",
            rarity: .legendary
        ),
        Joker(
            name: L10n.isEnglish ? "Fortune Wheel" : "命运之轮",
            description: L10n.isEnglish ? "Each Joker slot adds +0.5 mult" : "每个规则牌槽+0.5倍率",
            effect: .fortuneWheel,
            icon: "🎡",
            rarity: .legendary
        ),
        // ── 第五批 10 张 — 高级策略 ──
        Joker(
            name: L10n.isEnglish ? "Chain Blast" : "连锁爆破",
            description: L10n.isEnglish ? "+50% after bomb" : "炸弹后下一手+50%",
            effect: .bombChain,
            icon: "💥",
            rarity: .rare
        ),
        Joker(
            name: L10n.isEnglish ? "Overflow" : "爆手牌",
            description: L10n.isEnglish ? "+20% when 8+ cards" : "手牌>8时+20%",
            effect: .handOverflow,
            icon: "🃏",
            rarity: .common
        ),
        Joker(
            name: L10n.isEnglish ? "Variety Show" : "博采众长",
            description: L10n.isEnglish ? "+30% after 3+ pattern types" : "本层使用3+种牌型后+30%",
            effect: .patternVariety,
            icon: "🎪",
            rarity: .rare
        ),
        Joker(
            name: L10n.isEnglish ? "Gold Converter" : "金石为开",
            description: L10n.isEnglish ? "+15 chips per 50 gold" : "每50金币+15筹码",
            effect: .goldConverter,
            icon: "⚗️",
            rarity: .common
        ),
        Joker(
            name: L10n.isEnglish ? "Trash to Treasure" : "化腐为奇",
            description: L10n.isEnglish ? "+40% after discard" : "弃牌后下一手+40%",
            effect: .trashToTreasure,
            icon: "♻️",
            rarity: .rare
        ),
        Joker(
            name: L10n.isEnglish ? "King Slayer" : "弑君者",
            description: L10n.isEnglish ? "+25% with K" : "含K的牌型+25%",
            effect: .kingSlayer,
            icon: "👑",
            rarity: .common
        ),
        Joker(
            name: L10n.isEnglish ? "Ace High" : "以A为尊",
            description: L10n.isEnglish ? "+20 chips with A" : "含A牌型+20筹码",
            effect: .aceHigh,
            icon: "🅰️",
            rarity: .common
        ),
        Joker(
            name: L10n.isEnglish ? "Soaring Plane" : "展翅高飞",
            description: L10n.isEnglish ? "+80% for planes" : "飞机类牌型+80%",
            effect: .planeBonus,
            icon: "✈️",
            rarity: .rare
        ),
        Joker(
            name: L10n.isEnglish ? "Straight Flush" : "同花连珠",
            description: L10n.isEnglish ? "×3 for flush straight" : "同花顺子×3",
            effect: .straightFlush,
            icon: "💎",
            rarity: .legendary
        ),
        Joker(
            name: L10n.isEnglish ? "Endgame Surge" : "终局冲刺",
            description: L10n.isEnglish ? "+40% in last 2 plays" : "最后2次出牌+40%",
            effect: .endgameSurge,
            icon: "⏰",
            rarity: .rare
        ),
        // ── 第六批 15 张 — 花色策略 & 高级机制 ──
        Joker(
            name: L10n.isEnglish ? "Heart Hunter" : "红心猎手",
            description: L10n.isEnglish ? "+0.3 mult with ♥" : "含♥牌时+0.3倍率",
            effect: .heartCollector,
            icon: "❤️",
            rarity: .common
        ),
        Joker(
            name: L10n.isEnglish ? "Spade Edge" : "黑锋之刃",
            description: L10n.isEnglish ? "+15 chips with ♠" : "含♠牌时+15筹码",
            effect: .spadeEdge,
            icon: "♠️",
            rarity: .common
        ),
        Joker(
            name: L10n.isEnglish ? "Diamond Miner" : "钻石矿工",
            description: L10n.isEnglish ? "+10 gold on clear with ♦" : "含♦出牌过关额外+10金币",
            effect: .diamondMiner,
            icon: "💎",
            rarity: .common
        ),
        Joker(
            name: L10n.isEnglish ? "Club Shield" : "梅花护盾",
            description: L10n.isEnglish ? "♣ in discard keeps combo" : "弃牌含♣时不减连击",
            effect: .clubShield,
            icon: "🛡️",
            rarity: .common
        ),
        Joker(
            name: L10n.isEnglish ? "Full House" : "满堂红",
            description: L10n.isEnglish ? "Triple+pair +1.0 mult" : "三带二+1.0倍率",
            effect: .fullHouse,
            icon: "🏠",
            rarity: .rare
        ),
        Joker(
            name: L10n.isEnglish ? "Small Blind" : "小盲注",
            description: L10n.isEnglish ? "+50% mult before floor 3" : "第2关前+50%倍率",
            effect: .smallBlind,
            icon: "🔮",
            rarity: .common
        ),
        Joker(
            name: L10n.isEnglish ? "Big Blind" : "大盲注",
            description: L10n.isEnglish ? "+0.6 mult after floor 8" : "第8关后+0.6倍率",
            effect: .bigBlind,
            icon: "🔴",
            rarity: .rare
        ),
        Joker(
            name: L10n.isEnglish ? "Recycler" : "回收大师",
            description: L10n.isEnglish ? "+5 chips/card discarded" : "弃牌时每张+5筹码(下一手)",
            effect: .recycler,
            icon: "♻️",
            rarity: .rare
        ),
        Joker(
            name: L10n.isEnglish ? "Perfect Hand" : "完美之手",
            description: L10n.isEnglish ? "5 same-suit cards ×4" : "出5张同花色×4倍",
            effect: .perfectHand,
            icon: "✨",
            rarity: .legendary
        ),
        Joker(
            name: L10n.isEnglish ? "Double Down" : "加倍下注",
            description: L10n.isEnglish ? "Same type twice +0.5 mult" : "连续出相同牌型+0.5倍率",
            effect: .doubleDown,
            icon: "🎯",
            rarity: .rare
        ),
        Joker(
            name: L10n.isEnglish ? "Joker Stacker" : "叠叠乐",
            description: L10n.isEnglish ? "+10 chips per Joker" : "每张Joker+10筹码",
            effect: .jokerStacker,
            icon: "📚",
            rarity: .common
        ),
        Joker(
            name: L10n.isEnglish ? "Gold Digger" : "掘金者",
            description: L10n.isEnglish ? "+1.0 mult at 100+ gold" : "金币≥100时+1.0倍率",
            effect: .goldDigger,
            icon: "⛏️",
            rarity: .rare
        ),
        Joker(
            name: L10n.isEnglish ? "Mirror Image" : "镜像",
            description: L10n.isEnglish ? "Pair chips ×2" : "对子筹码翻倍",
            effect: .mirrorImage,
            icon: "🪞",
            rarity: .rare
        ),
        Joker(
            name: L10n.isEnglish ? "Chain Lightning" : "连锁闪电",
            description: L10n.isEnglish ? "+0.6 mult at combo 4+" : "连击≥4时+0.6倍率",
            effect: .chainLightning,
            icon: "⚡",
            rarity: .legendary
        ),
        Joker(
            name: L10n.isEnglish ? "Zen Master" : "禅定大师",
            description: L10n.isEnglish ? "+2.0 mult if no discards used" : "不弃牌时+2.0倍率",
            effect: .zenMaster,
            icon: "🧘",
            rarity: .legendary
        ),
    ]
}

// MARK: - Joker Unlock Manager

@MainActor
enum JokerUnlockManager {
    private static let unlockedKey = "unlocked_joker_effects"

    /// Effects that are unlocked by default (all common)
    static let defaultUnlocked: Set<JokerEffect> = {
        Set(Joker.allJokers.filter { $0.rarity == .common }.map { $0.effect })
    }()

    /// Get all currently unlocked effects
    static var unlockedEffects: Set<JokerEffect> {
        if let data = UserDefaults.standard.data(forKey: unlockedKey),
           let saved = try? JSONDecoder().decode(Set<JokerEffect>.self, from: data) {
            return defaultUnlocked.union(saved)
        }
        return defaultUnlocked
    }

    /// Unlock a specific Joker effect
    static func unlock(_ effect: JokerEffect) {
        var current = unlockedEffects
        current.insert(effect)
        let extra = current.subtracting(defaultUnlocked)
        if let data = try? JSONEncoder().encode(extra) {
            UserDefaults.standard.set(data, forKey: unlockedKey)
        }
    }

    /// Check if a Joker is unlocked
    static func isUnlocked(_ joker: Joker) -> Bool {
        unlockedEffects.contains(joker.effect)
    }

    /// Get available Jokers for shop (only unlocked ones)
    static var availableJokers: [Joker] {
        Joker.allJokers.filter { isUnlocked($0) }
    }

    /// Unlock all rare Jokers
    static func unlockAllRare() {
        for joker in Joker.allJokers where joker.rarity == .rare {
            unlock(joker.effect)
        }
    }

    /// Unlock all legendary Jokers
    static func unlockAllLegendary() {
        for joker in Joker.allJokers where joker.rarity == .legendary {
            unlock(joker.effect)
        }
    }
}
