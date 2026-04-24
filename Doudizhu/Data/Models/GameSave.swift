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
        self.currentFloor = rogueRun.currentFloorIndex
        self.totalScore = rogueRun.totalScore
        self.buffIds = rogueRun.activeBuffs.map { $0.id.uuidString }
    }
}
