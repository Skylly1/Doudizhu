import SwiftUI

struct FloatingParticles: View {
    let count: Int = 18

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for i in 0..<count {
                    let seed = Double(i) * 137.5
                    let x = (sin(seed + time * 0.3) * 0.5 + 0.5) * size.width
                    let progress = fmod(seed * 0.01 + time * (0.02 + Double(i) * 0.002), 1.0)
                    let y = size.height * (1.0 - progress)
                    let opacity = sin(progress * .pi) * 0.3
                    let radius = 1.5 + sin(seed) * 1.0

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

struct HomeView: View {
    let onNavigate: (AppScreen) -> Void
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var showButtons = [false, false, false, false]
    @State private var dailyPulse = false

    private var dailyChallengeButton: some View {
        let daily = DailyChallenge.today
        let played = DailyChallenge.hasPlayedToday
        return Button {
            if !played { onNavigate(.dailyChallenge) }
        } label: {
            HStack(spacing: 8) {
                Text(daily.modifiers.first?.icon ?? "📅")
                    .font(.body)
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
                    .fill(played ? Theme.bgInset : Theme.bgCard)
                    .stroke(played ? Theme.borderLight : (dailyPulse ? Theme.gold : Theme.border),
                            lineWidth: played ? 1 : (dailyPulse ? 1.5 : 0.5))
            )
        }
        .disabled(played)
    }

    var body: some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            // 装饰背景
            VStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.gold.opacity(0.08), Color.clear],
                            center: .center,
                            startRadius: 0, endRadius: 250
                        )
                    )
                    .frame(width: 500, height: 500)
                    .offset(y: -100)
                Spacer()
            }
            .ignoresSafeArea()

            FloatingParticles()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // 标题区
                VStack(spacing: 12) {
                    // 国潮印章式标识 — "斗"字
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Theme.gold.opacity(0.35), lineWidth: 1.5)
                            .frame(width: 58, height: 58)
                            .rotationEffect(.degrees(45))
                        Text("斗")
                            .font(.system(size: 40, weight: .black, design: .serif))
                            .foregroundStyle(Theme.goldGradient)
                    }
                    .shadow(color: Theme.gold.opacity(0.3), radius: 12)

                    Text(L10n.appName)
                        .font(Theme.responsiveTitle())
                        .foregroundStyle(Theme.goldGradient)
                        .shadow(color: Theme.gold.opacity(0.4), radius: 12, y: 0)
                        .shadow(color: Theme.gold.opacity(0.2), radius: 24, y: 0)

                    Text(L10n.appSubtitle)
                        .font(Theme.subtitleFont)
                        .foregroundColor(Theme.textTertiary)
                        .tracking(4)
                }
                .scaleEffect(titleScale)
                .opacity(titleOpacity)

                Spacer().frame(height: Theme.isCompactScreen ? Theme.spacingLG : Theme.spacingXXL)

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
                    PrimaryButton(title: L10n.startAdventure, icon: "play.fill") {
                        onNavigate(.map)
                    }
                    .padding(.horizontal, 60)
                    .offset(y: showButtons[0] ? 0 : 40)
                    .opacity(showButtons[0] ? 1.0 : 0)

                    SecondaryButton(title: L10n.quickStart, icon: "bolt.fill") {
                        onNavigate(.buildSelect)
                    }
                    .padding(.horizontal, 60)
                    .offset(y: showButtons[1] ? 0 : 40)
                    .opacity(showButtons[1] ? 1.0 : 0)

                    // Daily Challenge
                    dailyChallengeButton
                        .padding(.horizontal, 60)
                        .offset(y: showButtons[2] ? 0 : 40)
                        .opacity(showButtons[2] ? 1.0 : 0)

                    HStack(spacing: 12) {
                        SecondaryButton(title: L10n.cardCollection, icon: "rectangle.stack.fill") {
                            onNavigate(.collection)
                        }
                        SecondaryButton(title: L10n.settings, icon: "gearshape.fill") {
                            onNavigate(.settings)
                        }
                    }
                    .offset(y: showButtons[3] ? 0 : 40)
                    .opacity(showButtons[3] ? 1.0 : 0)
                }

                Spacer()

                // 版本信息
                Divider()
                    .frame(width: 40)
                    .background(Theme.border)
                    .padding(.bottom, 4)
                Text(L10n.versionString)
                    .font(.system(size: 10, weight: .light, design: .monospaced))
                    .foregroundColor(Theme.textDisabled.opacity(0.5))
                    .padding(.bottom, Theme.spacingMD)
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
            withAnimation(.easeInOut(duration: 1.5).repeatForever().delay(0.8)) {
                dailyPulse = true
            }
        }
    }
}

#Preview {
    HomeView(onNavigate: { _ in })
}
