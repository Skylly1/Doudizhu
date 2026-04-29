import SwiftUI

struct FloatingParticles: View {
    let count: Int = 30
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        if scenePhase == .active {
            TimelineView(.animation(minimumInterval: 1.0/30)) { timeline in
                particleCanvas(time: timeline.date.timeIntervalSinceReferenceDate)
            }
            .allowsHitTesting(false)
        } else {
            // Static frame when backgrounded — no animation cost
            particleCanvas(time: Date().timeIntervalSinceReferenceDate)
                .allowsHitTesting(false)
        }
    }

    private func particleCanvas(time: Double) -> some View {
        Canvas { context, size in
            for i in 0..<count {
                let seed = Double(i) * 137.5
                let x = (sin(seed + time * 0.25) * 0.5 + 0.5) * size.width
                let progress = fmod(seed * 0.01 + time * (0.015 + Double(i) * 0.0015), 1.0)
                let y = size.height * (1.0 - progress)
                let opacity = sin(progress * .pi) * 0.6
                let isLarge = i % 4 == 0
                let radius: Double = isLarge ? (3.5 + sin(seed) * 2.0) : (1.8 + sin(seed) * 1.0)
                let glowRadius: Double = isLarge ? 6.0 : 0.0

                if isLarge && opacity > 0.2 {
                    context.opacity = opacity * 0.3
                    context.fill(
                        Circle().path(in: CGRect(x: x - glowRadius, y: y - glowRadius,
                                                  width: glowRadius * 2, height: glowRadius * 2)),
                        with: .color(Color(red: 0.90, green: 0.75, blue: 0.35))
                    )
                }

                context.opacity = opacity
                context.fill(
                    Circle().path(in: CGRect(x: x - radius, y: y - radius,
                                              width: radius * 2, height: radius * 2)),
                    with: .color(Color(red: 0.85, green: 0.68, blue: 0.28))
                )
            }
        }
    }
}

/// 扑克牌扇形装饰 — 内联布局，固定高度
struct CardFanDecor: View {
    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let centerX = w / 2
            let scale = Theme.screenScale
            let cardW: CGFloat = 38 * scale
            let cardH: CGFloat = 54 * scale
            let baseY = h / 2  // 在容器中垂直居中

            let cards: [(rank: String, suit: String, color: Color, angle: Double, offsetX: CGFloat)] = [
                ("A", "♠", Color(red: 0.15, green: 0.12, blue: 0.10), -16, -64 * scale),
                ("K", "♥", Color(red: 0.72, green: 0.08, blue: 0.08), -8, -32 * scale),
                ("Q", "♠", Color(red: 0.15, green: 0.12, blue: 0.10), 0, 0),
                ("J", "♦", Color(red: 0.72, green: 0.08, blue: 0.08), 8, 32 * scale),
                ("10", "♣", Color(red: 0.15, green: 0.12, blue: 0.10), 16, 64 * scale),
            ]

            ZStack {
                // 底部光晕
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 220, height: 60)
                    .position(x: centerX, y: baseY + 10)

                ForEach(Array(cards.enumerated()), id: \.offset) { index, card in
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.95, green: 0.92, blue: 0.86))
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(red: 0.72, green: 0.62, blue: 0.48).opacity(0.4), lineWidth: 0.6)

                        VStack(spacing: 0) {
                            Text(card.rank)
                                .font(.system(size: 13 * scale, weight: .bold, design: .serif))
                                .foregroundColor(card.color)
                            Text(card.suit)
                                .font(.system(size: 9 * scale))
                                .foregroundColor(card.color)
                        }
                    }
                    .frame(width: cardW, height: cardH)
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                    .rotationEffect(.degrees(card.angle))
                    .position(x: centerX + card.offsetX, y: baseY)
                    .opacity(appeared ? 1.0 : 0.0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7).delay(0.8 + Double(index) * 0.06),
                        value: appeared
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .opacity(0.5)
        .onAppear { appeared = true }
    }
}

/// 底部烟雾/水墨氛围层
struct BottomMistLayer: View {
    @State private var shift: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // 底部渐变烟雾
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color(red: 0.12, green: 0.08, blue: 0.06).opacity(0.3),
                        Color(red: 0.10, green: 0.07, blue: 0.05).opacity(0.8)
                    ],
                    startPoint: .init(x: 0.5, y: 0.7),
                    endPoint: .bottom
                )

                // 流动的金色雾气
                Ellipse()
                    .fill(Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.06))
                    .frame(width: w * 0.7, height: 40)
                    .position(x: w * 0.4 + shift * 20, y: h * 0.82)

                Ellipse()
                    .fill(Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.04))
                    .frame(width: w * 0.5, height: 30)
                    .position(x: w * 0.65 - shift * 15, y: h * 0.86)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                shift = 1
            }
        }
    }
}

