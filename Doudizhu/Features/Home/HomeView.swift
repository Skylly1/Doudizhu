import SwiftUI

struct FloatingParticles: View {
    let count: Int = 30

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for i in 0..<count {
                    let seed = Double(i) * 137.5
                    let x = (sin(seed + time * 0.25) * 0.5 + 0.5) * size.width
                    let progress = fmod(seed * 0.01 + time * (0.015 + Double(i) * 0.0015), 1.0)
                    let y = size.height * (1.0 - progress)
                    let opacity = sin(progress * .pi) * 0.6
                    // 混合大小：部分大颗粒（像萤火虫），部分小颗粒
                    let isLarge = i % 4 == 0
                    let radius: Double = isLarge ? (3.5 + sin(seed) * 2.0) : (1.8 + sin(seed) * 1.0)
                    let glowRadius: Double = isLarge ? 6.0 : 0.0

                    // 大颗粒加辉光效果
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
        .allowsHitTesting(false)
    }
}

/// 底部扑克牌扇形展示动画 — 大气的入口视觉
struct CardFanDecor: View {
    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let centerX = w / 2
            let baseY = h * 0.88
            let cardW: CGFloat = 52
            let cardH: CGFloat = 76

            // 5 张扇形排列的卡牌
            let cards: [(rank: String, suit: String, color: Color, angle: Double, offsetX: CGFloat)] = [
                ("A", "♠", Color(red: 0.15, green: 0.12, blue: 0.10), -18, -80),
                ("K", "♥", Color(red: 0.72, green: 0.08, blue: 0.08), -9, -40),
                ("Q", "♠", Color(red: 0.15, green: 0.12, blue: 0.10), 0, 0),
                ("J", "♦", Color(red: 0.72, green: 0.08, blue: 0.08), 9, 40),
                ("10", "♣", Color(red: 0.15, green: 0.12, blue: 0.10), 18, 80),
            ]

