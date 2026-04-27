# 交互革命设计文档

> **项目**: 斗破乾坤（Roguelike 斗地主）  
> **日期**: 2026-04-27  
> **目标**: 出牌手感自然化 + 付费转化漏斗优化 → App Store 上架就绪  

---

## 一、出牌手势系统

### 1.1 问题分析

当前交互：逐张 tap 选牌 → 底部按钮出牌。存在三个问题：

1. **多张选牌慢** — 选顺子需点 5 次，无法一笔滑选
2. **出牌无手感** — 按按钮 ≠ "甩牌"，缺乏爽感
3. **认知断裂** — 选牌在 SpriteKit 区域，操作按钮在 SwiftUI 区域，手要跨区移动

### 1.2 手势层级设计

按优先级从高到低：

| 手势 | 触发区域 | 动作 | 动画反馈 |
|------|---------|------|---------|
| **上滑** | 选中牌区域（dy > 60pt） | 出牌（等同出牌按钮） | 牌飞向牌桌中央 + 水墨粒子散开 |
| **下滑** | 选中牌区域（dy < -60pt） | 换牌/弃牌（等同换牌按钮） | 牌淡出 + 新牌从牌堆滑入 |
| **横滑** | 手牌区域（dx/dy > 2） | 滑过的牌全部 toggle 选中 | 逐张弹起 + UIImpactFeedbackGenerator(.light) |
| **单点** | 单张牌 | toggle 该牌选中 | 牌弹起/落下（保留原逻辑） |
| **双击** | 单张牌（tapCount == 2） | 自动选中包含该牌的"最佳牌型" | 相关牌依次弹起 + 牌型名闪现 |

### 1.3 横滑选牌规则

- `touchesBegan` 记录起始点和起始时间
- `touchesMoved` 中，当水平位移 > 20pt 且 dx/dy > 2 时，判定为横滑模式
- 横滑模式下，追踪手指经过的 CardNode（通过 `nodes(at:)` 检测）
- 新碰触的牌 toggle 选中状态，每张牌在一次横滑中只 toggle 一次
- `touchesEnded` 结束横滑模式
- 触感：每张新牌被碰触时触发 `UIImpactFeedbackGenerator(.light)`

### 1.4 上滑/下滑出牌规则

- 仅在 **有选中牌** 时生效
- `touchesEnded` 时计算 dy = end.y - start.y（SpriteKit 坐标系 y 向上）
- dy > 60pt → 触发出牌（等同 `rogueRun.playSelectedCards()`）
- dy < -60pt → 触发换牌（等同 `rogueRun.discardSelectedCards()`）
- 出牌前校验：`selectedPattern != nil`（上滑）或 `discardCount > 0`（下滑）
- 无效操作：牌短暂左右抖动 + `UINotificationFeedbackGenerator(.warning)`
- 触感：出牌成功 `UIImpactFeedbackGenerator(.medium)`

### 1.5 双击智能选牌

双击某张牌时，自动选中包含该牌的最高得分牌型：

**优先级**（与 PatternType 得分权重一致）：
1. 火箭 (rocket)
2. 炸弹 (bomb)
3. 飞机带翅膀 (planeWithWings) / 飞机 (plane)
4. 顺子 (straight) / 连对 (pairStraight)
5. 三带二 (tripleWithPair) / 三带一 (tripleWithOne)
6. 三条 (triple)
7. 对子 (pair)
8. 单张 (single)

**算法**：
- 遍历手牌，对每种可能的牌型组合调用 `PatternRecognizer.recognize()`
- 过滤出包含双击牌的组合
- 按 `chips × mult` 降序排列，选第一个
- 实现位置：`Engine/CardPattern.swift` 新增 `PatternRecognizer.bestPattern(containing:from:)` 方法

### 1.6 实时牌型预览增强

当前已有 `selectedPattern` 显示牌型名称。增强为：