struct HomeView: View {
    // REVENUE-TODO: [P3] 加入「支持开发者」入口 — 设置页或关于页的打赏按钮
    let hasSavedGame: Bool
    let onNavigate: (AppScreen) -> Void
    let onContinue: () -> Void
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var showButtons = [false, false, false, false]
    @State private var dailyPulse = false
    @State private var sealGlow = false
    @State private var showNewRunConfirm = false
    @State private var pendingNewRunScreen: AppScreen? = nil
    @State private var hasAnimated = false

    private var dailyChallengeButton: some View {
        let daily = DailyChallenge.today
        let completed = DailyChallenge.hasCompletedToday
        let inProgress = DailyChallenge.hasInProgressToday
        return Button {
            if !completed { onNavigate(.dailyChallenge) }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: daily.modifiers.first?.icon ?? "calendar")
                    .font(.body)
                    .foregroundColor(Theme.flame)
                VStack(alignment: .leading, spacing: 2) {
                    Text(completed
                         ? (L10n.isEnglish ? "Completed" : "已完成")
                         : (inProgress
                            ? (L10n.isEnglish ? "Resume Challenge" : "继续挑战")
                            : L10n.dailyChallenge))
                        .font(.subheadline.bold())
                    Text(completed
                         ? (L10n.isEnglish ? "Best: \(DailyChallenge.todayBest)" : "最高: \(DailyChallenge.todayBest)")
                         : (daily.modifiers.first?.name ?? ""))
                        .font(.caption2)
                        .foregroundColor(Theme.textTertiary)
                }
                Spacer()
                if !completed {
                    Image(systemName: inProgress ? "play.fill" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(inProgress ? Theme.flame : Theme.textTertiary)
                }
            }
            .foregroundColor(completed ? Theme.textDisabled : Theme.textPrimary)
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .stroke(completed ? Theme.borderLight : (dailyPulse ? Theme.gold : Theme.gold.opacity(0.15)),
                                    lineWidth: completed ? 0.5 : (dailyPulse ? 1.5 : 0.5))
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        }
        .disabled(completed)
        .accessibilityLabel(completed ? L10n.a11yDailyChallengeComplete : L10n.a11yDailyChallenge)
        .accessibilityHint(completed ? L10n.localized("今日挑战已完成", en: "Today's challenge completed") : L10n.localized("开始今日限定挑战", en: "Start today's daily challenge"))
    }

    var body: some View {
        ZStack {
            // 渐变主背景 — 温暖国潮色
            LinearGradient(
                colors: [
                    Color(red: 0.38, green: 0.26, blue: 0.16),
                    Color(red: 0.26, green: 0.18, blue: 0.12),
                    Color(red: 0.17, green: 0.12, blue: 0.09)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // 顶部金色光晕 — 温暖聚焦
            RadialGradient(
                colors: [
                    Color(red: 0.90, green: 0.72, blue: 0.30).opacity(0.25),
                    Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.08),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.12),
                startRadius: 0,
                endRadius: 320
            )
            .ignoresSafeArea()

            // 底部烟雾氛围
            BottomMistLayer()
                .ignoresSafeArea()

            // 浮动粒子
            FloatingParticles()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            // 主内容
            VStack(spacing: 0) {
                Spacer().frame(height: Theme.isCompactScreen ? 10 : 16)  // 系统安全区域已自动处理刘海/灵动岛

                // 标题区 — 印章式 Logo
                VStack(spacing: 12) {
                    ZStack {
                        // 辉光呼吸圈
                        Circle()
                            .fill(Theme.gold.opacity(sealGlow ? 0.18 : 0.08))
                            .frame(width: 130, height: 130)
                            .blur(radius: 30)

                        // 外菱形框
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.gold.opacity(0.55), lineWidth: 2.2)
                            .frame(width: 72, height: 72)
                            .rotationEffect(.degrees(45))
                        // 内菱形框
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Theme.gold.opacity(0.22), lineWidth: 1)
                            .frame(width: 58, height: 58)
                            .rotationEffect(.degrees(45))

                        Text("斗")
                            .font(Theme.fontTitle)
                            .foregroundStyle(Theme.goldGradient)
                    }
                    .shadow(color: Theme.gold.opacity(0.4), radius: 16)
                    .accessibilityHidden(true)

                    Text(L10n.appName)
                        .font(Theme.responsiveTitle())
                        .foregroundStyle(Theme.goldGradient)
                        .shadow(color: Theme.gold.opacity(0.4), radius: 10, y: 0)
                        .accessibilityAddTraits(.isHeader)

                    Text(L10n.appSubtitle)
                        .font(Theme.subtitleFont)
                        .foregroundColor(Theme.textTertiary)
                        .tracking(4)

                    // 装饰分隔线
                    HStack(spacing: 8) {
                        Rectangle().fill(Theme.gold.opacity(0.25)).frame(width: 35, height: 1)
                        Image(systemName: "rhombus.fill")
                            .font(.system(size: 5))
                            .foregroundColor(Theme.gold.opacity(0.5))
                        Rectangle().fill(Theme.gold.opacity(0.25)).frame(width: 35, height: 1)
                    }
                }
                .scaleEffect(titleScale)
                .opacity(titleOpacity)

                Spacer().frame(height: Theme.isCompactScreen ? 18 : 28)

                // Ascension 等级展示
                let highestAsc = UserDefaults.standard.integer(forKey: "highestAscensionCleared")
                if highestAsc > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Theme.flame)
                        Text(L10n.highestAscLabel(highestAsc))
                            .font(.caption.bold().monospacedDigit())
                            .foregroundColor(Theme.flame)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Theme.flameDim))
                    .padding(.bottom, 6)
                }

                // 菜单按钮
                VStack(spacing: 14) {
                    if hasSavedGame {
                        PrimaryButton(
                            title: L10n.isEnglish ? "Continue" : "继续冒险",
                            icon: "play.circle.fill",
                            gradient: LinearGradient(
                                colors: [Theme.cyan, Theme.cyan.opacity(0.7)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        ) {
                            onContinue()
                        }
                        .padding(.horizontal, Theme.spacingXL)
                        .accessibilityLabel(L10n.a11yContinueAdventure)
                        .accessibilityHint(L10n.localized("继续上次保存的冒险进度", en: "Continue your saved adventure"))
                        .offset(y: showButtons[0] ? 0 : 30)
                        .opacity(showButtons[0] ? 1.0 : 0)
                    }

                    PrimaryButton(title: hasSavedGame
                                  ? (L10n.isEnglish ? "New Run" : "新的冒险")
                                  : L10n.startAdventure,
                                  icon: hasSavedGame ? "plus.circle.fill" : "play.fill") {
                        if hasSavedGame {
                            pendingNewRunScreen = .map
                            showNewRunConfirm = true
                        } else {
                            onNavigate(.map)
                        }
                    }
                    .padding(.horizontal, Theme.spacingXL)
                    .accessibilityLabel(hasSavedGame ? L10n.a11yNewAdventure : L10n.a11yStartAdventure)
                    .accessibilityHint(L10n.localized("开始新的一局游戏", en: "Start a new game"))
                    .offset(y: showButtons[1] ? 0 : 30)
                    .opacity(showButtons[1] ? 1.0 : 0)

                    // 快速开始 + 每日挑战 — 并排
                    HStack(spacing: 12) {
                        SecondaryButton(title: L10n.quickStart, icon: "bolt.fill") {
                            if hasSavedGame {
                                pendingNewRunScreen = .buildSelect
                                showNewRunConfirm = true
                            } else {
                                onNavigate(.buildSelect)
                            }
                        }
                        .accessibilityLabel(L10n.a11yQuickStart)
                        .accessibilityHint(L10n.localized("跳过地图直接开始游戏", en: "Skip map and start game directly"))
                        dailyChallengeButton
                    }
                    .padding(.horizontal, Theme.spacingXL)
                    .offset(y: showButtons[2] ? 0 : 30)
                    .opacity(showButtons[2] ? 1.0 : 0)

                    HStack(spacing: 12) {
                        SecondaryButton(title: L10n.cardCollection, icon: "rectangle.stack.fill") {
                            onNavigate(.collection)
                        }
                        .accessibilityLabel(L10n.a11yCardCollection)
                        .accessibilityHint(L10n.localized("查看卡牌图鉴和成就", en: "View card collection and achievements"))
                        SecondaryButton(title: L10n.settings, icon: "gearshape.fill") {
                            onNavigate(.settings)
                        }
                        .accessibilityLabel(L10n.a11ySettings)
                        .accessibilityHint(L10n.localized("打开游戏设置", en: "Open game settings"))
                    }
                    .padding(.horizontal, Theme.spacingXL)
                    .offset(y: showButtons[3] ? 0 : 30)
                    .opacity(showButtons[3] ? 1.0 : 0)
                }
                .frame(maxWidth: 500)

                // 内联卡牌扇形装饰 — 按钮与横幅之间
                CardFanDecor()
                    .frame(height: Theme.isCompactScreen ? 55 : 72)
                    .accessibilityHidden(true)

                // 免费用户 — 升级提示横幅（菜单按钮下方，高可见度位置）
                if !PurchaseManager.shared.isFullVersion {
                    upgradePromptBanner
                        .padding(.horizontal, Theme.spacingXL)
                        .frame(maxWidth: 500)
                        .padding(.bottom, 8)
                }

                // 今日数据概览
                TodayStatsBanner()
                    .padding(.horizontal, Theme.spacingXL)
                    .frame(maxWidth: 500)
                    .padding(.bottom, 12)
                Text("v1.0")
                    .font(Theme.fontMicro)
                    .foregroundColor(Theme.textDisabled.opacity(0.5))
                    .padding(.bottom, 6)
            }
        }
        .onAppear {
            guard !hasAnimated else { return }
            hasAnimated = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            for i in 0..<showButtons.count {
                withAnimation(.easeOut(duration: 0.45).delay(0.3 + Double(i) * 0.1)) {
                    showButtons[i] = true
                }
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.5)) {
                sealGlow = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever().delay(0.8)) {
                dailyPulse = true
            }
        }
        .alert(
            L10n.isEnglish ? "Start New Run?" : "开始新冒险？",
            isPresented: $showNewRunConfirm
        ) {
            Button(L10n.cancel, role: .cancel) {
                pendingNewRunScreen = nil
            }
            Button(L10n.isEnglish ? "Start New" : "开始新冒险", role: .destructive) {
                if let screen = pendingNewRunScreen {
                    onNavigate(screen)
                    pendingNewRunScreen = nil
                }
            }
        } message: {
            Text(L10n.isEnglish
                 ? "You have an adventure in progress. Starting a new run will overwrite your saved progress."
                 : "你有一个进行中的冒险。开始新冒险将覆盖已保存的进度。")
        }
    }

    // MARK: - 升级提示横幅（免费用户可见）
    private var upgradePromptBanner: some View {
        let totalFloors = FloorConfig.allFloors.count
        let unlockedFloors = PurchaseManager.demoMaxFloor
        let lockedFloors = totalFloors - unlockedFloors

        return Button {
            Analytics.shared.track(.paywallShown, params: ["source": "home_banner"])
            onNavigate(.demoGate)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(Theme.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.isEnglish
                         ? "Unlock \(lockedFloors) more floors & all Jokers"
                         : "解锁余下\(lockedFloors)层关卡 & 全部丑角牌")
                        .font(.caption2.bold())
                        .foregroundColor(Theme.textPrimary)
                    Text(L10n.isEnglish
                         ? "More builds · More strategies · Endless fun"
                         : "更多流派 · 更多策略 · 无限乐趣")
                        .font(Theme.fontMicro)
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(Theme.gold.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .fill(Theme.gold.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .stroke(Theme.gold.opacity(0.15)))
            )
        }
        .accessibilityLabel(L10n.isEnglish ? "See full version details" : "查看完整版内容")
    }
}

