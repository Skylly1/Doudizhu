import Foundation

// MARK: - 游戏状态

enum GamePhase: Equatable {
    case dealing              // 发牌中
    case selecting            // 玩家选牌中
    case scoring(PlayResult)  // 得分动画
    case floorWin             // 本层过关
    case floorFail            // 本层失败
    case shopping             // 商店
    case specialEvent(SpecialEvent) // 特殊事件
    case victory              // 通关
    case gameOver             // 死亡

    static func == (lhs: GamePhase, rhs: GamePhase) -> Bool {
        switch (lhs, rhs) {
        case (.dealing, .dealing),
             (.selecting, .selecting),
             (.floorWin, .floorWin),
             (.floorFail, .floorFail),
             (.shopping, .shopping),
             (.victory, .victory),
             (.gameOver, .gameOver):
            return true
        case (.scoring, .scoring):
            return true
        case (.specialEvent, .specialEvent):
            return true
        default:
            return false
        }
    }
}

// MARK: - 关卡配置

struct FloorConfig {
    let floor: Int
    let name: String
    let targetScore: Int
    let maxPlays: Int
    let maxDiscards: Int
    let description: String
    let isShop: Bool
    let bossModifiers: [BossModifier]
    
    init(floor: Int, name: String, targetScore: Int, maxPlays: Int, maxDiscards: Int,
         description: String, isShop: Bool, bossModifiers: [BossModifier] = []) {
        self.floor = floor
        self.name = name
        self.targetScore = targetScore
        self.maxPlays = maxPlays
        self.maxDiscards = maxDiscards
        self.description = description
        self.isShop = isShop
        self.bossModifiers = bossModifiers
    }
    
    var isBoss: Bool { !bossModifiers.isEmpty }

    /// 日挑战精选5层：热身→普通→商店→Boss→终极Boss，10-15分钟体验
    static let dailyChallengeFloors: [FloorConfig] = [
        FloorConfig(floor: 1, name: L10n.floor1Name, targetScore: 200, maxPlays: 5, maxDiscards: 3,
                    description: L10n.floor1Desc, isShop: false),
        FloorConfig(floor: 2, name: L10n.floor5Name, targetScore: 500, maxPlays: 5, maxDiscards: 2,
                    description: L10n.floor5Desc, isShop: false),
        FloorConfig(floor: 3, name: L10n.floor7Name, targetScore: 0, maxPlays: 0, maxDiscards: 0,
                    description: L10n.floor7Desc, isShop: true),
        FloorConfig(floor: 4, name: L10n.floor8Name, targetScore: 900, maxPlays: 4, maxDiscards: 2,
                    description: L10n.floor8Desc, isShop: false,
                    bossModifiers: [.bannedPattern]),
        FloorConfig(floor: 5, name: L10n.floor15Name, targetScore: 1800, maxPlays: 3, maxDiscards: 1,
                    description: L10n.floor15Desc, isShop: false,
                    bossModifiers: [.escalating, .phantomCards]),
    ]

    static let allFloors: [FloorConfig] = [
        // === 第一章：乡野篇 ===
        FloorConfig(floor: 1, name: L10n.floor1Name, targetScore: 150, maxPlays: 5, maxDiscards: 3,
                    description: L10n.floor1Desc, isShop: false),
        FloorConfig(floor: 2, name: L10n.floor2Name, targetScore: 250, maxPlays: 5, maxDiscards: 3,
                    description: L10n.floor2Desc, isShop: false),
        FloorConfig(floor: 3, name: L10n.floor3Name, targetScore: 0, maxPlays: 0, maxDiscards: 0,
                    description: L10n.floor3Desc, isShop: true),
        FloorConfig(floor: 4, name: L10n.floor4Name, targetScore: 400, maxPlays: 5, maxDiscards: 2,
                    description: L10n.floor4Desc, isShop: false, bossModifiers: [.scoreCap]),
        // === 第二章：府城篇 ===
        FloorConfig(floor: 5, name: L10n.floor5Name, targetScore: 550, maxPlays: 5, maxDiscards: 2,
                    description: L10n.floor5Desc, isShop: false),
        FloorConfig(floor: 6, name: L10n.floor6Name, targetScore: 750, maxPlays: 5, maxDiscards: 2,
                    description: L10n.floor6Desc, isShop: false, bossModifiers: [.handShrink, .pairTax]),
        FloorConfig(floor: 7, name: L10n.floor7Name, targetScore: 0, maxPlays: 0, maxDiscards: 0,
                    description: L10n.floor7Desc, isShop: true),
        FloorConfig(floor: 8, name: L10n.floor8Name, targetScore: 1100, maxPlays: 4, maxDiscards: 2,
                    description: L10n.floor8Desc, isShop: false,
                    bossModifiers: [.bannedPattern]),
        // === 第三章：江湖篇 ===
        FloorConfig(floor: 9, name: L10n.floor9Name, targetScore: 1500, maxPlays: 4, maxDiscards: 1,
                    description: L10n.floor9Desc, isShop: false),
        FloorConfig(floor: 10, name: L10n.floor10Name, targetScore: 2000, maxPlays: 4, maxDiscards: 1,
                    description: L10n.floor10Desc, isShop: false, bossModifiers: [.jokerSilence, .comboBreaker]),
        FloorConfig(floor: 11, name: L10n.floor11Name, targetScore: 0, maxPlays: 0, maxDiscards: 0,
                    description: L10n.floor11Desc, isShop: true),
        FloorConfig(floor: 12, name: L10n.floor12Name, targetScore: 2500, maxPlays: 4, maxDiscards: 1,
                    description: L10n.floor12Desc, isShop: false),
        FloorConfig(floor: 13, name: L10n.floor13Name, targetScore: 2800, maxPlays: 4, maxDiscards: 1,
                    description: L10n.floor13Desc, isShop: false,
                    bossModifiers: [.escalating, .goldDrain]),
        FloorConfig(floor: 14, name: L10n.floor14Name, targetScore: 0, maxPlays: 0, maxDiscards: 0,
                    description: L10n.floor14Desc, isShop: true),
        FloorConfig(floor: 15, name: L10n.floor15Name, targetScore: 4200, maxPlays: 3, maxDiscards: 0,
                    description: L10n.floor15Desc, isShop: false,
                    bossModifiers: [.escalating, .phantomCards]),
    ]
}

// MARK: - 手牌排序模式

enum HandSortMode: String, CaseIterable {
    case byRank = "rank"
    case bySuit = "suit"

    var icon: String {
        switch self {
        case .byRank: return "textformat.123"
        case .bySuit: return "suit.spade.fill"
        }
    }

    var label: String {
        switch self {
        case .byRank: return L10n.sortByRank
        case .bySuit: return L10n.sortBySuit
        }
    }

    var next: HandSortMode {
        switch self {
        case .byRank: return .bySuit
        case .bySuit: return .byRank
        }
    }
}

// MARK: - Roguelike 核心

@MainActor class RogueRun: ObservableObject {
    // 状态
    @Published var phase: GamePhase = .dealing
    @Published var currentFloorIndex: Int = 0
    @Published var floorScore: Int = 0          // 本层得分
    @Published var totalScore: Int = 0          // 总得分
    @Published var playsRemaining: Int = 0      // 剩余出牌次数
    @Published var discardsRemaining: Int = 0   // 剩余弃牌次数
    @Published var gold: Int = 150              // 金币
    @Published var multiplier: Double = 1.0     // 全局倍率
    @Published var activeBuffs: [Buff] = []
    @Published var activeJokers: [Joker] = []    // 规则牌（最多5张）
    @Published var handCards: [Card] = []
    @Published var lastPlayResult: PlayResult?
    @Published var combo: Int = 0               // 连续出牌计数（连击加分）
    @Published var lastScoreEarned: Int = 0      // 上次出牌得分（破甲用）
    @Published var playHistory: [PlayResult] = []   // 本层出牌记录
    @Published var ascensionLevel: Int = 0    // 挑战等级（0-10）
    @Published var handSortMode: HandSortMode = .byRank  // 手牌排序模式
    var bossState: BossState?                  // 当前Boss关状态（非Boss关为nil）
    var phoenixUsed: Bool = false               // 浴火凤凰复活是否已使用
    var dailyChallenge: DailyChallenge?         // 每日挑战（非nil表示当前为每日挑战模式）
    var lastPatternWasBomb: Bool = false        // 上一手是否为炸弹（连锁爆破用）
    var justDiscarded: Bool = false             // 上一操作是否为弃牌（化腐为奇用）
    var usedPatternTypes: Set<PatternType> = [] // 本层已使用的牌型（博采众长用）
    var bonusPlays: Int = 0                     // 下层额外出牌次数（特殊事件奖励）
    var lastPatternType: PatternType?           // 上一手牌型（加倍下注用）
    var recyclerChipBonus: Int = 0              // 回收大师累积筹码（弃牌时填充）

