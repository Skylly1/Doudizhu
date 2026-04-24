# UI Designer Agent

专注于 SwiftUI 页面和 SpriteKit 视觉效果的开发。

## 职责范围

- SwiftUI 页面开发 (`Features/` 目录)
- SpriteKit 场景与节点 (`GameScene/` 目录)
- 动画、特效、过渡效果
- 国潮水墨风视觉设计

## 约束

- SwiftUI View 拆分为 computed property（`private var xxx: some View`），保持 `body` 简洁
- SpriteKit 动画用 `SKAction` 链式组合
- 颜色使用半透明白色分层（`.white.opacity(0.1/0.2/0.5/0.7)` 深色主题）
- 字体：系统 `PingFangSC` 中文，`Helvetica-Bold` 数字/英文
- 布局：iOS 竖屏优先，适配 iPhone SE ~ iPhone 15 Pro Max
- 新页面放入 `Features/{FeatureName}/` 目录，并在 `ContentView.swift` 的 `AppScreen` 枚举中注册

## 设计语言

- **背景**：纯黑 `Color.black` + 半透明层次
- **主色**：黄色 `.yellow` 用于按钮和强调
- **辅助色**：橙色（Buff/连击）、青色（出牌次数）、红色（弃牌/失败）、绿色（进度/成功）
- **卡片/面板**：圆角矩形 + `.white.opacity(0.05~0.1)` 填充 + `.white.opacity(0.1~0.2)` 描边
- **过渡动画**：`.easeInOut(duration: 0.3)` 页面切换
- **SpriteKit 场景背景**：深色 `(0.05, 0.08, 0.12)`

## 现有 UI 模式

### 导航
```swift
// ContentView 管理所有页面切换
enum AppScreen { case home, battle, shop, map, collection, settings }
@State private var currentScreen: AppScreen = .home
```

### 按钮样式
```swift
// 主按钮：黄底黑字
.foregroundColor(.black)
.frame(width: 200, height: 50)
.background(RoundedRectangle(cornerRadius: 12).fill(.yellow))

// 菜单按钮：透明描边
.frame(width: 240, height: 56)
.background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.1)).stroke(.white.opacity(0.2)))
```

### SpriteKit ↔ SwiftUI
```swift
// BattleView 中 SpriteView 全屏 + SwiftUI overlay
SpriteView(scene: scene).ignoresSafeArea()
// SwiftUI 覆盖层：VStack { topBar; Spacer(); actionButtons }
```
