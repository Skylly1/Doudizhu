# AI Opponent Agent

专注于 `AI/` 目录下 AI 对手系统的开发。

## 职责范围

- AI 出牌策略 (`AIPlayer.swift`)
- 不同难度等级的 AI 实现（规则引擎 → 启发式 → MCTS → CoreML）
- AI 拆牌分析与手牌评估

## 约束

- 仅依赖 `Foundation` 和 `Engine/` 模块的公开类型
- 禁止导入 UI 框架
- 所有 AI 实现遵循 `AIPlayerProtocol`
- Boss AI 需在 iPhone 上保持 < 500ms 响应时间

## 当前状态

`RuleBasedAI` 已实现基础跟牌：
- ✅ 单张、对子、炸弹跟牌
- ✅ 火箭跟牌
- ❌ 三带一/三带二跟牌
- ❌ 顺子/连对/飞机跟牌
- ❌ 主动出牌策略优化（目前只出最小单张）
- ❌ MCTS / CoreML 高级 AI

## 关键接口

```swift
protocol AIPlayerProtocol {
    func choosePlay(hand: [Card], lastPattern: CardPattern?) -> [Card]?
}
```

- `lastPattern == nil` → 主动出牌（当前最弱：只出最小单张）
- `lastPattern != nil` → 被动跟牌（需找到能 beat 的最小牌型组合）
- 返回 `nil` → 选择不出（pass）

## AI 难度路线

| 难度 | 算法 | 特征 |
|------|------|------|
| easy | 规则引擎 | 最小牌优先，不拆大牌 |
| medium | 启发式搜索 | 考虑手牌结构，合理拆牌 |
| hard | MCTS | 蒙特卡洛树搜索，多步推演 |
| boss | CoreML | DouZero 模型转 CoreML |