    /// Run start time for play-time tracking
    private var runStartTime: Date?
    /// Current build ID for stats
    private var currentBuildId: String = ""

    /// 剩余牌堆（弃牌后从中补牌）
    var drawPile: [Card] = []

    /// 是否有可恢复的主线存档
    var hasSavedRun: Bool { SaveManager.shared.hasSavedGame }

    /// 自动保存（每次出牌/弃牌后调用，按槽位隔离）
    private func autoSave() {
        SaveManager.shared.save(run: self, buildId: currentBuildId)
    }

    /// 从主线存档恢复
    func restoreFromSave() -> Bool {
        guard let save = SaveManager.shared.loadSave() else { return false }
        save.restore(to: self)
        currentBuildId = save.starterBuildId
        runStartTime = Date()
        return true
    }

    /// 从每日挑战存档恢复
    func restoreFromDailySave() -> Bool {
        guard let save = SaveManager.shared.loadDailySave() else { return false }
        save.restore(to: self)
        currentBuildId = save.starterBuildId
        runStartTime = Date()
        return true
    }

    /// 清除存档（根据当前模式清对应槽位）
    func clearSave() {
        if dailyChallenge != nil {
            SaveManager.shared.clearDailySaves()
        } else {
            SaveManager.shared.clearSaves()
        }
    }

    /// 当前模式的关卡列表
    private var activeFloors: [FloorConfig] {
        dailyChallenge != nil ? FloorConfig.dailyChallengeFloors : FloorConfig.allFloors
    }

    var currentFloor: FloorConfig {
        let floors = activeFloors
        guard currentFloorIndex >= 0,
              currentFloorIndex < floors.count else {
            CrashReporter.shared.log(
                "currentFloorIndex \(currentFloorIndex) out of bounds (0..<\(floors.count))",
                level: .error)
            return floors.last ?? FloorConfig(
                floor: 1, name: "???", targetScore: 100,
                maxPlays: 3, maxDiscards: 1, description: "", isShop: false)
        }
        return floors[currentFloorIndex]
    }

    var floorProgress: Double {
        guard effectiveTargetScore > 0 else { return 1.0 }
        return min(1.0, Double(floorScore) / Double(effectiveTargetScore))
    }

    var isFloorCleared: Bool {
        floorScore >= effectiveTargetScore
    }
    
    /// 考虑Ascension和Boss修改器后的实际目标分数
    var effectiveTargetScore: Int {
        var target = currentFloor.targetScore
        // Ascension 加成
        if ascensionLevel >= 1 {
            target = Int(Double(target) * (1.0 + Double(ascensionLevel) * 0.08))
        }
        // Boss escalating: 每次出牌后+5%
        if let boss = bossState, boss.hasEscalating {
            target = Int(Double(target) * (1.0 + Double(boss.escalationCount) * 0.05))
        }
        return target
    }

    /// 检查是否装备了某种效果的规则牌（排除被封印的）
    func hasJoker(_ effect: JokerEffect) -> Bool {
        activeJokers.enumerated().contains { index, joker in
            joker.effect == effect && bossState?.silencedJokerIndex != index
        }
    }

    // MARK: - 流程控制

    /// 开始当前层
    func startFloor() {
        let floor = currentFloor
        
        if floor.isShop {
            phase = .shopping
            Analytics.shared.track(.shopVisit, params: ["gold": "\(gold)"])
            return
        }
        
        floorScore = 0
        playsRemaining = floor.maxPlays + bonusPlays
        bonusPlays = 0  // 消费后清零
        discardsRemaining = floor.maxDiscards
        combo = 0
        lastPlayResult = nil
        playHistory = []
        bossState = nil
        lastPatternWasBomb = false
        justDiscarded = false
        usedPatternTypes = []
        lastPatternType = nil
        recyclerChipBonus = 0
        
        // Ascension 调整
        if ascensionLevel >= 1 {
            // A1+: 目标分数+8%/级（由 effectiveTargetScore 计算）
        }
        if ascensionLevel >= 3 {
            // A3+: 出牌次数-1
            playsRemaining = max(2, playsRemaining - 1)
        }
        if ascensionLevel >= 5 {
            // A5+: 换牌次数-1
            discardsRemaining = max(0, discardsRemaining - 1)
        }
        if ascensionLevel >= 7 {
            // A7+: 起始金币更少（在startWithBuild中处理）
        }

        // 破釜沉舟 Buff: 出牌次数-2
        if activeBuffs.contains(where: { $0.type == .desperateStrike }) {
            playsRemaining = max(1, playsRemaining - 2)
        }
        
        // Boss 关初始化
        if floor.isBoss {
            bossState = BossState(modifiers: floor.bossModifiers)
            Analytics.shared.track(.bossEncounter, params: [
                "floor": "\(floor.floor)",
                "modifiers": floor.bossModifiers.map(\.rawValue).joined(separator: ",")
            ])
            // timeLimit修改器: 出牌次数-1
            if floor.bossModifiers.contains(.timeLimit) {
                playsRemaining = max(2, playsRemaining - 1)
            }
        }
        
        // 规则牌：暗度陈仓 — 每关换牌次数+2
        if hasJoker(.extraDiscards) {
            discardsRemaining += 2
        }
        
        // 规则牌：回光返照 — 每关额外出牌+1
        if hasJoker(.secondWind) {
            playsRemaining += 1
        }

        // Daily challenge modifier adjustments
        if let dc = dailyChallenge {
            for mod in dc.modifiers {
                switch mod {
                case .extraPlays:
                    playsRemaining += 2
                case .noDiscards:
                    discardsRemaining = 0
                case .speedRun:
                    playsRemaining = min(playsRemaining, 3)
                case .giantHand:
                    break  // Handled below in deal size
                case .tinyDeck:
                    break  // Handled in deal
                case .mirrorMatch:
                    // 每层都有Boss修改器
                    if bossState == nil {
                        let randomMod = BossModifier.allCases.randomElement() ?? .scoreCap
                        bossState = BossState(modifiers: [randomMod])
                    }
                case .bossRush:
                    // Boss rush: every non-shop floor gets a random boss modifier
                    if !floor.isShop && bossState == nil {
                        let randomMod = BossModifier.allCases.randomElement() ?? .escalating
                        bossState = BossState(modifiers: [randomMod])
                    }
                case .noBombs, .halfGold, .doubleScore, .allOrNothing, .goldRush:
                    break  // Handled elsewhere (playCards / startDailyChallenge)
                }
            }
        }

        // 发牌 — 日挑战使用种子+层号确保确定性
        let giantHandBonus = (dailyChallenge?.modifiers.contains(.giantHand) == true) ? 5 : 0
        let baseHandSize = hasJoker(.bloodPact) ? 9 : 10
        let dealSize = baseHandSize + giantHandBonus
        let tinyDeck = dailyChallenge?.modifiers.contains(.tinyDeck) == true
        let floorSeed: UInt64? = dailyChallenge.map { $0.seed &+ UInt64(currentFloorIndex) }
        let deckSizeParam: Int? = tinyDeck ? 36 : nil
        let deal = Deck.dealRoguelike(handSize: dealSize, deckSize: deckSizeParam, seed: floorSeed)
        handCards = deal.hand
        drawPile = deal.drawPile

        // handShrink: 手牌减少2张（发8张）
        if let boss = bossState, boss.modifiers.contains(.handShrink) {
            while handCards.count > 8 {
                let removed = handCards.removeLast()
                drawPile.append(removed)
            }
            drawPile.shuffle()
        }

        // jokerSilence: 随机封印一张规则牌
        if let boss = bossState, boss.modifiers.contains(.jokerSilence) && !activeJokers.isEmpty {
            var b = boss
            b.silencedJokerIndex = Int.random(in: 0..<activeJokers.count)
            bossState = b
        }

        // phantomCards: 随机2张手牌无法被选中
        if var boss = bossState, boss.modifiers.contains(.phantomCards) && handCards.count > 4 {
            let phantomIndices = handCards.indices.shuffled().prefix(2)
            boss.phantomCardIds = Set(phantomIndices.map { handCards[$0].id })
            bossState = boss
        }

        phase = .selecting
        Analytics.shared.track(.floorStart, params: [
            "floor": "\(currentFloor.floor)",
            "is_boss": "\(currentFloor.isBoss)"
        ])
        Analytics.shared.track(.levelStart, level: currentFloor.floor)
    }

