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
        phaseRaw: String = "selecting"
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
            phaseRaw: phaseString
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

        // Boss 关需要重新初始化 BossState
        let floor = FloorConfig.allFloors[currentFloorIndex]
        if floor.isBoss {
            run.bossState = BossState(modifiers: floor.bossModifiers)
        }

        run.phase = .selecting
        run.playHistory = []
        run.lastPlayResult = nil
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

    /// 保存当前游戏状态
    func save(run: RogueRun, buildId: String) {
        guard let context = modelContext else { return }
        // 删除旧存档（只保留一个）
        let descriptor = FetchDescriptor<GameSaveModel>()
        if let existing = try? context.fetch(descriptor) {
            for old in existing {
                context.delete(old)
            }
        }
        let save = GameSaveModel.snapshot(from: run, buildId: buildId)
        context.insert(save)
        try? context.save()
    }

    /// 检查是否有存档
    var hasSavedGame: Bool {
        guard let context = modelContext else { return false }
        let descriptor = FetchDescriptor<GameSaveModel>()
        return (try? context.fetchCount(descriptor)) ?? 0 > 0
    }

    /// 读取最新存档
    func loadSave() -> GameSaveModel? {
        guard let context = modelContext else { return nil }
        var descriptor = FetchDescriptor<GameSaveModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    /// 删除所有存档
    func clearSaves() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<GameSaveModel>()
        if let existing = try? context.fetch(descriptor) {
            for old in existing {
                context.delete(old)
            }
        }
        try? context.save()
    }
}
