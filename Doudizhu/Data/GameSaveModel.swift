import Foundation
import SwiftData

// MARK: - 存档模型（SwiftData）

/// 游戏存档 — 精确保存 RogueRun 状态以支持断点续玩
@Model
final class GameSaveModel {
    var runId: String
    var timestamp: Date

    // MARK: 关卡状态
    var currentFloorIndex: Int
    var floorScore: Int
    var totalScore: Int
    var playsRemaining: Int
    var discardsRemaining: Int
    var gold: Int
    var multiplier: Double
    var combo: Int
    var lastScoreEarned: Int
    var ascensionLevel: Int
    var phoenixUsed: Bool

    // MARK: 卡牌状态（JSON 编码）
    var handCardsData: Data      // [Card] JSON
    var drawPileData: Data       // [Card] JSON

    // MARK: 构筑状态（JSON 编码）
    var activeJokersData: Data   // [Joker] JSON
    var activeBuffsData: Data    // [Buff] JSON

    // MARK: 排序/Build
    var handSortModeRaw: String  // HandSortMode.rawValue
    var starterBuildId: String

    // MARK: 游戏阶段
    var phaseRaw: String         // "selecting" / "dealing" / etc.

    // MARK: 每日挑战
    var isDailyChallenge: Bool

    init(
        runId: String = UUID().uuidString,
        timestamp: Date = Date(),
        currentFloorIndex: Int = 0,
        floorScore: Int = 0,
        totalScore: Int = 0,
        playsRemaining: Int = 0,
        discardsRemaining: Int = 0,
        gold: Int = 150,
        multiplier: Double = 1.0,
        combo: Int = 0,
        lastScoreEarned: Int = 0,
        ascensionLevel: Int = 0,
        phoenixUsed: Bool = false,
        handCardsData: Data = Data(),
        drawPileData: Data = Data(),
        activeJokersData: Data = Data(),
        activeBuffsData: Data = Data(),
        handSortModeRaw: String = "rank",
        starterBuildId: String = "",
        phaseRaw: String = "selecting",
        isDailyChallenge: Bool = false
    ) {
        self.runId = runId
        self.timestamp = timestamp
        self.currentFloorIndex = currentFloorIndex
        self.floorScore = floorScore
        self.totalScore = totalScore
        self.playsRemaining = playsRemaining
        self.discardsRemaining = discardsRemaining
        self.gold = gold
        self.multiplier = multiplier
        self.combo = combo
        self.lastScoreEarned = lastScoreEarned
        self.ascensionLevel = ascensionLevel
        self.phoenixUsed = phoenixUsed
        self.handCardsData = handCardsData
        self.drawPileData = drawPileData
        self.activeJokersData = activeJokersData
        self.activeBuffsData = activeBuffsData
        self.handSortModeRaw = handSortModeRaw
        self.starterBuildId = starterBuildId
        self.phaseRaw = phaseRaw
        self.isDailyChallenge = isDailyChallenge
    }
}

// MARK: - RogueRun ↔ GameSaveModel 转换

extension GameSaveModel {
    /// 从 RogueRun 快照创建存档
    @MainActor static func snapshot(from run: RogueRun, buildId: String) -> GameSaveModel {
        let encoder = JSONEncoder()
        let handData = (try? encoder.encode(run.handCards)) ?? Data()
        let drawData = (try? encoder.encode(run.drawPile)) ?? Data()
        let jokersData = (try? encoder.encode(run.activeJokers)) ?? Data()
        let buffsData = (try? encoder.encode(run.activeBuffs)) ?? Data()

        let phaseString: String
        switch run.phase {
        case .selecting: phaseString = "selecting"
        case .dealing: phaseString = "dealing"
        case .shopping: phaseString = "shopping"
        case .floorWin: phaseString = "floorWin"
        case .floorFail: phaseString = "floorFail"
        case .victory: phaseString = "victory"
        default: phaseString = "selecting"
        }

        return GameSaveModel(
            runId: UUID().uuidString,
            timestamp: Date(),
            currentFloorIndex: run.currentFloorIndex,
            floorScore: run.floorScore,
            totalScore: run.totalScore,
            playsRemaining: run.playsRemaining,
            discardsRemaining: run.discardsRemaining,
            gold: run.gold,
            multiplier: run.multiplier,
            combo: run.combo,
            lastScoreEarned: run.lastScoreEarned,
            ascensionLevel: run.ascensionLevel,
            phoenixUsed: run.phoenixUsed,
            handCardsData: handData,
            drawPileData: drawData,
            activeJokersData: jokersData,
            activeBuffsData: buffsData,
            handSortModeRaw: run.handSortMode.rawValue,
            starterBuildId: buildId,
            phaseRaw: phaseString,
            isDailyChallenge: run.dailyChallenge != nil
        )
    }