    /// 出牌
    func playCards(_ cards: [Card]) -> PlayResult? {
        guard phase == .selecting, playsRemaining > 0 else { return nil }
        guard !cards.isEmpty else { return nil }

        guard let pattern = PatternRecognizer.recognize(cards) else {
            return nil  // 无效牌型
        }

        // Daily challenge: noBombs — reject bomb and rocket patterns
        if let dc = dailyChallenge, dc.modifiers.contains(.noBombs),
           pattern.type == .bomb || pattern.type == .rocket {
            return nil
        }

        // Daily challenge: allOrNothing — only bombs and rockets score
        let isAllOrNothing = dailyChallenge?.modifiers.contains(.allOrNothing) == true
        let isBombOrRocket = pattern.type == .bomb || pattern.type == .rocket

        // 消耗出牌次数
        playsRemaining -= 1
        combo += hasJoker(.shadowClone) ? 2 : 1

        // === chips × mult scoring system ===
        var chips = Double(pattern.baseChips)
        chips += Double(PatternUpgradeManager.shared.chipBonus(for: pattern.type))
        var mult = pattern.baseMult
        mult += PatternUpgradeManager.shared.multBonus(for: pattern.type)

        // Buff bonuses → chips & mult
        for buff in activeBuffs {
            chips += Double(buff.chipBonus(pattern: pattern))
            mult += buff.multBonus(pattern: pattern)
        }

        // Combo → mult
        if combo > 1 {
            let rate = hasJoker(.doubleComboRate) ? 0.30 : 0.15
            mult += Double(combo - 1) * rate
        }

        // === Joker effects split into chip/mult ===

        // Mult-boosting Jokers:
        if combo == 1 && hasJoker(.firstPlayBonus) { mult += 1.0 }  // 一鸣惊人: ×2.5→×2.0 (nerf)
        if playsRemaining == 0 && hasJoker(.lastStandBonus) { mult += 1.5 }  // 破釜沉舟: ×3→×2.5 (nerf)
        if handCards.count - cards.count <= 5 && hasJoker(.lowHandBonus) { mult += 0.5 }
        if hasJoker(.explosiveBonus) && (pattern.type == .bomb || pattern.type == .rocket) { mult += 0.75 }  // 火烧连营: ×2→×1.75 (nerf)
        if hasJoker(.sequenceBonus) && (pattern.type == .straight || pattern.type == .pairStraight) { mult += 1.0 }
        if hasJoker(.pairMastery) && pattern.type == .pair { mult += 1.0 }
        if hasJoker(.tripleThreat) && (pattern.type == .triple || pattern.type == .tripleWithOne || pattern.type == .tripleWithPair) { mult += 0.8 }  // 三生万物: +0.5→+0.8 (buff)
        if hasJoker(.multiKill) && combo >= 3 { mult += 0.4 }  // 连环杀: +0.2→+0.4 (buff)
        if hasJoker(.shieldBreaker) && lastScoreEarned >= 60 { mult += 0.5 }  // 破甲: 100分→60分门槛降低, +0.25→+0.5 (buff)
        if hasJoker(.nightOwl) && currentFloor.floor >= 8 { mult += 0.4 }  // 夜枭: +0.2→+0.4 (buff)

        // Chip-boosting Jokers:
        if hasJoker(.highCardBonus) {
            let highCount = handCards.filter { $0.rank == .two || $0.rank == .ace }.count
            chips += Double(highCount) * 8.0  // 四面楚歌: 5→8 per K/A/2 (buff)
        }
        if hasJoker(.cardCounter) && cards.count >= 5 { chips += 25.0 }  // 心算如飞: 20→25 (buff)
        if hasJoker(.miniHandBonus) && cards.count <= 3 { chips += 15.0 }
        if hasJoker(.scoreSurge) && currentFloor.targetScore > 0 && floorScore >= currentFloor.targetScore / 2 { chips += 20.0 }  // 厚积薄发: 15→20 (buff)
        if hasJoker(.earlyBird) && combo == 1 { chips += 30.0 }
        if hasJoker(.collector) && cards.count >= 5 {
            let suits = Set(cards.compactMap { $0.suit })
            if suits.count == 1 { chips += 35.0 }  // 同花顺缘: 25→35 (buff)
        }
        if hasJoker(.miser) && gold >= 50 { chips += Double(gold / 50) * 8.0 }  // 守财奴: 5→8 per 50g (buff)

        // Random/special Jokers:
        if hasJoker(.criticalHit) && Int.random(in: 0..<10) == 0 { mult *= 2.0 }
        if hasJoker(.gambler) {
            let roll = Double.random(in: -0.30...0.40)
            mult *= (1.0 + roll)
            // BALANCE: Expected value is +5% — consider narrowing range to -0.20...0.30 to reduce frustration
        }
        if hasJoker(.dragon) && combo == 5 { mult += 2.0 }  // 神龙摆尾: combo 6→5 门槛降低 (buff)
        if hasJoker(.tideTurner) && effectiveTargetScore > 0 && floorScore < effectiveTargetScore * 4 / 10 { mult += 0.8 }  // 逆转乾坤: 30%→40%门槛+0.5→+0.8 (buff)

        // Engine Jokers
        if hasJoker(.bloodPact) { mult += 3.0 }
        if hasJoker(.fortuneWheel) { mult += Double(activeJokers.count) * 0.5 }
        if hasJoker(.cosmicShift) {
            let tempChips = chips
            chips = max(1.0, mult * 10.0)
            mult = max(0.1, tempChips / 10.0)
        }

        // 第五批 Joker effects
        if hasJoker(.bombChain) && lastPatternWasBomb { mult += 0.5 }
        if hasJoker(.handOverflow) && handCards.count > 8 { mult += 0.2 }
        if hasJoker(.patternVariety) && usedPatternTypes.count >= 3 { mult += 0.3 }
        if hasJoker(.goldConverter) && gold >= 50 { chips += Double(gold / 50) * 15.0 }
        if hasJoker(.trashToTreasure) && justDiscarded { mult += 0.4 }
        if hasJoker(.kingSlayer) && cards.contains(where: { $0.rank == .king }) { mult += 0.25 }
        if hasJoker(.aceHigh) && cards.contains(where: { $0.rank == .ace }) { chips += 20.0 }
        if hasJoker(.planeBonus) && (pattern.type == .plane || pattern.type == .planeWithWings) { mult += 0.8 }
        if hasJoker(.straightFlush) && pattern.type == .straight {
            let suits = Set(cards.compactMap { $0.suit })
            if suits.count == 1 { mult *= 3.0 }
        }
        if hasJoker(.endgameSurge) && playsRemaining <= 1 { mult += 0.4 }

        // 第六批 Joker effects — 花色策略
        if hasJoker(.heartCollector) && cards.contains(where: { $0.suit == .heart }) { mult += 0.3 }
        if hasJoker(.spadeEdge) && cards.contains(where: { $0.suit == .spade }) { chips += 15.0 }
        // diamondMiner: gold bonus handled in onScoringComplete
        // clubShield: handled in discardCards
        if hasJoker(.fullHouse) && pattern.type == .tripleWithPair { mult += 1.0 }
        if hasJoker(.smallBlind) && currentFloor.floor <= 2 { mult += 0.5 }
        if hasJoker(.bigBlind) && currentFloor.floor >= 8 { mult += 0.6 }
        // recycler: bonus applied via recyclerChipBonus
        chips += Double(recyclerChipBonus)
        recyclerChipBonus = 0
        if hasJoker(.perfectHand) && cards.count == 5 {
            let suits = Set(cards.compactMap { $0.suit })
            if suits.count == 1 { mult *= 4.0 }
            // BALANCE: ×4 mult for same-suit 5-card is extremely strong with straightFlush (×3) — cap combined at ×8?
        }
        if hasJoker(.doubleDown) && lastPatternType == pattern.type { mult += 0.5 }
        if hasJoker(.jokerStacker) { chips += Double(activeJokers.count) * 10.0 }
        if hasJoker(.goldDigger) && gold >= 100 { mult += 1.0 }
        if hasJoker(.mirrorImage) && pattern.type == .pair { chips *= 2.0 }
        if hasJoker(.chainLightning) && combo >= 4 { mult += 0.6 }
        if hasJoker(.zenMaster) && discardsRemaining == currentFloor.maxDiscards { mult += 2.0 }
        // BALANCE: zenMaster (+2.0 mult) is very strong since noDiscards floors auto-trigger it; consider checking that maxDiscards > 0

        // 更新状态追踪
        usedPatternTypes.insert(pattern.type)
        lastPatternWasBomb = (pattern.type == .bomb)
        lastPatternType = pattern.type
        justDiscarded = false

        // Calculate final score
        let finalChips = max(0, Int(chips))
        let finalMult = max(0.0, mult)
        var earned = max(0, Int(chips * mult))

        // === Boss 修改器 ===
        if var boss = bossState {
            // bannedPattern: 如果出了被禁的牌型，得分为0
            if let banned = boss.bannedPatternType, pattern.type == banned {
                earned = 0  // 被禁牌型无分
            }
            
            // scoringDecay: 每次出牌得分递减10%
            if boss.hasScoringDecay && boss.decayCount > 0 {
                let decayRate = 1.0 - Double(boss.decayCount) * 0.10
                earned = Int(Double(earned) * max(0.3, decayRate))
            }
            boss.decayCount += 1
            
            // escalating: 每次出牌后目标+5%（在onScoringComplete中不需要，因为target是固定的，但我们记录）
            boss.escalationCount += 1
            
            // greedyTax: 每次出牌扣10金币
            if boss.hasGreedyTax {
                gold = max(0, gold - 10)
            }

            // scoreCap: 单次出牌得分上限为目标分的60%
            if boss.modifiers.contains(.scoreCap) && effectiveTargetScore > 0 {
                let cap = effectiveTargetScore * 6 / 10
                earned = min(earned, cap)
            }

            // pairTax: 对子得分减半
            if boss.modifiers.contains(.pairTax) && pattern.type == .pair {
                earned = earned / 2
            }

            // comboBreaker: 禁用连击加成（重置combo为1）
            if boss.modifiers.contains(.comboBreaker) {
                combo = 1
            }

            // goldDrain: 每回合自动扣5金币
            if boss.modifiers.contains(.goldDrain) {
                gold = max(0, gold - 5)
            }

            // reverseOrder: 小牌得分更高（根据平均rank反转系数）
            if boss.modifiers.contains(.reverseOrder) {
                let avgRank = cards.map({ $0.rank.rawValue }).reduce(0, +) / max(1, cards.count)
                // rawValue 3-17, midpoint≈10 → 小牌(3-9)获得加成, 大牌(11-17)受到惩罚
                let factor = 1.0 + Double(10 - avgRank) * 0.06
                earned = Int(Double(earned) * max(0.5, factor))
            }

            bossState = boss
        }

        // allOrNothing: 非炸弹/火箭牌型得分归零
        if isAllOrNothing && !isBombOrRocket {
            earned = 0
        }

        // 全局倍率
        earned = Int(Double(earned) * multiplier)

        floorScore += earned
        totalScore += earned
        lastScoreEarned = earned

        // 规则牌：点石成金 — 每次出牌+8金币 (buff: 5→8)
        if hasJoker(.goldRush) {
            gold += 8
            PlayerStats.shared.totalGoldEarned += 8
        }

        // 成就检测
        let tracker = AchievementTracker.shared
        if earned >= 200 { tracker.tryUnlock("single_200") }
        if earned >= 500 { tracker.tryUnlock("single_500") }
        if earned >= 1000 { tracker.tryUnlock("single_1000") }
        if totalScore >= 500 { tracker.tryUnlock("score_500") }
        if totalScore >= 2000 { tracker.tryUnlock("score_2000") }
        if totalScore >= 5000 { tracker.tryUnlock("score_5000") }
        if totalScore >= 10000 { tracker.tryUnlock("score_10000") }
        if combo >= 5 { tracker.tryUnlock("combo_5") }
        if pattern.type == .bomb { tracker.tryUnlock("bombs_10"); tracker.tryUnlock("bombs_50") }
        if pattern.type == .rocket { tracker.tryUnlock("rockets_5") }
        if pattern.type == .straight || pattern.type == .pairStraight { tracker.tryUnlock("straights_20") }
        if activeJokers.count >= 5 { tracker.tryUnlock("jokers_collect_5") }
        if gold >= 300 { tracker.tryUnlock("gold_300") }

        // 从手牌移除
        let playedIds = Set(cards.map(\.id))
        handCards.removeAll { playedIds.contains($0.id) }

        // Engine Joker: Infinite Loop — if hand is empty, refill from draw pile (once per play)
        if hasJoker(.infiniteLoop) && handCards.isEmpty && !drawPile.isEmpty {
            let baseHandSize = hasJoker(.bloodPact) ? 9 : 10
            let refillCount = min(baseHandSize, drawPile.count)
            handCards = Array(drawPile.prefix(refillCount))
            drawPile.removeFirst(refillCount)
            sortHand()
        }

        // 规则牌：贪心鬼 — 出牌后额外抽1张
        if hasJoker(.drawAfterPlay) && !drawPile.isEmpty {
            handCards.append(drawPile.removeFirst())
            sortHand()
        }

        // Build score breakdown for display
        var breakdown: [ScoreComponent] = []

        // 1. Base pattern
        breakdown.append(ScoreComponent(
            label: pattern.type.displayName,
            value: Int(Double(pattern.baseChips) * pattern.baseMult),
            isMultiplier: false
        ))

        // 2. Buff contributions
        let buffChips = activeBuffs.reduce(0) { $0 + $1.chipBonus(pattern: pattern) }
        let buffMult = activeBuffs.reduce(0.0) { $0 + $1.multBonus(pattern: pattern) }
        if buffChips > 0 || buffMult > 0 {
            breakdown.append(ScoreComponent(
                label: L10n.isEnglish ? "Buff" : "增益",
                value: Int(Double(buffChips) + buffMult * Double(pattern.baseChips)),
                isMultiplier: false
            ))
        }

        // 3. Joker count
        let jokerContrib = earned - Int(Double(pattern.baseChips + buffChips) * (pattern.baseMult + buffMult) * multiplier)
        if jokerContrib > 0 && !activeJokers.isEmpty {
            breakdown.append(ScoreComponent(
                label: L10n.isEnglish ? "Jokers ×\(activeJokers.count)" : "规则牌 ×\(activeJokers.count)",
                value: jokerContrib,
                isMultiplier: false
            ))
        }

        // 4. Combo
        if combo > 1 {
            let comboValue = Int(Double(pattern.baseChips) * Double(combo - 1) * (hasJoker(.doubleComboRate) ? 0.30 : 0.15))
            breakdown.append(ScoreComponent(
                label: "Combo ×\(combo)",
                value: comboValue,
                isMultiplier: false
            ))
        }

        // 5. Total
        breakdown.append(ScoreComponent(
            label: L10n.isEnglish ? "Total" : "总计",
            value: earned,
            isMultiplier: false
        ))

        let result = PlayResult(
            pattern: pattern,
            score: earned,
            totalScore: floorScore,
            combo: combo,
            isFloorCleared: isFloorCleared,
            breakdown: breakdown,
            chips: finalChips,
            mult: finalMult
        )
        lastPlayResult = result
        playHistory.append(result)
        phase = .scoring(result)

        // PlayerStats tracking
        let stats = PlayerStats.shared
        stats.totalCardsPlayed += 1  // 计数一次出牌（非单张卡牌数）
        if combo > stats.highestCombo { stats.highestCombo = combo }
        if earned > stats.highestSingleScore { stats.highestSingleScore = earned }
        stats.save()

        // 行为埋点
        Analytics.shared.track(.cardPlay, params: [
            "pattern": pattern.type.rawValue,
            "cards": "\(cards.count)",
            "score": "\(earned)",
            "floor": "\(currentFloor.floor)"
        ])
        if combo >= 3 {
            Analytics.shared.track(.comboAchieved, params: ["combo": "\(combo)"])
        }

        autoSave()

        return result
    }

