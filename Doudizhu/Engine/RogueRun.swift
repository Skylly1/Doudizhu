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
        FloorConfig(floor: 1, name: "乡野牌局", targetScore: 200, maxPlays: 5, maxDiscards: 3, description: "村口老槐树下的牌局", isShop: false),
        FloorConfig(floor: 2, name: "集市赌坊", targetScore: 300, maxPlays: 5, maxDiscards: 3, description: "赶集路上遇到的牌摊", isShop: false),
        FloorConfig(floor: 3, name: "茶馆对弈", targetScore: 450, maxPlays: 5, maxDiscards: 2, description: "茶馆里的老牌手", isShop: false),
        FloorConfig(floor: 4, name: "杂货铺", targetScore: 0, maxPlays: 0, maxDiscards: 0, description: "补充装备，再上路", isShop: true),
        FloorConfig(floor: 5, name: "县城擂台", targetScore: 600, maxPlays: 4, maxDiscards: 2, description: "县城里的斗地主擂台", isShop: false),
        FloorConfig(floor: 6, name: "府衙暗局", targetScore: 800, maxPlays: 4, maxDiscards: 2, description: "知府大人设下的暗局", isShop: false),
        FloorConfig(floor: 7, name: "杂货铺", targetScore: 0, maxPlays: 0, maxDiscards: 0, description: "最后的准备机会", isShop: true),
        FloorConfig(floor: 8, name: "地主庄园", targetScore: 1200, maxPlays: 4, maxDiscards: 1, description: "终极Boss：恶霸地主", isShop: false),
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

        // 发牌（Roguelike 模式：10张手牌 + 44张牌堆）
        let deal = Deck.dealRoguelike(handSize: 10)
        handCards = deal.hand
        drawPile = deal.drawPile
        phase = .selecting
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

        // 全局倍率
        earned = Int(Double(earned) * multiplier)

        floorScore += earned
        totalScore += earned

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
            // 过关奖励金币
            let bonus = currentFloor.targetScore / 10
            gold += bonus
            phase = .floorWin
        } else if playsRemaining <= 0 || handCards.isEmpty {
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
            let drawn = Array(drawPile.prefix(drawCount))
            drawPile.removeFirst(drawCount)
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
            phase = .victory
        } else {
            startFloor()
        }
    }

    /// 商店购买后继续
    func leaveShop() {
        advanceToNextFloor()
    }

    /// 重新开始整个游戏
    func restart() {
        currentFloorIndex = 0
        totalScore = 0
        gold = 150
        multiplier = 1.0
        activeBuffs = []
        activeJokers = []
        combo = 0
        drawPile = []
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
    ]
}