```
┌─────────────────────────────┐
│  ✅ 顺子  ·  30 chips × 4 mult = 120  │
│  🃏 炸弹大师: +50 chips               │  ← Joker 效果预览
│  📊 预估总分: 170                       │
└─────────────────────────────┘
```

- 拆解显示 base chips / base mult / Joker 加成
- 如果选中牌不构成合法牌型：显示 `❌ 无法出牌` + 灰色文字
- 位置：`BattleView.swift` 的 `actionButtons` 区域上方

### 1.7 保留按钮兼容

出牌和换牌按钮 **保留不变**，作为手势的备选操作。理由：
- 新玩家可能不知道手势
- 辅助功能需要（VoiceOver 无法触发滑动手势）
- 手势引导 tooltip 在首次使用时出现一次，之后不再显示

### 1.8 实现范围

**文件变更：**

| 文件 | 变更 |
|------|------|
| `GameScene/BattleScene.swift` | touchesBegan/Moved/Ended 重写，新增横滑/上滑/下滑手势识别 |
| `GameScene/CardNode.swift` | 新增 `isSwipeSelected` 状态追踪（防止横滑重复 toggle） |
| `Engine/CardPattern.swift` | 新增 `PatternRecognizer.bestPattern(containing:from:)` |
| `Features/Battle/BattleView.swift` | 牌型预览增强（chips × mult 拆解 + Joker 效果） |

---

## 二、付费转化漏斗优化

### 2.1 当前状态

DemoGateView 已有较好的基础设计：
- ✅ 祝贺过渡头部（缓解付费墙突兀感）
- ✅ 试玩成绩回顾（情感锚点：层数/最高分/最高连击）
- ✅ 当前装备展示（损失规避：Joker 和 Buff 列表）
- ✅ 内容预览（锁定关卡展示）
- ✅ 进度条（33% → 100%）
- ✅ 免费体验一层（首次只能用一次）
- ✅ 脉冲动画购买按钮
- ✅ Analytics 埋点（paywall_shown / converted / dismissed）

**核心问题**：缺少付费墙之前的"前置铺垫"，玩家从游戏直接撞墙。

### 2.2 三层漏斗策略

#### 第①层：软性渗透（游戏中，1~4 层）

**A. 商店锁定 Joker 预览**

每层商店额外展示 1 个锁定 Joker 位：
- 外观：半透明卡牌 + 🔒 图标 + "完整版解锁" 标签
- 点击锁定 Joker 弹出 toast："解锁完整版即可获得 55+ 规则牌"
- 不阻断商店流程，不弹付费墙
- 实现：`ShopView.swift` 新增 `lockedJokerSlot` 组件

**B. 关卡间预告 Toast**

通关第 3 层和第 4 层后，短暂展示下一章预告：
- 样式：底部浮出 toast，2.5秒后自动消失
- 内容：章节名 + Boss 修改器描述 + "完整版解锁"
- 仅展示，无按钮，不打断游戏流
- 实现：`MapView.swift` 或 `BattleView.swift` 通关回调中添加

**C. 分数板潜力提示**

每局结算时，在分数下方小字展示：
- "完整版玩家平均得分 98,000+"
- 字号小、颜色淡（Theme.textTertiary），不喧宾夺主
- 实现：`BattleView.swift` 结算弹窗新增一行

#### 第②层：付费墙增强（DemoGateView 现有基础上新增）

**A. 社交证明区**（新增 section）

位置：在 contentPreviewSection 下方、featuresSection 上方：
- 上线前：展示设计好的文案占位（如"获得 100+ 玩家好评"）
- 上线后：接入 SKStoreReviewController 引导评分，展示真实评分

**B. 价格锚定**

购买按钮上方新增价格展示行：
- 划线原价 ¥68（或 $9.99）
- 当前售价 ¥28（或 $4.99）+ "首发价" 标签
- 附文案："= 每层不到 ¥2"
- 注意：原价需基于真实定价计划，非虚构（App Store 审核合规）