    /// 得分动画结束后调用
    func onScoringComplete() {
        if isFloorCleared {
            let baseBonus = currentFloor.targetScore / 10
            // 超额奖励：超过目标分的部分按 5% 转化为额外金币（最多翻倍）
            let overScore = max(0, floorScore - effectiveTargetScore)
            let overBonus = min(baseBonus, overScore / 20)
            var totalBonus = baseBonus + overBonus
            // 天降横财 Buff: 过关金币+50%
            if activeBuffs.contains(where: { $0.type == .goldWindfall }) {
                totalBonus = Int(Double(totalBonus) * 1.5)
            }
            // 钻石矿工 Joker: 含♦出牌过关时额外+10金币
            if hasJoker(.diamondMiner) {
                totalBonus += 10
            }
            gold += totalBonus

            // PlayerStats: floor cleared
            PlayerStats.shared.totalFloors += 1
            PlayerStats.shared.totalGoldEarned += totalBonus
            PlayerStats.shared.save()

            // 成就检测
            let tracker = AchievementTracker.shared
            if currentFloorIndex == 0 { tracker.tryUnlock("first_win") }
            if currentFloorIndex >= 4 { tracker.tryUnlock("mid_run") }
            if discardsRemaining == currentFloor.maxDiscards { tracker.tryUnlock("no_discard_win") }

            Analytics.shared.track(.levelComplete, level: currentFloor.floor)

            // 特殊事件：非商店/非Boss层，20%概率触发
            if !currentFloor.isShop && !currentFloor.isBoss {
                if let event = SpecialEventGenerator.maybeGenerate(floor: currentFloor.floor, gold: gold) {
                    phase = .specialEvent(event)
                    return
                }
            }
            phase = .floorWin
            autoSave()  // 覆盖 playCards 中的 mid-scoring 存档，确保 floorWin 状态被保存
        } else if playsRemaining <= 0 || handCards.isEmpty {
            // 规则牌：保险单 — 失败时保留50%分数到下一次
            if hasJoker(.insurance) {
                totalScore = max(totalScore, floorScore / 2)
            }
            // 规则牌：浴火凤凰 — 每局可复活一次
            if hasJoker(.phoenix) && !phoenixUsed {
                phoenixUsed = true
                playsRemaining = 1
                phase = .selecting
                return
            }
            Analytics.shared.track(.levelFail, level: currentFloor.floor)
            // PlayerStats: record play time for failed run
            if let start = runStartTime {
                PlayerStats.shared.addPlayTime(Date().timeIntervalSince(start))
                runStartTime = nil
            }
            // Record daily challenge score on fail
            if dailyChallenge != nil {
                DailyChallenge.recordScore(totalScore)
                DailyChallenge.markCompleted()
                GameCenterManager.shared.reportDailyChallengeScore(totalScore)
            }
            phase = .floorFail
            // 不自动删除存档 — 用户可从失败界面重试或保存退出
            autoSave()
        } else {
            phase = .selecting
            autoSave()  // 覆盖 playCards 中的 mid-scoring 存档，确保存档状态稳定
        }
    }

