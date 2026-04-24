import Foundation

// MARK: - 游戏状态

enum GamePhase: Equatable {
    case dealing              // 发牌中
    case selecting            // 玩家选牌中
    case scoring(PlayResult)  // 得分动画
    case floorWin             // 本层过关
    case floorFail            // 本层失败
    case shopping             // 商店
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

    static let allFloors: [FloorConfig] = [
        // === 第一章：乡野篇 ===
        FloorConfig(floor: 1, name: L10n.floor1Name, targetScore: 200, maxPlays: 5, maxDiscards: 3,
                    description: L10n.floor1Desc, isShop: false),
        FloorConfig(floor: 2, name: L10n.floor2Name, targetScore: 320, maxPlays: 5, maxDiscards: 3,
                    description: L10n.floor2Desc, isShop: false),
        FloorConfig(floor: 3, name: L10n.floor3Name, targetScore: 0, maxPlays: 0, maxDiscards: 0,
                    description: L10n.floor3Desc, isShop: true),
        FloorConfig(floor: 4, name: L10n.floor4Name, targetScore: 500, maxPlays: 5, maxDiscards: 2,
                    description: L10n.floor4Desc, isShop: false),
        // === 第二章：府城篇 ===
        FloorConfig(floor: 5, name: L10n.floor5Name, targetScore: 650, maxPlays: 5, maxDiscards: 2,
                    description: L10n.floor5Desc, isShop: false),
        FloorConfig(floor: 6, name: L10n.floor6Name, targetScore: 850, maxPlays: 4, maxDiscards: 2,
                    description: L10n.floor6Desc, isShop: false),
        FloorConfig(floor: 7, name: L10n.floor7Name, targetScore: 0, maxPlays: 0, maxDiscards: 0,
                    description: L10n.floor7Desc, isShop: true),
        FloorConfig(floor: 8, name: L10n.floor8Name, targetScore: 1100, maxPlays: 4, maxDiscards: 2,
                    description: L10n.floor8Desc, isShop: false,
                    bossModifiers: [.bannedPattern]),
        // === 第三章：江湖篇 ===
        FloorConfig(floor: 9, name: L10n.floor9Name, targetScore: 1400, maxPlays: 4, maxDiscards: 1,
                    description: L10n.floor9Desc, isShop: false),
        FloorConfig(floor: 10, name: L10n.floor10Name, targetScore: 1800, maxPlays: 4, maxDiscards: 1,
                    description: L10n.floor10Desc, isShop: false),
        FloorConfig(floor: 11, name: L10n.floor11Name, targetScore: 0, maxPlays: 0, maxDiscards: 0,
                    description: L10n.floor11Desc, isShop: true),
        FloorConfig(floor: 12, name: L10n.floor12Name, targetScore: 2200, maxPlays: 4, maxDiscards: 1,
                    description: L10n.floor12Desc, isShop: false),
        FloorConfig(floor: 13, name: L10n.floor13Name, targetScore: 2800, maxPlays: 3, maxDiscards: 1,
                    description: L10n.floor13Desc, isShop: false,
                    bossModifiers: [.escalating]),
        FloorConfig(floor: 14, name: L10n.floor14Name, targetScore: 0, maxPlays: 0, maxDiscards: 0,
                    description: L10n.floor14Desc, isShop: true),
        FloorConfig(floor: 15, name: L10n.floor15Name, targetScore: 4000, maxPlays: 3, maxDiscards: 0,
                    description: L10n.floor15Desc, isShop: false,
                    bossModifiers: [.scoringDecay, .noDiscard]),
    ]
}

// MARK: - Roguelike 核心

class RogueRun: ObservableObject {
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
    @Published var ascensionLevel: Int = 0    // 挑战等级（0-10）
    var bossState: BossState?                  // 当前Boss关状态（非Boss关为nil）
    var phoenixUsed: Bool = false               // 浴火凤凰复活是否已使用

    /// Run start time for play-time tracking
    private var runStartTime: Date?
    /// Current build ID for stats
    private var currentBuildId: String = ""

    /// 剩余牌堆（弃牌后从中补牌）
    private(set) var drawPile: [Card] = []

