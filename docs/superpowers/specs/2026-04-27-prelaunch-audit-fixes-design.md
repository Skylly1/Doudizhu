# 上线前全面检视修复方案

> 日期: 2026-04-27
> 状态: 设计完成
> 范围: 代码层面全修 — 功能面 + 营收面 + 生产就绪

## 背景

基于项目全面审计（45 个 Swift 文件、1004+ 行交互革命代码已合并），发现 6 类上线阻塞项需要在代码层面解决。

## 审计核心发现

| 领域 | 评级 | 说明 |
|------|------|------|
| 游戏设计 & 内容 | ✅ 就绪 | 60+ Joker, 25+ Buff, 15 关卡, 9 构筑, Boss, 每日挑战 |
| 核心玩法代码 | ✅ 就绪 | 完整游戏循环, 全牌型识别, chips×mult 计分 |
| UI/UX | ✅ 就绪 | 国潮水墨风, 手势系统, 新手引导 |
| 变现链路 | ✅ 就绪 | StoreKit 2, 付费墙优化, 首购奖励 |
| 基础设施 | ⚠️ 需修 | 纯本地 Analytics/Crash, 无测试, 无迁移策略 |
| 无障碍 | ⚠️ 需修 | SwiftUI 页面缺少 accessibilityLabel |
| 元数据 | ⚠️ 需修 | URL 占位符未替换 |

## 工作包设计

### W1: Firebase Analytics + Crashlytics 接入

**目标**: 替换本地 Analytics/CrashReporter 为 Firebase，保留本地方案作降级。

**改动清单**:
1. `project.yml` — 添加 `packages:` SPM 依赖 (firebase-ios-sdk)，target 添加 FirebaseAnalytics + FirebaseCrashlytics
2. `DoudizhuApp.swift` — `import FirebaseCore`, `init()` 顶部 `FirebaseApp.configure()`
3. `Analytics.swift` — `import FirebaseAnalytics`, `track()` 内追加 `FirebaseAnalytics.Analytics.logEvent()`
4. `CrashReporter.swift` — `import FirebaseCrashlytics`, `log()` 转发, `addBreadcrumb()` 同步
5. `PrivacyInfo.xcprivacy` — 声明 Firebase 数据收集（analytics, crash logs）
6. 需要用户手动: 创建 Firebase 项目 → 下载 `GoogleService-Info.plist` → 放入 `Doudizhu/` 目录

**条件编译**: 使用 `#if canImport(FirebaseCore)` 守卫，无 plist 时仍可编译。

### W2: 单元测试

**目标**: 核心引擎逻辑的自动化验证。

**新文件**: `DoudizhuTests/EngineTests.swift`

**测试用例**:
- PatternRecognizer: 12 种牌型各 1 个 happy path + 边界（空牌、1 张、非法组合）
- bestPattern: 双击选牌 — 炸弹优先、顺子检测、对子回退
- CardPattern 计分: baseChips × baseMult 验证
- RogueRun.playCards: 连击加成、Buff 应用

**构建**: `project.yml` 新增 `DoudizhuTests` target, type: `bundle.unit-test`

### W3: SwiftData 迁移安全

**目标**: 避免版本更新时丢失玩家存档。

**方案**: 
1. `GameSaveModel` 添加 `schemaVersion: Int = 1`
2. `DoudizhuApp.swift` 替换 catch-delete:
   - 先尝试正常创建 ModelContainer
   - 失败时备份 `.store` 文件到 `Documents/SaveBackup/`
   - 再清除重建
   - 日志记录迁移事件
3. 添加 `SchemaMigrationPlan` 为未来版本预留

### W4: 无障碍最小合规

**范围**: SwiftUI 页面的 accessibilityLabel/Hint/Value。SpriteKit 牌桌不处理（v2 做）。

**涉及页面** (10 个):
- HomeView: 按钮标签（开始游戏、继续、每日挑战、收藏、设置）
- BuildSelectView: 构筑卡片标签
- MapView: 关卡节点标签
- ShopView: 商品名+价格+购买按钮
- DemoGateView: 购买按钮 + 特权列表
- BattleView HUD: 分数、出牌次数、弃牌次数、金币
- SettingsView: 开关标签
- CollectionView: Tab 标签
- AchievementView: 成就名+状态
- HelpView: 条目标签

**策略**: 对每个交互元素添加 `.accessibilityLabel()`, 对数值添加 `.accessibilityValue()`。

### W5: URL 与元数据修复

**改动**:
1. 创建 `docs/privacy.html` — 基于现有 PrivacyPolicy.md 转 HTML
2. 创建 `docs/support.html` — 支持页（联系邮箱 + FAQ 链接）
3. `docs/AppStoreMetadata.md` — 替换 `[your-github-pages-url]` 为真实 GitHub Pages URL

**URL 格式**: `https://hongzeng.github.io/doudizhu/privacy.html`（需确认 GitHub 用户名）

### W6: 生产检查清单同步

更新 `docs/PRODUCTION_CHECKLIST.md`，把本次修复的项目标记为已完成。

## 依赖关系

```
W1 (Firebase) ───┐
W2 (测试)    ───┤── 全部独立，可并行
W3 (迁移)    ───┤
W4 (无障碍)  ───┘
                 ↓
W5 (URL) ─── 独立
W6 (清单) ─── 依赖 W1-W5 全部完成
```

## 约束

- Firebase plist 需要用户手动添加（代码层面用 `#if canImport` 守卫）
- 不修改游戏逻辑/数值平衡
- 不重构大文件（BattleView 1492 行等留给 v2）
- SpriteKit 牌桌无障碍留给 v2
- GitHub Pages URL 需要确认用户名