    /// 换牌（弃掉选中的牌，从牌堆抽等量新牌）
    func discardCards(_ cards: [Card]) -> Bool {
        // Daily challenge: noDiscards — always reject
        if let dc = dailyChallenge, dc.modifiers.contains(.noDiscards) {
            return false
        }
        guard phase == .selecting, discardsRemaining > 0, !cards.isEmpty else {
            return false
        }

        discardsRemaining -= 1
        // 冰封之心 Buff: 弃牌不打断连击
        let hasClubInDiscard = hasJoker(.clubShield) && cards.contains(where: { $0.suit == .club })
        if activeBuffs.contains(where: { $0.type == .iceFrozen }) || hasClubInDiscard {
            // 不减少 combo
        } else {
            combo = max(0, combo - 1)  // 换牌仅减少1点连击，不清零
        }

        // 回收大师 Joker: 弃牌时每张+5 chips到下一手
        if hasJoker(.recycler) {
            recyclerChipBonus += cards.count * 5
        }

        // 移除弃牌
        let discardedIds = Set(cards.map(\.id))
        handCards.removeAll { discardedIds.contains($0.id) }

        // 从牌堆补抽等量新牌
        var drawCount = min(cards.count, drawPile.count)

        // 规则牌：偷梁换柱 — 换牌时多抽1张
        if hasJoker(.extraDrawOnDiscard) && drawPile.count > drawCount {
            drawCount += 1
        }

        if drawCount > 0 {
            // 规则牌：锦鲤附体 — 从牌堆底部取牌
            let drawn: [Card]
            if hasJoker(.luckyDraw) {
                drawn = Array(drawPile.suffix(drawCount))
                drawPile.removeLast(drawCount)
            } else {
                drawn = Array(drawPile.prefix(drawCount))
                drawPile.removeFirst(drawCount)
            }
            handCards.append(contentsOf: drawn)
            sortHand()
        }

        // 换牌后如果手牌空了且没达标
        if handCards.isEmpty && !isFloorCleared {
            phase = .floorFail
        }

        autoSave()
        justDiscarded = true
        Analytics.shared.track(.cardDiscard, params: ["cards": "\(cards.count)"])
        return true
    }

    /// 进入下一层
    func advanceToNextFloor() {
        currentFloorIndex += 1
        PlayerStats.shared.recordHighestFloor(currentFloorIndex)
        if currentFloorIndex >= activeFloors.count {
            AchievementTracker.shared.tryUnlock("full_clear")
            AchievementTracker.shared.tryUnlock("wins_5")
            // 保存最高Ascension记录
            let key = "highestAscensionCleared"
            let current = UserDefaults.standard.integer(forKey: key)
            if ascensionLevel > current {
                UserDefaults.standard.set(ascensionLevel, forKey: key)
            }
            if ascensionLevel >= 1 { AchievementTracker.shared.tryUnlock("ascension_1") }
            if ascensionLevel >= 5 { AchievementTracker.shared.tryUnlock("ascension_5") }
            if ascensionLevel >= 10 { AchievementTracker.shared.tryUnlock("ascension_10") }
            // 构筑精通追踪
            trackBuildWin(currentBuildId)
            // PlayerStats: record win and play time
            PlayerStats.shared.totalWins += 1
            if let start = runStartTime {
                PlayerStats.shared.addPlayTime(Date().timeIntervalSince(start))
                runStartTime = nil
            }
            PlayerStats.shared.save()
            // Record daily challenge score
            if dailyChallenge != nil {
                DailyChallenge.recordScore(totalScore)
                DailyChallenge.markCompleted()
                GameCenterManager.shared.reportDailyChallengeScore(totalScore)
            }
            Analytics.shared.track(.runComplete, params: [
                "total_score": "\(totalScore)",
                "ascension": "\(ascensionLevel)",
                "build": currentBuildId,
                "joker_count": "\(activeJokers.count)"
            ])
            phase = .victory
            clearSave()
        } else {
            startFloor()
            autoSave()
        }
    }

    /// 商店购买后继续
    func leaveShop() {
        advanceToNextFloor()
    }

