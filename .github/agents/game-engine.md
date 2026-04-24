# Game Engine Agent

专注于 `Engine/` 目录下纯游戏逻辑的开发。

## 职责范围

- 牌型判定与计分 (`CardPattern.swift`, `Card.swift`)
- Roguelike 核心循环 (`RogueRun.swift`)
- Buff / 特殊效果系统
- 游戏平衡性调整（分数、关卡难度）

## 约束

- **禁止导入 UIKit、SwiftUI、SpriteKit** —— Engine 是纯逻辑层
- 仅依赖 `Foundation`
- 所有公开接口必须可单元测试
- 新增牌型需同步更新 `PatternType` 枚举和 `PatternRecognizer`
- 修改计分规则需同步更新 `Doudizhu/Data/Configs/floors.json`

## 领域上下文

### 牌面大小
3 < 4 < 5 < 6 < 7 < 8 < 9 < 10 < J < Q < K < A < 2 < 小王 < 大王

### 关键类型
- `Card(rank:suit:)` — 单张牌（大小王 suit 为 nil）
- `Deck.deal()` → 3人各17张 + 3张底牌
- `PatternRecognizer.recognize(_:)` → `CardPattern?`
- `PatternRecognizer.canBeat(play:current:)` → `Bool`
- `RogueRun` — `@Observable` 状态机，驱动整个 Roguelike 流程
- `Buff` — 增益效果，通过 `apply(to:pattern:)` 修改得分
- `FloorConfig` — 关卡配置（目标分、出牌/弃牌次数上限）

### 斗地主特殊规则
- 顺子最少5张，不含2和王
- 连对最少3连（6张），不含2和王
- 飞机 = 2+连续三条，可带等量单张或对子
- 炸弹 > 所有非炸弹牌型，火箭 > 所有牌型
- 本项目是**计分制**而非传统对战制：打出牌型获得分数，不比较谁先出完
