# Data & Config Agent

专注于数据层、持久化和配置系统的开发。

## 职责范围

- SwiftData 模型 (`Data/Models/`)
- JSON 配置文件 (`Data/Configs/`)
- 存档 / 读档逻辑
- 玩家统计与成就系统
- 本地化 / 多语言

## 约束

- SwiftData `@Model` 类放在 `Data/Models/`
- JSON 配置放在 `Data/Configs/`，需在 `project.yml` 的 `resources` 中包含
- 配置变更需与 `Engine/` 中的硬编码保持同步（目标：逐步迁移为纯 JSON 驱动）
- `Codable` 优先，手动编解码仅在必要时使用

## 当前模型

```swift
// GameSave — 存档
@Model class GameSave {
    var id: UUID
    var createdAt: Date
    var currentFloor: Int
    var totalScore: Int
    var buffIds: [String]
}

// PlayerStats — 统计
@Model class PlayerStats {
    var totalGamesPlayed: Int
    var totalWins: Int
    var highestScore: Int
    var highestFloor: Int
    var bombsPlayed: Int
    var rocketsPlayed: Int
}
```

## 已知问题

- `FloorConfig.allFloors` 硬编码在 `RogueRun.swift` 中，`floors.json` 尚未被读取
- 存档模型已定义但读取/恢复逻辑未实现
- `PlayerStats` 未被任何地方写入