    /// 使用指定流派重新开始
    func startWithBuild(_ build: StarterBuild) {
        currentFloorIndex = 0
        totalScore = 0
        gold = 150 + build.goldAdjustment
        // Ascension 7+: 起始金币-30
        if ascensionLevel >= 7 {
            gold = max(50, gold - 30)
        }
        multiplier = 1.0
        activeBuffs = []
        activeJokers = []
        combo = 0
        drawPile = []
        lastScoreEarned = 0
        phoenixUsed = false
        dailyChallenge = nil
        bonusPlays = 0
        lastPatternType = nil
        recyclerChipBonus = 0

        // PlayerStats: end previous run timer & start new run
        if let start = runStartTime {
            PlayerStats.shared.addPlayTime(Date().timeIntervalSince(start))
        }
        runStartTime = Date()
        currentBuildId = build.id
        PlayerStats.shared.totalRuns += 1
        PlayerStats.shared.recordBuildUsage(build.id)

        // 核心漏斗埋点
        Analytics.shared.track(.runStart, params: [
            "build": build.id,
            "ascension": "\(ascensionLevel)"
        ])

        if let joker = build.startingJoker {
            activeJokers.append(joker)
        }
        if let buff = build.startingBuff {
            activeBuffs.append(buff)
        }

        startFloor()
        autoSave()  // 确保首次存档，防止用户退出后无存档可恢复
    }

    /// Start a daily challenge run
    func startDailyChallenge(_ challenge: DailyChallenge) {
        currentFloorIndex = 0
        totalScore = 0
        gold = 150 + challenge.bonusGold
        multiplier = 1.0
        activeBuffs = []
        activeJokers = []
        combo = 0
        drawPile = []
        lastScoreEarned = 0
        phoenixUsed = false
        dailyChallenge = challenge
        lastPatternType = nil
        recyclerChipBonus = 0

        // Apply daily challenge modifiers
        for modifier in challenge.modifiers {
            switch modifier {
            case .halfGold:
                gold = gold / 2
            case .doubleScore:
                multiplier = 2.0
            case .goldRush:
                gold = gold * 3  // ×3 gold
            case .giantHand:
                break  // Handled in startFloor
            default:
                break
            }
        }

        // 日挑战赠送1个种子确定的Joker — 所有玩家同天同Joker
        let commonJokers = Joker.allJokers.filter { $0.rarity == .common }
        if !commonJokers.isEmpty {
            var rng = SeededRandomNumberGenerator(seed: challenge.seed &+ 777)
            let idx = Int(rng.next() % UInt64(commonJokers.count))
            activeJokers.append(commonJokers[idx])
        }

        // PlayerStats
        if let start = runStartTime {
            PlayerStats.shared.addPlayTime(Date().timeIntervalSince(start))
        }
        runStartTime = Date()
        currentBuildId = "daily"
        PlayerStats.shared.totalRuns += 1
        PlayerStats.shared.save()  // 确保每日挑战的 totalRuns 增量被持久化

        Analytics.shared.track(.dailyChallengeStart, params: [
            "modifier": challenge.modifiers.map(\.rawValue).joined(separator: ",")
        ])

        DailyChallenge.markStarted()
        startFloor()
        autoSave()  // 确保首次存档，防止用户退出后无存档可恢复
    }

    /// 重试当前关卡（保留 Joker/Buff/金币，重置本层状态）
    func retryCurrentFloor() {
        floorScore = 0
        combo = 0
        lastPlayResult = nil
        lastScoreEarned = 0
        playHistory = []
        lastPatternWasBomb = false
        justDiscarded = false
        usedPatternTypes = []
        lastPatternType = nil
        recyclerChipBonus = 0
        startFloor()
    }

    /// 切换手牌排序模式 & 重排
    func toggleSortMode() {
        handSortMode = handSortMode.next
        sortHand()
    }

    /// 按当前模式排序手牌
    func sortHand() {
        switch handSortMode {
        case .byRank:
            handCards.sort { $0.rank < $1.rank }
        case .bySuit:
            let suitOrder: [Suit: Int] = [.spade: 0, .heart: 1, .club: 2, .diamond: 3]
            handCards.sort { a, b in
                let sa = a.suit.flatMap { suitOrder[$0] } ?? 9
                let sb = b.suit.flatMap { suitOrder[$0] } ?? 9
                if sa != sb { return sa < sb }
                return a.rank < b.rank
            }
        }
    }

    /// 重新开始整个游戏
    func restart() {
        // 如果当前有进行中的局，记录为放弃
        if currentFloorIndex > 0 {
            Analytics.shared.track(.runAbandon, params: [
                "floor": "\(currentFloor.floor)",
                "score": "\(totalScore)",
                "reason": "restart"
            ])
        }
        // 每日挑战：必须实际游玩才算完成（防止进入即退出刷完成）
        if dailyChallenge != nil {
            if totalScore > 0 || currentFloorIndex > 0 {
                DailyChallenge.recordScore(totalScore)
                DailyChallenge.markCompleted()
                GameCenterManager.shared.reportDailyChallengeScore(totalScore)
            }
            // score=0 且 floor=0 → 未实际游玩，不标记完成，允许重新挑战
        }
        clearSave()

        // 游戏次数成就
        let gamesKey = "total_games_played"
        let games = UserDefaults.standard.integer(forKey: gamesKey) + 1
        UserDefaults.standard.set(games, forKey: gamesKey)
        if games >= 10 { AchievementTracker.shared.tryUnlock("games_10") }
        if games >= 50 { AchievementTracker.shared.tryUnlock("games_50") }

        currentFloorIndex = 0
        totalScore = 0
        gold = 150
        multiplier = 1.0
        activeBuffs = []
        activeJokers = []
        combo = 0
        drawPile = []
        lastScoreEarned = 0
        phoenixUsed = false
        dailyChallenge = nil
        bonusPlays = 0
        lastPatternType = nil
        recyclerChipBonus = 0

        // PlayerStats: end previous run timer & start new run
        if let start = runStartTime {
            PlayerStats.shared.addPlayTime(Date().timeIntervalSince(start))
        }
        runStartTime = Date()
        PlayerStats.shared.totalRuns += 1
        PlayerStats.shared.save()

        startFloor()
    }

    /// 购买 Buff
    func buyBuff(_ buff: Buff, cost: Int) -> Bool {
        guard gold >= cost else { return false }
        gold -= cost
        activeBuffs.append(buff)
        Analytics.shared.track(.shopPurchase, params: ["type": "buff", "cost": "\(cost)"])
        return true
    }

    /// 购买规则牌
    func buyJoker(_ joker: Joker, cost: Int) -> Bool {
        guard gold >= cost else { return false }
        guard activeJokers.count < Joker.maxSlots else { return false }
        gold -= cost
        activeJokers.append(joker)
        Analytics.shared.track(.shopPurchase, params: ["type": "joker", "id": joker.effect.rawValue, "cost": "\(cost)"])
        return true
    }

    // MARK: - 特殊事件

    /// 应用特殊事件选择
    func applyEventChoice(_ choice: EventChoice) {
        switch choice.effect {
        case .gainGold(let amount):
            gold += amount
            PlayerStats.shared.totalGoldEarned += amount
        case .loseGold(let amount):
            gold = max(0, gold - amount)
        case .gainRandomJoker:
            let owned = Set(activeJokers.map(\.effect))
            let available = Joker.allJokers.filter { !owned.contains($0.effect) }
            if let pick = available.randomElement(), activeJokers.count < Joker.maxSlots {
                activeJokers.append(pick)
            } else {
                gold += 30
                PlayerStats.shared.totalGoldEarned += 30
            }
        case .buyRandomJoker(let cost):
            guard gold >= cost else { break }
            gold -= cost
            let owned2 = Set(activeJokers.map(\.effect))
            let available2 = Joker.allJokers.filter { !owned2.contains($0.effect) }
            if let pick = available2.randomElement(), activeJokers.count < Joker.maxSlots {
                activeJokers.append(pick)
            } else {
                gold += cost  // 无可用Joker，退还金币
                PlayerStats.shared.totalGoldEarned += cost
            }
        case .gainRandomBuff:
            if let pick = Buff.allBuffs.randomElement() {
                activeBuffs.append(pick)
            }
        case .healPlays(let count, let goldCost):
            if goldCost > 0 {
                gold = max(0, gold - goldCost)
            }
            bonusPlays += count
        case .upgradeRandomJoker:
            guard gold >= 50 else { break }
            gold -= 50
            gold += 30  // 简化补偿
        case .skipNextShop:
            break
        case .nothing:
            break
        }
        PlayerStats.shared.save()  // 持久化事件中的金币变动
        phase = .floorWin
    }