    /// 将存档恢复到 RogueRun
    @MainActor func restore(to run: RogueRun) {
        let decoder = JSONDecoder()

        run.currentFloorIndex = currentFloorIndex
        run.floorScore = floorScore
        run.totalScore = totalScore
        run.playsRemaining = playsRemaining
        run.discardsRemaining = discardsRemaining
        run.gold = gold
        run.multiplier = multiplier
        run.combo = combo
        run.lastScoreEarned = lastScoreEarned
        run.ascensionLevel = ascensionLevel
        run.phoenixUsed = phoenixUsed
        run.handSortMode = HandSortMode(rawValue: handSortModeRaw) ?? .byRank

        run.handCards = (try? decoder.decode([Card].self, from: handCardsData)) ?? []
        run.drawPile = (try? decoder.decode([Card].self, from: drawPileData)) ?? []
        run.activeJokers = (try? decoder.decode([Joker].self, from: activeJokersData)) ?? []
        run.activeBuffs = (try? decoder.decode([Buff].self, from: activeBuffsData)) ?? []

        // 每日挑战恢复
        run.dailyChallenge = isDailyChallenge ? DailyChallenge.today : nil

        run.playHistory = []
        run.lastPlayResult = nil

        // 根据保存时的阶段智能恢复
        switch phaseRaw {
        case "floorWin":
            // 已过关 — 推进到下一层（会发新手牌）
            run.advanceToNextFloor()
        case "shopping":
            // 在商店中 — 保持商店阶段，由调用方导航到商店页面
            run.phase = .shopping
        default:
            // "selecting" / "dealing" 等 — 恢复为选牌状态
            // 越界保护（防止关卡配置变更导致崩溃）
            guard currentFloorIndex >= 0,
                  currentFloorIndex < FloorConfig.allFloors.count else {
                run.phase = .victory
                return
            }
            // Boss 关需要重新初始化 BossState
            let floor = FloorConfig.allFloors[currentFloorIndex]
            if floor.isBoss {
                run.bossState = BossState(modifiers: floor.bossModifiers)
            }
            run.phase = .selecting
            // 安全兜底：若手牌为空（异常存档），重新发牌
            if run.handCards.isEmpty {
                run.startFloor()
            }
        }
    }
}

// MARK: - 存档管理器

@MainActor
final class SaveManager {
    static let shared = SaveManager()
    private init() {}

    private var modelContext: ModelContext?

    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    /// 保存当前游戏状态（按槽位隔离：主线 vs 每日挑战）
    func save(run: RogueRun, buildId: String) {
        guard let context = modelContext else { return }
        let isDaily = run.dailyChallenge != nil
        // 只删除同槽位旧存档
        let all = (try? context.fetch(FetchDescriptor<GameSaveModel>())) ?? []
        for old in all where old.isDailyChallenge == isDaily {
            context.delete(old)
        }
        let save = GameSaveModel.snapshot(from: run, buildId: buildId)
        context.insert(save)
        try? context.save()
    }

    /// 检查是否有主线存档
    var hasSavedGame: Bool {
        guard let context = modelContext else { return false }
        let all = (try? context.fetch(FetchDescriptor<GameSaveModel>())) ?? []
        return all.contains { !$0.isDailyChallenge }
    }

    /// 检查是否有每日挑战存档
    var hasDailySave: Bool {
        guard let context = modelContext else { return false }
        let all = (try? context.fetch(FetchDescriptor<GameSaveModel>())) ?? []
        return all.contains { $0.isDailyChallenge }
    }

    /// 读取主线存档
    func loadSave() -> GameSaveModel? {
        guard let context = modelContext else { return nil }
        let all = (try? context.fetch(FetchDescriptor<GameSaveModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        ))) ?? []
        return all.first { !$0.isDailyChallenge }
    }

    /// 读取每日挑战存档
    func loadDailySave() -> GameSaveModel? {
        guard let context = modelContext else { return nil }
        let all = (try? context.fetch(FetchDescriptor<GameSaveModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        ))) ?? []
        return all.first { $0.isDailyChallenge }
    }

    /// 删除主线存档
    func clearSaves() {
        guard let context = modelContext else { return }
        let all = (try? context.fetch(FetchDescriptor<GameSaveModel>())) ?? []
        for old in all where !old.isDailyChallenge {
            context.delete(old)
        }
        try? context.save()
    }

    /// 删除每日挑战存档
    func clearDailySaves() {
        guard let context = modelContext else { return }
        let all = (try? context.fetch(FetchDescriptor<GameSaveModel>())) ?? []
        for old in all where old.isDailyChallenge {
            context.delete(old)
        }
        try? context.save()
    }

    /// 删除所有存档（重置用）
    func clearAllSaves() {
        guard let context = modelContext else { return }
        let all = (try? context.fetch(FetchDescriptor<GameSaveModel>())) ?? []
        for old in all { context.delete(old) }
        try? context.save()
    }
}
