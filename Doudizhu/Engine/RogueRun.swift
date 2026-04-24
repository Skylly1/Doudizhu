import Foundation

// MARK: - Roguelike 核心

/// 一次 Roguelike 冒险运行
class RogueRun: ObservableObject {
    @Published var currentFloor: Int = 1        // 当前层数
    @Published var score: Int = 0               // 总分
    @Published var multiplier: Double = 1.0     // 全局倍率
    @Published var gold: Int = 100              // 金币（商店用）
    @Published var activeBuffs: [Buff] = []     // 激活的 Buff
    @Published var isGameOver: Bool = false
    @Published var handCards: [Card] = []       // 当前手牌

    let totalFloors: Int = 8                    // 每轮总层数
    let targetScore: Int                        // 本层目标分数

    init() {
        self.targetScore = 300
    }

    /// 开始新层
    func startFloor() {
        let deal = Deck.deal()
        handCards = deal.player
    }

    /// 打出牌型，计算得分
    func playCards(_ cards: [Card]) -> PlayResult? {
        guard let pattern = PatternRecognizer.recognize(cards) else {
            return nil
        }

        // 基础分
        var earnedScore = pattern.baseScore

        // 应用 Buff 加成
        for buff in activeBuffs {
            earnedScore = buff.apply(to: earnedScore, pattern: pattern)
        }

        // 全局倍率
        earnedScore = Int(Double(earnedScore) * multiplier)

        score += earnedScore

        // 从手牌中移除
        let playedIds = Set(cards.map(\.id))
        handCards.removeAll { playedIds.contains($0.id) }

        return PlayResult(pattern: pattern, score: earnedScore, totalScore: score)
    }

    /// 进入下一层
    func advanceFloor() {
        currentFloor += 1
        if currentFloor > totalFloors {
            isGameOver = true
        }
    }
}

struct PlayResult {
    let pattern: CardPattern
    let score: Int
    let totalScore: Int
}

// MARK: - Buff 系统

struct Buff: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let type: BuffType
    let value: Double

    init(name: String, description: String, type: BuffType, value: Double) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.type = type
        self.value = value
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
        Buff(name: "火药桶", description: "炸弹得分 +50", type: .bombBonus, value: 50),
        Buff(name: "冲天炮", description: "火箭得分 +100", type: .rocketBonus, value: 100),
        Buff(name: "顺风车", description: "顺子得分 ×2", type: .straightBonus, value: 2.0),
        Buff(name: "大阅兵", description: "飞机得分 ×2.5", type: .planeBonus, value: 2.5),
        Buff(name: "翻倍符", description: "全局得分 ×1.5", type: .globalMultiplier, value: 1.5),
    ]
}