            ZStack {
                // 底部光晕
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.10),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 280, height: 80)
                    .position(x: centerX, y: baseY + 20)

                ForEach(Array(cards.enumerated()), id: \.offset) { index, card in
                    // 单张卡牌
                    ZStack {
                        // 牌面
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(red: 0.95, green: 0.92, blue: 0.86))
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(red: 0.72, green: 0.62, blue: 0.48).opacity(0.5), lineWidth: 0.8)

                        // 内框
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color(red: 0.72, green: 0.55, blue: 0.35).opacity(0.15), lineWidth: 0.4)
                            .padding(3)

                        VStack(spacing: 1) {
                            Text(card.rank)
                                .font(.system(size: 16, weight: .bold, design: .serif))
                                .foregroundColor(card.color)
                            Text(card.suit)
                                .font(.system(size: 12))
                                .foregroundColor(card.color)
                        }
                    }
                    .frame(width: cardW, height: cardH)
                    .shadow(color: .black.opacity(0.4), radius: 4, y: 3)
                    .rotationEffect(.degrees(card.angle))
                    .position(
                        x: centerX + card.offsetX,
                        y: baseY
                    )
                    .opacity(appeared ? 1.0 : 0.0)
                    .offset(y: appeared ? 0 : 30)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.7).delay(0.8 + Double(index) * 0.08),
                        value: appeared
                    )
                }
            }
        }
        .allowsHitTesting(false)
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
    let hasSavedGame: Bool
    let onNavigate: (AppScreen) -> Void
    let onContinue: () -> Void
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var showButtons = [false, false, false, false, false]
    @State private var dailyPulse = false

    private var dailyChallengeButton: some View {
        let daily = DailyChallenge.today
        let played = DailyChallenge.hasPlayedToday
        return Button {
            if !played { onNavigate(.dailyChallenge) }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: daily.modifiers.first?.icon ?? "calendar")
                    .font(.body)
                    .foregroundColor(Theme.flame)
                VStack(alignment: .leading, spacing: 2) {
                    Text(played
                         ? (L10n.isEnglish ? "Completed" : "已完成")
                         : L10n.dailyChallenge)
                        .font(.subheadline.bold())
                    Text(played
                         ? (L10n.isEnglish ? "Best: \(DailyChallenge.todayBest)" : "最高: \(DailyChallenge.todayBest)")
                         : (daily.modifiers.first?.name ?? ""))
                        .font(.caption2)
                        .foregroundColor(Theme.textTertiary)
                }
                Spacer()
                if !played {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Theme.textTertiary)
                }
            }
            .foregroundColor(played ? Theme.textDisabled : Theme.textPrimary)
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .stroke(played ? Theme.borderLight : (dailyPulse ? Theme.gold : Theme.gold.opacity(0.15)),
                                    lineWidth: played ? 0.5 : (dailyPulse ? 1.5 : 0.5))
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        }
        .disabled(played)
    }

    var body: some View {
        ZStack {
            // 渐变主背景 — 大幅提亮
            LinearGradient(
                colors: [
                    Color(red: 0.34, green: 0.25, blue: 0.17),
                    Color(red: 0.22, green: 0.16, blue: 0.11),
                    Color(red: 0.15, green: 0.11, blue: 0.08)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // 顶部金色光晕 — 更大更亮
            RadialGradient(
                colors: [
                    Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.25),
                    Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.08),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.15),
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()

            // 底部烟雾氛围
            BottomMistLayer()
                .ignoresSafeArea()

            // 浮动粒子
            FloatingParticles()
                .ignoresSafeArea()

            // 底部卡牌扇形装饰
            CardFanDecor()
                .ignoresSafeArea()

            // 主内容
            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                // 标题区
                VStack(spacing: 14) {
                    // 国潮印章式标识 — "斗"字
                    ZStack {
                        // 大辉光圈
                        Circle()
                            .fill(Theme.gold.opacity(0.12))
                            .frame(width: 120, height: 120)
                            .blur(radius: 25)
                        // 外菱形框
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.gold.opacity(0.50), lineWidth: 2)
                            .frame(width: 72, height: 72)
                            .rotationEffect(.degrees(45))
                        // 内菱形框
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Theme.gold.opacity(0.22), lineWidth: 1)
                            .frame(width: 58, height: 58)
                            .rotationEffect(.degrees(45))
                        Text("斗")
                            .font(.system(size: 48, weight: .black, design: .serif))
                            .foregroundStyle(Theme.goldGradient)
                    }
                    .shadow(color: Theme.gold.opacity(0.5), radius: 20)

                    Text(L10n.appName)
                        .font(Theme.responsiveTitle())
                        .foregroundStyle(Theme.goldGradient)
                        .shadow(color: Theme.gold.opacity(0.5), radius: 12, y: 0)

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

                Spacer().frame(height: Theme.isCompactScreen ? 20 : 36)

                // Ascension 等级展示
                let highestAsc = UserDefaults.standard.integer(forKey: "highestAscensionCleared")
                if highestAsc > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Theme.flame)
                        Text(L10n.highestAscLabel(highestAsc))
                            .font(.subheadline.bold().monospacedDigit())
                            .foregroundColor(Theme.flame)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Theme.flameDim))
                    .padding(.bottom, 8)
                }

                // 菜单按钮
                VStack(spacing: 14) {
                    // 继续冒险（有存档时显示）
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
                        .padding(.horizontal, 50)
                        .offset(y: showButtons[0] ? 0 : 40)
                        .opacity(showButtons[0] ? 1.0 : 0)
                    }

                    PrimaryButton(title: hasSavedGame
                                  ? (L10n.isEnglish ? "New Run" : "新的冒险")
                                  : L10n.startAdventure,
                                  icon: hasSavedGame ? "plus.circle.fill" : "play.fill") {
                        onNavigate(.map)
                    }
                    .padding(.horizontal, 50)
                    .offset(y: showButtons[1] ? 0 : 40)
                    .opacity(showButtons[1] ? 1.0 : 0)

                    SecondaryButton(title: L10n.quickStart, icon: "bolt.fill") {
                        onNavigate(.buildSelect)
                    }
                    .padding(.horizontal, 50)
                    .offset(y: showButtons[2] ? 0 : 40)
                    .opacity(showButtons[2] ? 1.0 : 0)

                    // Daily Challenge
                    dailyChallengeButton
                        .padding(.horizontal, 50)
                        .offset(y: showButtons[3] ? 0 : 40)
                        .opacity(showButtons[3] ? 1.0 : 0)

                    HStack(spacing: 12) {
                        SecondaryButton(title: L10n.cardCollection, icon: "rectangle.stack.fill") {
                            onNavigate(.collection)
                        }
                        SecondaryButton(title: L10n.settings, icon: "gearshape.fill") {
                            onNavigate(.settings)
                        }
                    }
                    .padding(.horizontal, 50)
                    .offset(y: showButtons[4] ? 0 : 40)
                    .opacity(showButtons[4] ? 1.0 : 0)
                }

                Spacer()

                // 今日数据概览
                TodayStatsBanner()
                    .padding(.horizontal, 40)
                    .padding(.bottom, 6)

                // 版本信息
                Text(L10n.versionString)
                    .font(.system(size: 10, weight: .light, design: .monospaced))
                    .foregroundColor(Theme.textDisabled.opacity(0.5))
                    .padding(.bottom, 8)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
                showButtons[0] = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.45)) {
                showButtons[1] = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.55)) {
                showButtons[2] = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.65)) {
                showButtons[3] = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.75)) {
                showButtons[4] = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever().delay(0.8)) {
                dailyPulse = true
            }
        }
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
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .stroke(Theme.gold.opacity(0.12), lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }

    private var divider: some View {
        Rectangle().fill(Theme.border).frame(width: 1, height: 22)
    }

    private func statItem(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)
                Text(value)
                    .font(.caption.bold().monospacedDigit())
                    .foregroundColor(Theme.textPrimary)
            }
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView(hasSavedGame: true, onNavigate: { _ in }, onContinue: {})
}