**C. 温和紧迫感**

在回访用户文案位置新增：
- "首发限时优惠"字样（不设具体倒计时 — 避免 App Store 审核风险）
- 仅文案暗示，不做强制时间限制

#### 第③层：首购即时奖励

购买成功后弹出庆典页面：

**奖励内容：**
- 🃏 随机稀有规则牌 ×1（从 Batch 3+ Joker 中随机）
- 💎 额外换牌次数 +2（本次冒险）
- 🔥 Combo 起始倍率 ×2（本次冒险）

**设计原则：**
- 奖励仅限当次冒险，不影响长期平衡
- 降低第 6 层（首个完整版关卡）的难度梯度
- 庆典弹窗设计：全屏半透明覆盖 + 粒子特效 + 奖励卡片展示
- 实现：新建 `Features/Shop/PurchaseSuccessView.swift`

### 2.3 实现范围

**文件变更：**

| 文件 | 变更 |
|------|------|
| `Features/Shop/DemoGateView.swift` | 新增社交证明区 + 价格锚定行 + 紧迫感文案 |
| `Features/Shop/ShopView.swift` | 新增锁定 Joker 展示位 |
| `Features/Shop/PurchaseSuccessView.swift` | **新建** — 首购庆典弹窗 |
| `Features/Battle/BattleView.swift` | 结算弹窗新增潜力提示 |
| `Features/Map/MapView.swift` | 通关 toast 预告 |
| `Engine/RogueRun.swift` | 首购奖励逻辑（Joker + 换牌 + combo） |

---

## 三、手势引导（首次使用）

### 3.1 引导时机

玩家第一次进入对战场景（`!UserDefaults.standard.bool(forKey: "gestureGuideShown")`）。

### 3.2 引导内容

分 3 步引导 overlay：

1. **"滑过牌面选多张"** — 高亮手牌区域，模拟横滑动画
2. **"上滑甩出"** — 高亮选中牌，模拟上滑箭头
3. **"双击智能选牌"** — 高亮单张牌，模拟双击动画

每步有"跳过"按钮。完成后设置 `gestureGuideShown = true`。

### 3.3 实现

新建 `Features/Battle/GestureGuideOverlay.swift`（SwiftUI overlay）。

---

## 四、技术约束

1. **Engine/ 模块无 UI 依赖** — `bestPattern(containing:from:)` 是纯 Swift 方法
2. **SpriteKit 坐标系** — y 轴向上，上滑 = dy 为正
3. **触感反馈** — 需要 `import UIKit`，在 BattleScene 中已有 UIKit 访问权限
4. **App Store 审核** — 价格锚定基于真实定价计划；不使用虚假倒计时；首购奖励不构成消耗型 IAP
5. **买断制** — 所有付费优化均围绕一次性购买，无订阅、无消耗型 IAP
6. **SwiftData 兼容** — 首购奖励状态通过 RogueRun 管理，不新增持久化模型

---

## 五、不做的事

- ❌ 不做排行榜（依赖 GameCenter，后续迭代）
- ❌ 不做消耗型 IAP（买断制）
- ❌ 不做强制弹窗广告
- ❌ 不做虚假倒计时
- ❌ 不做 AI 改进（本次聚焦交互和付费）
- ❌ 不做美术资源更换（用现有 SF Symbols + 程序化效果）

---

## 六、成功标准

| 指标 | 目标 |
|------|------|
| 出牌操作步骤 | 从 3 步（点选×N + 按钮）→ 2 步（滑选 + 上滑） |
| 手势使用率 | 上滑出牌 > 50% 占比（vs 按钮出牌） |
| 付费墙转化率 | 提升 30%+（相对当前基线） |
| 首购后 1 小时留存 | > 80%（即时奖励消除"后悔"） |
| App Store 审核 | 一次通过 |