    // MARK: - 首购奖励

    /// 应用首购奖励（仅当前 run 有效，不破坏平衡）
    func applyFirstPurchaseBonus() {
        // +2 换牌次数
        discardsRemaining += 2
        
        // +1 初始连击
        combo = 1
        
        // 随机赠送一张 Joker（如果槽位未满）
        if activeJokers.count < Joker.maxSlots {
            let allJokers = Joker.allJokers.filter { j in
                !activeJokers.contains(where: { $0.id == j.id })
            }
            if let randomJoker = allJokers.randomElement() {
                activeJokers.append(randomJoker)
            }
        }
    }
}

struct ScoreComponent: Hashable {
    let label: String
    let value: Int
    let isMultiplier: Bool
}

struct PlayResult: Equatable {
    let pattern: CardPattern
    let score: Int
    let totalScore: Int
    let combo: Int
    let isFloorCleared: Bool
    var breakdown: [ScoreComponent] = []
    var chips: Int = 0
    var mult: Double = 1.0

    static func == (lhs: PlayResult, rhs: PlayResult) -> Bool {
        lhs.score == rhs.score && lhs.totalScore == rhs.totalScore && lhs.combo == rhs.combo
    }
}

// MARK: - 构筑精通追踪

extension RogueRun {
    /// 记录用某个构筑通关，解锁构筑相关成就
    private func trackBuildWin(_ buildId: String) {
        let key = "build_wins_set"
        var wins = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        wins.insert(buildId)
        UserDefaults.standard.set(Array(wins), forKey: key)
        if wins.count >= 3 { AchievementTracker.shared.tryUnlock("builds_3") }
        if wins.count >= 9 { AchievementTracker.shared.tryUnlock("builds_9") }
    }
}

// MARK: - Buff 系统

struct Buff: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let type: BuffType
    let value: Double
    let icon: String

    init(name: String, description: String, type: BuffType, value: Double, icon: String = "✨") {
        self.id = UUID()
        self.name = name
        self.description = description
        self.type = type
        self.value = value
        self.icon = icon
    }

    func apply(to score: Int, pattern: CardPattern) -> Int {
        switch type {
        case .globalMultiplier, .comboMultiplier:
            return Int(Double(score) * value)
        case .bombBonus:
            return pattern.type == .bomb ? score + Int(value) : score
        case .rocketBonus:
            return pattern.type == .rocket ? score + Int(value) : score
        case .straightBonus:
            return pattern.type == .straight ? Int(Double(score) * value) : score
        case .planeBonus:
            return (pattern.type == .plane || pattern.type == .planeWithWings)
                ? Int(Double(score) * value) : score
        case .pairBonus:
            return pattern.type == .pair ? score + Int(value) : score
        case .tripleBonus:
            return (pattern.type == .triple || pattern.type == .tripleWithOne || pattern.type == .tripleWithPair)
                ? Int(Double(score) * value) : score
        case .singleBonus:
            return pattern.type == .single ? score + Int(value) : score
        case .pairStraightBonus:
            return pattern.type == .pairStraight ? Int(Double(score) * value) : score
        case .fourWithTwoBonus:
            return pattern.type == .fourWithTwo ? score + Int(value) : score
        case .chipFlat, .highCardChip, .lowCardChip, .burnHand:
            return score + Int(value)
        case .multFlat, .desperateStrike:
            return Int(Double(score) * (1.0 + value))
        case .allInBomb:
            return pattern.type == .bomb ? Int(Double(score) * value) : score
        case .windStraight:
            return pattern.type == .straight ? Int(Double(score) * value) : score
        case .planeAscend:
            return (pattern.type == .plane || pattern.type == .planeWithWings) ? score + Int(value) : score
        case .alchemyStone, .iceFrozen, .eagleEye, .goldWindfall, .reshuffleOnce:
            return score  // 非计分类 — 在其他逻辑中处理
        }
    }

    /// Chip bonus for the chips×mult scoring system
    func chipBonus(pattern: CardPattern) -> Int {
        switch type {
        case .bombBonus:
            return pattern.type == .bomb ? Int(value) : 0
        case .rocketBonus:
            return pattern.type == .rocket ? Int(value) : 0
        case .pairBonus:
            return pattern.type == .pair ? Int(value) : 0
        case .singleBonus:
            return pattern.type == .single ? Int(value) : 0
        case .fourWithTwoBonus:
            return pattern.type == .fourWithTwo ? Int(value) : 0
        case .chipFlat:
            return Int(value)
        case .highCardChip, .lowCardChip:
            return Int(value)
        case .burnHand:
            return Int(value)  // 每次出牌+20 chips
        case .planeAscend:
            return (pattern.type == .plane || pattern.type == .planeWithWings) ? Int(value) : 0
        default:
            return 0
        }
    }

    /// Mult bonus for the chips×mult scoring system
    func multBonus(pattern: CardPattern) -> Double {
        switch type {
        case .globalMultiplier:
            return value - 1.0  // e.g. value=1.5 → +0.5 mult
        case .straightBonus:
            return pattern.type == .straight ? value - 1.0 : 0.0
        case .planeBonus:
            return (pattern.type == .plane || pattern.type == .planeWithWings) ? value - 1.0 : 0.0
        case .tripleBonus:
            return (pattern.type == .triple || pattern.type == .tripleWithOne || pattern.type == .tripleWithPair)
                ? value - 1.0 : 0.0
        case .pairStraightBonus:
            return pattern.type == .pairStraight ? value - 1.0 : 0.0
        case .comboMultiplier:
            return value - 1.0  // 始终生效，value=1.3 → +0.3 mult
        case .multFlat:
            return value
        case .desperateStrike:
            return value  // +3.0 mult
        case .allInBomb:
            return pattern.type == .bomb ? value - 1.0 : 0.0
        case .windStraight:
            return pattern.type == .straight ? value - 1.0 : 0.0
        default:
            return 0.0
        }
    }
}

enum BuffType: String, Codable, Hashable {
    case globalMultiplier   // 全局倍率提升
    case bombBonus          // 炸弹额外加分
    case rocketBonus        // 火箭额外加分
    case straightBonus      // 顺子倍率
    case planeBonus         // 飞机倍率
    // 新增 10 种
    case pairBonus          // 对子加分
    case tripleBonus        // 三条倍率
    case comboMultiplier    // 连击倍率加成
    case singleBonus        // 单张加分
    case pairStraightBonus  // 连对倍率
    case fourWithTwoBonus   // 四带二加分
    case chipFlat           // 固定chips加成（所有牌型）
    case multFlat           // 固定mult加成（所有牌型）
    case highCardChip       // 大牌(A/2/King)额外chips
    case lowCardChip        // 小牌(3-6)额外chips
    // 第三批 10 种 — 高级/限时
    case burnHand           // 灼热之手: 每次出牌chips+20（本层）
    case iceFrozen          // 冰封之心: 弃牌不打断连击（本层）
    case eagleEye           // 鹰眼: 策略类（标记用）
    case alchemyStone       // 点石成金: 2和3的chips等同于A
    case allInBomb          // 乾坤一掷: 下一次炸弹mult×3
    case windStraight       // 顺风顺水: 下一次顺子chips×2
    case planeAscend        // 飞黄腾达: 飞机牌型额外+100chips
    case goldWindfall        // 天降横财: 过关金币+50%
    case desperateStrike    // 破釜沉舟: 手数-2但mult+3
    case reshuffleOnce      // 洗牌大师: 策略类（标记用）

