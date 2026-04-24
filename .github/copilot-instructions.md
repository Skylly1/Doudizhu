# Copilot Instructions — 斗破乾坤 (Doudizhu Roguelike)

## 项目概述

这是一款 **Roguelike 斗地主** 单机 iOS 游戏，灵感来自 Balatro，用中国斗地主牌型体系替代西方扑克规则。玩家通过打出牌型（顺子/炸弹/飞机等）得分，收集 Buff 构筑卡组，闯过 8 层关卡击败 Boss 地主。

- **产品名**：斗破乾坤
- **商业模式**：买断制（¥25~45 / $4.99~$6.99）
- **目标平台**：iOS 17+（后续 Steam）
- **美术风格**：国潮水墨风

## 技术栈

| 模块 | 技术 | 说明 |
|------|------|------|
| 语言 | **Swift 6.0** | 启用 strict concurrency |
| UI 层 | **SwiftUI** | 菜单、地图、商店、设置 |
| 游戏渲染 | **SpriteKit** | 牌桌场景、卡牌动画、特效 |
| 桥接 | `SpriteView` | SwiftUI 内嵌 SpriteKit |
| 数据持久化 | **SwiftData** | `@Model` 存档、统计 |
| 配置数据 | **JSON** | `Doudizhu/Data/Configs/` |
| 构建系统 | **XcodeGen** (`project.yml`) | 不要直接编辑 `.xcodeproj` |

## 项目结构

```
Doudizhu/
├── App/                    # 入口 (DoudizhuApp, ContentView)
├── Features/               # SwiftUI 页面（按功能模块组织）
│   ├── Home/               # 主菜单
│   ├── Map/                # Roguelike 地图
│   ├── Shop/               # 构筑商店
│   ├── Collection/         # 卡牌收集（待开发）
│   └── Settings/           # 设置
├── GameScene/              # SpriteKit 牌桌场景
│   ├── BattleScene.swift   # SKScene 主场景
│   ├── BattleView.swift    # SwiftUI 包装 + HUD
│   └── CardNode.swift      # 卡牌节点
├── Engine/                 # 核心游戏逻辑（纯 Swift，无 UI 依赖）
│   ├── Card.swift          # Suit, Rank, Card, Deck
│   ├── CardPattern.swift   # PatternType, CardPattern, PatternRecognizer
│   └── RogueRun.swift      # GamePhase, FloorConfig, RogueRun, Buff
├── AI/                     # AI 对手
│   └── AIPlayer.swift      # AIPlayerProtocol, RuleBasedAI
├── Data/
│   ├── Models/             # SwiftData 模型 (GameSave, PlayerStats)
│   └── Configs/            # JSON 配置 (floors.json)
└── Resources/              # 资源文件 (Assets.xcassets)
```

## 领域知识：斗地主规则

### 牌面大小（从小到大）
3 < 4 < 5 < 6 < 7 < 8 < 9 < 10 < J < Q < K < A < 2 < 小王 < 大王

### 牌型体系
| 牌型 | 英文标识 | 说明 |
|------|---------|------|
| 单张 | `single` | 任意一张牌 |
| 对子 | `pair` | 两张相同点数 |
| 三条 | `triple` | 三张相同点数 |
| 三带一 | `tripleWithOne` | 三条 + 1张 |
| 三带二 | `tripleWithPair` | 三条 + 1对 |
| 顺子 | `straight` | 5+ 连续单张（不含2和王） |
| 连对 | `pairStraight` | 3+ 连续对子（不含2和王） |
| 飞机 | `plane` | 2+ 连续三条 |
| 飞机带翅膀 | `planeWithWings` | 飞机 + 等量单张或对子 |
| 炸弹 | `bomb` | 四张相同点数 |
| 火箭 | `rocket` | 大小王 |
| 四带二 | `fourWithTwo` | 四张 + 2单张 |

### Roguelike 机制
- **计分制**（非传统对战）：打出牌型得分，达到目标分过关
- **Buff 系统**：商店购买增益（炸弹加分、顺子倍率等）
- **连击系统**：连续出牌累积 combo 加成
- **弃牌机制**：不消耗出牌次数，但打断连击

## 编码规范

### Swift 风格
- 使用 `// MARK: -` 分隔代码区域
- 中文注释描述业务逻辑，英文命名标识符
- 枚举优先用 `switch` 穷举，不用 `default`
- SwiftUI View 拆分为 computed property（如 `private var topBar: some View`）
- SpriteKit 节点动画用 `SKAction` 链式组合

### 架构约定
- **Engine/ 模块禁止导入 UIKit/SwiftUI/SpriteKit**——纯逻辑层，方便单元测试
- `RogueRun` 是核心状态机，用 `@Published` 驱动 SwiftUI 响应式更新
- SwiftUI ↔ SpriteKit 通过 `rogueRun` 共享引用通信
- 新 Feature 页面放入 `Features/{FeatureName}/` 目录
- 新 SpriteKit 节点放入 `GameScene/`

### 命名约定
- 牌型用 `PatternType` 枚举值（如 `.bomb`, `.rocket`）
- Buff 用 `BuffType` 枚举值（如 `.globalMultiplier`, `.bombBonus`）
- 关卡配置用 `FloorConfig`
- 游戏阶段用 `GamePhase` 枚举
- AI 难度用 `AIDifficulty`（`.easy`, `.medium`, `.hard`, `.boss`）

### 构建
- 使用 `xcodegen generate` 从 `project.yml` 生成 Xcode 项目
- 新文件/目录需同步更新 `project.yml`（如有需要）
- 最低部署目标：iOS 17.0

## 当前开发状态

### ✅ 已完成
- 卡牌数据模型（54张牌、花色、点数）
- 完整牌型识别器（12种牌型）
- Roguelike 核心循环（发牌→选牌→出牌→计分→过关/失败）
- Buff 系统（5种预设 Buff + 商店购买）
- SpriteKit 牌桌场景（手牌布局、选牌交互、出牌动画）
- SwiftUI 全套页面（主菜单、地图、商店、对战HUD）
- 基础 AI（RuleBasedAI：单张、对子、炸弹跟牌）
- SwiftData 存档模型

### 🚧 待开发
- 水墨风美术资源 & SKShader 特效
- 完整 AI（三带一/顺子/飞机等牌型的跟牌逻辑、MCTS、CoreML）
- 卡牌收藏图鉴（CollectionView 待实现）
- 音效 & 背景音乐（AVFoundation）
- 存档读取功能
- 更多 Buff / 特殊卡牌
- 从 JSON 配置加载关卡（目前硬编码 + JSON 并存）
- 教学引导
- 多语言（中英双语）
