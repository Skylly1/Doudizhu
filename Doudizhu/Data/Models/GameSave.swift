import Foundation
import SwiftData

@Model
class GameSave {
    var id: UUID
    var createdAt: Date
    var currentFloor: Int
    var totalScore: Int
    var buffIds: [String]   // Buff ID 列表

    init(rogueRun: RogueRun) {
        self.id = UUID()
        self.createdAt = Date()
        self.currentFloor = rogueRun.currentFloor
        self.totalScore = rogueRun.score
        self.buffIds = rogueRun.activeBuffs.map { $0.id.uuidString }
    }
}

@Model
class PlayerStats {
    var totalGamesPlayed: Int = 0
    var totalWins: Int = 0
    var highestScore: Int = 0
    var highestFloor: Int = 0
    var bombsPlayed: Int = 0
    var rocketsPlayed: Int = 0

    init() {}
}
