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
    let maxPlays: Int        // 出牌次数上限
    let maxDiscards: Int     // 弃牌次数上限
    let description: String
    let isShop: Bool

    static let allFloors: [FloorConfig] = [
        // === 第一章：乡野篇 ===
        FloorConfig(floor: 1, name: "乡野牌局", targetScore: 200, maxPlays: 5, maxDiscards: 3,
                    description: "村口老槐树下的牌局", isShop: false),
        FloorConfig(floor: 2, name: "集市赌坊", targetScore: 320, maxPlays: 5, maxDiscards: 3,
                    description: "赶集路上遇到的牌摊", isShop: false),
        FloorConfig(floor: 3, name: "茶馆对弈", targetScore: 450, maxPlays: 5, maxDiscards: 2,
                    description: "茶馆里的老牌手", isShop: false),
        FloorConfig(floor: 4, name: "杂货铺", targetScore: 0, maxPlays: 0, maxDiscards: 0,
                    description: "补充装备，继续上路", isShop: true),
        // === 第二章：府城篇 ===
        FloorConfig(floor: 5, name: "县城擂台", targetScore: 600, maxPlays: 5, maxDiscards: 2,
                    description: "县城里的斗地主擂台", isShop: false),
        FloorConfig(floor: 6, name: "府衙暗局", targetScore: 800, maxPlays: 4, maxDiscards: 2,
                    description: "知府大人设下的暗局", isShop: false),
        FloorConfig(floor: 7, name: "赌神酒楼", targetScore: 1000, maxPlays: 4, maxDiscards: 2,
                    description: "江湖传说中的赌神地盘", isShop: false),
        FloorConfig(floor: 8, name: "兵器铺", targetScore: 0, maxPlays: 0, maxDiscards: 0,
                    description: "精良的装备等着你", isShop: true),
        // === 第三章：江湖篇 ===
        FloorConfig(floor: 9, name: "镖局较量", targetScore: 1300, maxPlays: 4, maxDiscards: 1,
                    description: "押镖路上遇到的高手", isShop: false),
        FloorConfig(floor: 10, name: "武林大会", targetScore: 1600, maxPlays: 4, maxDiscards: 1,
                    description: "各路英雄齐聚一堂", isShop: false),
        FloorConfig(floor: 11, name: "皇城暗影", targetScore: 2000, maxPlays: 4, maxDiscards: 1,
                    description: "京城地下赌场", isShop: false),
        FloorConfig(floor: 12, name: "藏宝阁", targetScore: 0, maxPlays: 0, maxDiscards: 0,
                    description: "最后的准备机会", isShop: true),
        // === 终章：登顶 ===
        FloorConfig(floor: 13, name: "王府密室", targetScore: 2500, maxPlays: 3, maxDiscards: 1,
                    description: "王爷的私人牌局", isShop: false),
        FloorConfig(floor: 14, name: "天牢赌命", targetScore: 3200, maxPlays: 3, maxDiscards: 1,
                    description: "以命相搏的最终对决", isShop: false),
        FloorConfig(floor: 15, name: "斗破乾坤", targetScore: 4000, maxPlays: 3, maxDiscards: 0,
                    description: "最终Boss：地主之王——无弃牌机会！", isShop: false),
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

    /// 剩余牌堆（弃牌后从中补牌）
    private(set) var drawPile: [Card] = []

    var currentFloor: FloorConfig {
        FloorConfig.allFloors[currentFloorIndex]
    }

    var floorProgress: Double {
        guard currentFloor.targetScore > 0 else { return 1.0 }
        return min(1.0, Double(floorScore) / Double(currentFloor.targetScore))
    }

    var isFloorCleared: Bool {
        floorScore >= currentFloor.targetScore
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

        // 规则牌：暗度陈仓 — 每关换牌次数+2
        if hasJoker(.extraDiscards) {
            discardsRemaining += 2
        }

        // 规则牌：回光返照 — 每关额外出牌+1
        if hasJoker(.secondWind) {
            playsRemaining += 1
        }

        // 发牌（Roguelike 模式：10张手牌 + 44张牌堆）
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

        // 全局倍率
        earned = Int(Double(earned) * multiplier)

        floorScore += earned
        totalScore += earned
        lastScoreEarned = earned

        // 规则牌：点石成金 — 每次出牌+5金币
        if hasJoker(.goldRush) {
            gold += 5
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

        return result
    }

    /// 得分动画结束后调用
    func onScoringComplete() {
        if isFloorCleared {
            let bonus = currentFloor.targetScore / 10
            gold += bonus

            // 成就检测
            let tracker = AchievementTracker.shared
            if currentFloorIndex == 0 { tracker.tryUnlock("first_win") }
            if currentFloorIndex >= 4 { tracker.tryUnlock("mid_run") }
            if discardsRemaining == currentFloor.maxDiscards { tracker.tryUnlock("no_discard_win") }

            Analytics.shared.track(.levelComplete, level: currentFloor.floor)
            phase = .floorWin
        } else if playsRemaining <= 0 || handCards.isEmpty {
            Analytics.shared.track(.levelFail, level: currentFloor.floor)
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
            AchievementTracker.shared.tryUnlock("wins_5") // 简化：首次通关即解锁
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
        multiplier = 1.0
        activeBuffs = []
        activeJokers = []
        combo = 0
        drawPile = []
        lastScoreEarned = 0

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
        Buff(name: "火药桶", description: "炸弹得分 +60", type: .bombBonus, value: 60, icon: "🧨"),
        Buff(name: "冲天炮", description: "火箭得分 +120", type: .rocketBonus, value: 120, icon: "🚀"),
        Buff(name: "顺风车", description: "顺子得分 ×2", type: .straightBonus, value: 2.0, icon: "🚗"),
        Buff(name: "大阅兵", description: "飞机得分 ×2.5", type: .planeBonus, value: 2.5, icon: "✈️"),
        Buff(name: "翻倍符", description: "全局得分 ×1.5", type: .globalMultiplier, value: 1.5, icon: "🔮"),
        Buff(name: "财神爷", description: "全局得分 ×1.3", type: .globalMultiplier, value: 1.3, icon: "💰"),
        Buff(name: "双响炮", description: "炸弹得分 +100", type: .bombBonus, value: 100, icon: "🎆"),
        Buff(name: "铁索连舟", description: "顺子得分 ×2.5", type: .straightBonus, value: 2.5, icon: "⛓️"),
        Buff(name: "空中堡垒", description: "飞机得分 ×3", type: .planeBonus, value: 3.0, icon: "🏰"),
        Buff(name: "神来之手", description: "全局得分 ×2", type: .globalMultiplier, value: 2.0, icon: "🌟"),
    ]
}