// MARK: - 今日数据横条

private struct TodayStatsBanner: View {
    @ObservedObject private var stats = PlayerStats.shared

    var body: some View {
        HStack(spacing: 0) {
            statItem(icon: "gamecontroller.fill", color: Theme.cyan, value: "\(stats.totalRuns)",
                     label: L10n.isEnglish ? "Runs" : "局数")
            divider
            statItem(icon: "crown.fill", color: Theme.gold, value: "\(stats.highestSingleScore)",
                     label: L10n.isEnglish ? "Best" : "最高分")
            divider
            statItem(icon: "trophy.fill", color: Theme.success, value: "\(stats.totalWins)",
                     label: L10n.isEnglish ? "Wins" : "胜场")
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .stroke(Theme.gold.opacity(0.18), lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.a11yTodayStats)
    }

    private var divider: some View {
        Rectangle().fill(Theme.border).frame(width: 1, height: 22)
    }

    private func statItem(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(Theme.fontSmall)
                    .foregroundColor(color)
                Text(value)
                    .font(.caption.bold().monospacedDigit())
                    .foregroundColor(Theme.textPrimary)
            }
            Text(label)
                .font(Theme.fontMicro)
                .foregroundColor(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}

#Preview {
    HomeView(hasSavedGame: true, onNavigate: { _ in }, onContinue: {})
}