    /// SF Symbol 图标名
    var systemIcon: String {
        switch self {
        case .globalMultiplier:  return "wand.and.stars"
        case .bombBonus:         return "flame.fill"
        case .rocketBonus:       return "paperplane.fill"
        case .straightBonus:     return "wind"
        case .planeBonus:        return "airplane"
        case .pairBonus:         return "heart.fill"
        case .tripleBonus:       return "dice.fill"
        case .comboMultiplier:   return "bolt.fill"
        case .singleBonus:       return "person.fill"
        case .pairStraightBonus: return "equal.circle.fill"
        case .fourWithTwoBonus:  return "diamond.fill"
        case .chipFlat:          return "square.fill"
        case .multFlat:          return "sparkle"
        case .highCardChip:      return "crown.fill"
        case .lowCardChip:       return "leaf.fill"
        case .burnHand:          return "flame"
        case .iceFrozen:         return "snowflake"
        case .eagleEye:          return "eye.fill"
        case .alchemyStone:      return "testtube.2"
        case .allInBomb:         return "star.circle.fill"
        case .windStraight:      return "water.waves"
        case .planeAscend:       return "trophy.fill"
        case .goldWindfall:      return "banknote.fill"
        case .desperateStrike:   return "shield.lefthalf.filled"
        case .reshuffleOnce:     return "arrow.triangle.2.circlepath"
        }
    }
}

// MARK: - 预设 Buff

extension Buff {
    static let allBuffs: [Buff] = [
        Buff(name: L10n.buffPowderKegName, description: L10n.buffPowderKegDesc, type: .bombBonus, value: 60, icon: "🧨"),
        Buff(name: L10n.buffSkyRocketName, description: L10n.buffSkyRocketDesc, type: .rocketBonus, value: 120, icon: "🚀"),
        Buff(name: L10n.buffTailwindName, description: L10n.buffTailwindDesc, type: .straightBonus, value: 2.0, icon: "🚗"),
        Buff(name: L10n.buffAirParadeName, description: L10n.buffAirParadeDesc, type: .planeBonus, value: 2.5, icon: "✈️"),
        Buff(name: L10n.buffDoubleCharmName, description: L10n.buffDoubleCharmDesc, type: .globalMultiplier, value: 1.5, icon: "🔮"),
        Buff(name: L10n.buffFortuneGodName, description: L10n.buffFortuneGodDesc, type: .globalMultiplier, value: 1.3, icon: "💰"),
        Buff(name: L10n.buffDoubleBlastName, description: L10n.buffDoubleBlastDesc, type: .bombBonus, value: 100, icon: "🎆"),
        Buff(name: L10n.buffIronChainName, description: L10n.buffIronChainDesc, type: .straightBonus, value: 2.5, icon: "⛓️"),
        Buff(name: L10n.buffSkyFortressName, description: L10n.buffSkyFortressDesc, type: .planeBonus, value: 3.0, icon: "🏰"),
        Buff(name: L10n.buffDivineTouchName, description: L10n.buffDivineTouchDesc, type: .globalMultiplier, value: 2.0, icon: "🌟"),
        // ── 新增 10 种 Buff ──
        Buff(name: L10n.isEnglish ? "Twin Strike" : "成双成对",
             description: L10n.isEnglish ? "Pairs +40 chips" : "对子额外+40基础分",
             type: .pairBonus, value: 40, icon: "👯"),
        Buff(name: L10n.isEnglish ? "Triple Fortune" : "三生有幸",
             description: L10n.isEnglish ? "Triples ×1.8 mult" : "三条类牌型×1.8倍率",
             type: .tripleBonus, value: 1.8, icon: "🎲"),
        Buff(name: L10n.isEnglish ? "Combo Surge" : "连击狂潮",
             description: L10n.isEnglish ? "+0.3 mult per combo" : "连击时额外+0.3倍率",
             type: .comboMultiplier, value: 1.3, icon: "⚡"),
        Buff(name: L10n.isEnglish ? "Lone Wolf" : "独狼之力",
             description: L10n.isEnglish ? "Single cards +25 chips" : "单张出牌+25基础分",
             type: .singleBonus, value: 25, icon: "🐺"),
        Buff(name: L10n.isEnglish ? "Chain Link" : "连锁反应",
             description: L10n.isEnglish ? "Pair straights ×2.0 mult" : "连对牌型×2.0倍率",
             type: .pairStraightBonus, value: 2.0, icon: "🔗"),
        Buff(name: L10n.isEnglish ? "Quad Crusher" : "四方碾压",
             description: L10n.isEnglish ? "Four-with-two +80 chips" : "四带二+80基础分",
             type: .fourWithTwoBonus, value: 80, icon: "💎"),
        Buff(name: L10n.isEnglish ? "Iron Foundation" : "铁打根基",
             description: L10n.isEnglish ? "+15 chips to all plays" : "所有出牌+15基础分",
             type: .chipFlat, value: 15, icon: "🪨"),
        Buff(name: L10n.isEnglish ? "Spirit Boost" : "灵气加持",
             description: L10n.isEnglish ? "+0.5 mult to all plays" : "所有出牌+0.5倍率",
             type: .multFlat, value: 0.5, icon: "💫"),
        Buff(name: L10n.isEnglish ? "Royal Favor" : "皇恩浩荡",
             description: L10n.isEnglish ? "A/2/K cards +20 chips" : "A/2/K牌+20基础分",
             type: .highCardChip, value: 20, icon: "👑"),
        Buff(name: L10n.isEnglish ? "Grassroot Power" : "草根之力",
             description: L10n.isEnglish ? "3-6 cards +15 chips" : "3-6点牌+15基础分",
             type: .lowCardChip, value: 15, icon: "🌱"),
        // ── 第三批 10 种 Buff — 高级限时效果 ──
        Buff(name: L10n.isEnglish ? "Burning Hand" : "灼热之手",
             description: L10n.isEnglish ? "+20 chips per play" : "每次出牌+20基础分",
             type: .burnHand, value: 20, icon: "🔥"),
        Buff(name: L10n.isEnglish ? "Frozen Heart" : "冰封之心",
             description: L10n.isEnglish ? "Discards don't break combo" : "弃牌不打断连击",
             type: .iceFrozen, value: 0, icon: "❄️"),
        Buff(name: L10n.isEnglish ? "Eagle Eye" : "鹰眼",
             description: L10n.isEnglish ? "See next 3 draw pile cards" : "可查看牌堆顶3张",
             type: .eagleEye, value: 0, icon: "🦅"),
        Buff(name: L10n.isEnglish ? "Alchemy Stone" : "点石成金",
             description: L10n.isEnglish ? "2 and 3 chips equal to A" : "2和3的chips等同于A",
             type: .alchemyStone, value: 0, icon: "⚗️"),
        Buff(name: L10n.isEnglish ? "All-In Bomb" : "乾坤一掷",
             description: L10n.isEnglish ? "Next bomb ×3 mult" : "下一次炸弹×3倍率",
             type: .allInBomb, value: 3.0, icon: "🎰"),
        Buff(name: L10n.isEnglish ? "Smooth Sailing" : "顺风顺水",
             description: L10n.isEnglish ? "Next straight ×2 chips" : "下一次顺子chips×2",
             type: .windStraight, value: 2.0, icon: "🌊"),
        Buff(name: L10n.isEnglish ? "Soaring Fortune" : "飞黄腾达",
             description: L10n.isEnglish ? "Planes +100 chips" : "飞机牌型+100基础分",
             type: .planeAscend, value: 100, icon: "🏅"),
        Buff(name: L10n.isEnglish ? "Gold Windfall" : "天降横财",
             description: L10n.isEnglish ? "+50% floor clear gold" : "过关金币+50%",
             type: .goldWindfall, value: 1.5, icon: "🤑"),
        Buff(name: L10n.isEnglish ? "Desperate Strike" : "破釜沉舟",
             description: L10n.isEnglish ? "Plays -2, but +3.0 mult" : "出牌次数-2但+3.0倍率",
             type: .desperateStrike, value: 3.0, icon: "⚔️"),
        Buff(name: L10n.isEnglish ? "Shuffle Master" : "洗牌大师",
             description: L10n.isEnglish ? "Redeal hand once per floor" : "每层可重新发牌1次",
             type: .reshuffleOnce, value: 0, icon: "🎴"),
    ]
}