    var currentFloor: FloorConfig {
        FloorConfig.allFloors[currentFloorIndex]
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

    /// 检查是否装备了某种效果的规则牌
    func hasJoker(_ effect: JokerEffect) -> Bool {
        activeJokers.contains { $0.effect == effect }
    }

    // MARK: - 流程控制

    /// 开始当前层
    func startFloor() {
        let floor = currentFloor
        
        if floor.isShop {
            phase = .shopping
            return
        }
        
        floorScore = 0
        playsRemaining = floor.maxPlays
        discardsRemaining = floor.maxDiscards
        combo = 0
        lastPlayResult = nil
        bossState = nil
        
        // Ascension 调整
        if ascensionLevel >= 1 {
            // A1+: 目标分数+15%（通过减少容错实现）
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
        
        // Boss 关初始化
        if floor.isBoss {
            bossState = BossState(modifiers: floor.bossModifiers)
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
        
        // 发牌
        let deal = Deck.dealRoguelike(handSize: 10)
        handCards = deal.hand
        drawPile = deal.drawPile
        phase = .selecting
        Analytics.shared.track(.levelStart, level: currentFloor.floor)
    }

    /// 出牌
    func playCards(_ cards: [Card]) -> PlayResult? {
        guard phase == .selecting, playsRemaining > 0 else { return nil }
        guard !cards.isEmpty else { return nil }

        guard let pattern = PatternRecognizer.recognize(cards) else {
            return nil  // 无效牌型
        }

        // 消耗出牌次数
        playsRemaining -= 1
        combo += 1

        // 计算得分
        var earned = pattern.baseScore

        // Buff 加成
        for buff in activeBuffs {
            earned = buff.apply(to: earned, pattern: pattern)
        }

        // 连击加成：连续出牌第2次+15%，第3次+30%...
        if combo > 1 {
            let rate = hasJoker(.doubleComboRate) ? 0.30 : 0.15
            let comboBonus = Double(combo - 1) * rate
            earned = Int(Double(earned) * (1.0 + comboBonus))
        }

        // 规则牌：一鸣惊人 — 每关第一次出牌×2.5
        if combo == 1 && hasJoker(.firstPlayBonus) {
            earned = Int(Double(earned) * 2.5)
        }

        // 规则牌：破釜沉舟 — 最后1次出牌机会时×3
        if playsRemaining == 0 && hasJoker(.lastStandBonus) {
            earned = Int(Double(earned) * 3.0)
        }

        // 规则牌：空城计 — 手牌≤5张时×1.5（出牌前计算，因为牌还没移除）
        if handCards.count - cards.count <= 5 && hasJoker(.lowHandBonus) {
            earned = Int(Double(earned) * 1.5)
        }

        // 规则牌：火烧连营 — 炸弹/火箭×2
        if hasJoker(.explosiveBonus) && (pattern.type == .bomb || pattern.type == .rocket) {
            earned *= 2
        }

        // 规则牌：顺势而为 — 顺子/连对×2
        if hasJoker(.sequenceBonus) && (pattern.type == .straight || pattern.type == .pairStraight) {
            earned *= 2
        }

        // 规则牌：四面楚歌 — 手牌中每张2或A +10%
        if hasJoker(.highCardBonus) {
            let highCount = handCards.filter { $0.rank == .two || $0.rank == .ace }.count
            if highCount > 0 {
                earned = Int(Double(earned) * (1.0 + Double(highCount) * 0.1))
            }
        }

        // 规则牌：成双成对 — 对子×2
        if hasJoker(.pairMastery) && pattern.type == .pair {
            earned *= 2
        }

        // 规则牌：三生万物 — 三带类+50%
        if hasJoker(.tripleThreat) &&
           (pattern.type == .triple || pattern.type == .tripleWithOne || pattern.type == .tripleWithPair) {
            earned = Int(Double(earned) * 1.5)
        }

        // 规则牌：心算如飞 — 出牌≥5张+40%
        if hasJoker(.cardCounter) && cards.count >= 5 {
            earned = Int(Double(earned) * 1.4)
        }

        // 规则牌：精打细算 — 出3张及以下+60%
        if hasJoker(.miniHandBonus) && cards.count <= 3 {
            earned = Int(Double(earned) * 1.6)
        }

        // 规则牌：厚积薄发 — 当前得分≥目标50%时+30%
        if hasJoker(.scoreSurge) && currentFloor.targetScore > 0 &&
           floorScore >= currentFloor.targetScore / 2 {
            earned = Int(Double(earned) * 1.3)
        }

        // 规则牌：连环杀 — 连击≥3时额外+20%
        if hasJoker(.multiKill) && combo >= 3 {
            earned = Int(Double(earned) * 1.2)
        }

        // 规则牌：破甲 — 上次出牌≥100分时+25%
        if hasJoker(.shieldBreaker) && lastScoreEarned >= 100 {
            earned = Int(Double(earned) * 1.25)
        }

        // ── 第三批规则牌效果 ──

        // 规则牌：暴击之手 — 10%概率双倍得分
        if hasJoker(.criticalHit) && Int.random(in: 0..<10) == 0 {
            earned *= 2
        }

        // 规则牌：同花顺缘 — 同花色出5张以上+50分
        if hasJoker(.collector) && cards.count >= 5 {
            let suits = Set(cards.compactMap { $0.suit })
            if suits.count == 1 { earned += 50 }
        }

        // 规则牌：夜枭 — 后半程(8-15关)得分+20%
        if hasJoker(.nightOwl) && currentFloor.floor >= 8 {
            earned = Int(Double(earned) * 1.2)
        }

        // 规则牌：先声夺人 — 每关第一手出牌+100分
        if hasJoker(.earlyBird) && combo == 1 {
            earned += 100
        }

        // 规则牌：守财奴 — 每持有50金币+5%
        if hasJoker(.miser) && gold >= 50 {
            let bonus = Double(gold / 50) * 0.05
            earned = Int(Double(earned) * (1.0 + bonus))
        }

        // 规则牌：赌徒之心 — 随机±30%得分（期望+5%）
        if hasJoker(.gambler) {
            let roll = Double.random(in: -0.30...0.40)  // avg +5%
            earned = max(1, Int(Double(earned) * (1.0 + roll)))
        }

        // 规则牌：神龙摆尾 — 连击达到5时下一手3倍
        if hasJoker(.dragon) && combo == 6 {
            earned *= 3
        }

        // 规则牌：逆转乾坤 — 得分<目标30%时+50%
        if hasJoker(.tideTurner) && effectiveTargetScore > 0 &&
           floorScore < effectiveTargetScore * 3 / 10 {
            earned = Int(Double(earned) * 1.5)
        }

        // === Boss 修改器 ===
        if let boss = bossState {
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
        }

        // 全局倍率
        earned = Int(Double(earned) * multiplier)

        floorScore += earned
        totalScore += earned
        lastScoreEarned = earned

        // 规则牌：点石成金 — 每次出牌+5金币
        if hasJoker(.goldRush) {
            gold += 5
            PlayerStats.shared.totalGoldEarned += 5
        }

        // 成就检测
        let tracker = AchievementTracker.shared
        if earned >= 200 { tracker.tryUnlock("single_200") }
        if earned >= 500 { tracker.tryUnlock("single_500") }
        if totalScore >= 500 { tracker.tryUnlock("score_500") }
        if totalScore >= 2000 { tracker.tryUnlock("score_2000") }
        if totalScore >= 5000 { tracker.tryUnlock("score_5000") }
        if combo >= 5 { tracker.tryUnlock("combo_5") }
        if pattern.type == .bomb { tracker.tryUnlock("bombs_10") }  // 简化：首次炸弹即解锁
        if pattern.type == .rocket { tracker.tryUnlock("rockets_5") }
        if activeJokers.count >= 5 { tracker.tryUnlock("jokers_collect_5") }
        if gold >= 300 { tracker.tryUnlock("gold_300") }

        // 从手牌移除
        let playedIds = Set(cards.map(\.id))
        handCards.removeAll { playedIds.contains($0.id) }

        // 规则牌：贪心鬼 — 出牌后额外抽1张
        if hasJoker(.drawAfterPlay) && !drawPile.isEmpty {
            handCards.append(drawPile.removeFirst())
            handCards.sort { $0.rank < $1.rank }
        }

        let result = PlayResult(
            pattern: pattern,
            score: earned,
            totalScore: floorScore,
            combo: combo,
            isFloorCleared: isFloorCleared
        )
        lastPlayResult = result
        phase = .scoring(result)

        // PlayerStats tracking
        let stats = PlayerStats.shared
        stats.totalCardsPlayed += cards.count
        if combo > stats.highestCombo { stats.highestCombo = combo }
        if earned > stats.highestSingleScore { stats.highestSingleScore = earned }
        stats.save()

        return result
    }

    /// 得分动画结束后调用
    func onScoringComplete() {
        if isFloorCleared {
            let bonus = currentFloor.targetScore / 10
            gold += bonus

            // PlayerStats: floor cleared
            PlayerStats.shared.totalFloors += 1
            PlayerStats.shared.totalGoldEarned += bonus
            PlayerStats.shared.save()

            // 成就检测
            let tracker = AchievementTracker.shared
            if currentFloorIndex == 0 { tracker.tryUnlock("first_win") }
            if currentFloorIndex >= 4 { tracker.tryUnlock("mid_run") }
            if discardsRemaining == currentFloor.maxDiscards { tracker.tryUnlock("no_discard_win") }

            Analytics.shared.track(.levelComplete, level: currentFloor.floor)
            phase = .floorWin
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
            phase = .floorFail
        } else {
            phase = .selecting
        }
    }

    /// 换牌（弃掉选中的牌，从牌堆抽等量新牌）
    func discardCards(_ cards: [Card]) -> Bool {
        guard phase == .selecting, discardsRemaining > 0, !cards.isEmpty else {
            return false
        }

        discardsRemaining -= 1
        combo = max(0, combo - 1)  // 换牌仅减少1点连击，不清零

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
            handCards.sort { $0.rank < $1.rank }
        }

        // 换牌后如果手牌空了且没达标
        if handCards.isEmpty && !isFloorCleared {
            phase = .floorFail
        }

        return true
    }

    /// 进入下一层
    func advanceToNextFloor() {
        currentFloorIndex += 1
        if currentFloorIndex >= FloorConfig.allFloors.count {
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
            // PlayerStats: record win and play time
            PlayerStats.shared.totalWins += 1
            if let start = runStartTime {
                PlayerStats.shared.totalPlayTime += Date().timeIntervalSince(start)
                runStartTime = nil
            }
            PlayerStats.shared.save()
            phase = .victory
        } else {
            startFloor()
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

        // PlayerStats: end previous run timer & start new run
        if let start = runStartTime {
            PlayerStats.shared.addPlayTime(Date().timeIntervalSince(start))
        }
        runStartTime = Date()
        currentBuildId = build.id
        PlayerStats.shared.totalRuns += 1
        PlayerStats.shared.recordBuildUsage(build.id)

        if let joker = build.startingJoker {
            activeJokers.append(joker)
        }
        if let buff = build.startingBuff {
            activeBuffs.append(buff)
        }

        startFloor()
    }

    /// 重新开始整个游戏
    func restart() {
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
        return true
    }

    /// 购买规则牌
    func buyJoker(_ joker: Joker, cost: Int) -> Bool {
        guard gold >= cost else { return false }
        guard activeJokers.count < Joker.maxSlots else { return false }
        gold -= cost
        activeJokers.append(joker)
        return true
    }
}

struct PlayResult: Equatable {
    let pattern: CardPattern
    let score: Int
    let totalScore: Int
    let combo: Int
    let isFloorCleared: Bool

    static func == (lhs: PlayResult, rhs: PlayResult) -> Bool {
        lhs.score == rhs.score && lhs.totalScore == rhs.totalScore && lhs.combo == rhs.combo
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
        case .globalMultiplier:
            return Int(Double(score) * value)
        case .bombBonus:
            return pattern.type == .bomb ? score + Int(value) : score
        case .rocketBonus:
            return pattern.type == .rocket ? score + Int(value) : score
        case .straightBonus:
            return pattern.type == .straight ? Int(Double(score) * value) : score
        case .planeBonus:
            return pattern.type == .plane || pattern.type == .planeWithWings
                ? Int(Double(score) * value) : score
        }
    }
}

enum BuffType: String, Codable, Hashable {
    case globalMultiplier   // 全局倍率提升
    case bombBonus          // 炸弹额外加分
    case rocketBonus        // 火箭额外加分
    case straightBonus      // 顺子倍率
    case planeBonus         // 飞机倍率
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
    ]
}
