import SwiftUI

/// 试玩结束 → 付费解锁引导页（转化优化版）
struct DemoGateView: View {
    @ObservedObject var purchaseManager: PurchaseManager
    let onContinue: () -> Void
    let onBack: () -> Void

    // 试玩成绩（从 PlayerStats 读取 — 情感锚点）
    private var floorsCleared: Int {
        UserDefaults.standard.integer(forKey: "stats_highestFloor")
    }
    private var bestScore: Int {
        UserDefaults.standard.integer(forKey: "stats_highestSingleScore")
    }
    private var bestCombo: Int {
        max(UserDefaults.standard.integer(forKey: "stats_highestCombo"), 1)
    }

    @State private var showContent = false
    @State private var pulseButton = false

    var body: some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            // 双层金色光晕
            RadialGradient(
                colors: [Theme.gold.opacity(0.10), Color.clear],
                center: .top, startRadius: 0, endRadius: 350
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Spacer().frame(height: 24)

                    // === 试玩成绩回顾（情感锚点）===
                    trialStatsSection

                    // === 内容预览 ===
                    contentPreviewSection

                    // === 完整版特权 ===
                    featuresSection

                    // === 购买区 ===
                    purchaseSection

                    Spacer().frame(height: 16)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            Analytics.shared.track(.paywallShown, params: [
                "floor_reached": "\(floorsCleared)",
                "best_score": "\(bestScore)",
                "best_combo": "\(bestCombo)"
            ])
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.8)) {
                pulseButton = true
            }
        }
    }

    // MARK: - 试玩成绩回顾

    private var trialStatsSection: some View {
        VStack(spacing: 12) {
            Text(L10n.demoGateTrialSummary)
                .font(.caption.bold())
                .foregroundColor(Theme.textTertiary)
                .textCase(.uppercase)
                .tracking(1.5)

            HStack(spacing: 16) {
                statBadge(
                    icon: "flag.checkered",
                    value: L10n.demoGateFloorsCleared(max(floorsCleared, 1)),
                    color: Theme.cyan
                )
                statBadge(
                    icon: "star.fill",
                    value: L10n.demoGateBestScore(bestScore),
                    color: Theme.gold
                )
                statBadge(
                    icon: "flame.fill",
                    value: L10n.demoGateBestCombo(bestCombo),
                    color: Theme.flame
                )
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusLG)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: Theme.radiusLG)
                    .stroke(Theme.gold.opacity(0.15)))
        )
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }

    private func statBadge(icon: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Theme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 内容预览（好奇心驱动）

    private var contentPreviewSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text(L10n.demoGateWhatsNext)
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textPrimary)
                Spacer()
            }

            // 展示付费后即将体验的3个关键关卡
            VStack(spacing: 8) {
                nextFloorRow(
                    icon: "🏛️", name: L10n.floor6Name,
                    desc: L10n.isEnglish ? "Boss modifier: Hand Shrink + Pair Tax" : "Boss修改器：手牌缩减 + 对子税",
                    color: Theme.cyan
                )
                nextFloorRow(
                    icon: "⚔️", name: L10n.floor8Name,
                    desc: L10n.isEnglish ? "Magistrate Boss — bans one pattern!" : "县令Boss — 禁用一种牌型！",
                    color: Theme.flame
                )
                nextFloorRow(
                    icon: "👑", name: L10n.floor15Name,
                    desc: L10n.isEnglish ? "Final Boss — decaying score + phantom cards!" : "最终Boss — 得分递减 + 幻影牌！",
                    color: Theme.gold
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusLG)
                .fill(Theme.bgCard)
                .overlay(RoundedRectangle(cornerRadius: Theme.radiusLG)
                    .stroke(Theme.gold.opacity(0.12)))
        )
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }

    private func nextFloorRow(icon: String, name: String, desc: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Text(icon)
                .font(.title3)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.bold())
                    .foregroundColor(color)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundColor(Theme.textDisabled)
        }
        .padding(.vertical, 6)
    }

    // MARK: - 完整版特权

    private var featuresSection: some View {
        VStack(spacing: 0) {
            // 进度条 — 展示已解锁比例
            let totalFloors = FloorConfig.allFloors.count
            let unlockedPercent = Int(Double(PurchaseManager.demoMaxFloor) / Double(totalFloors) * 100)

            VStack(spacing: 6) {
                HStack {
                    Text(L10n.isEnglish ? "Content Unlocked" : "内容解锁进度")
                        .font(.caption.bold())
                        .foregroundColor(Theme.textSecondary)
                    Spacer()
                    Text("\(unlockedPercent)% → 100%")
                        .font(.caption.bold().monospacedDigit())
                        .foregroundColor(Theme.gold)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.bgInset)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.goldGradient)
                            .frame(width: geo.size.width * CGFloat(unlockedPercent) / 100.0)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider().background(Theme.gold.opacity(0.1))

            // 特权列表
            VStack(alignment: .leading, spacing: 12) {
                featureRow(systemIcon: "mountain.2.fill", color: Theme.cyan, text: L10n.featureAllFloors)
                featureRow(systemIcon: "flame.fill", color: Theme.flame, text: L10n.featureAscension)
                featureRow(systemIcon: "suit.spade.fill", color: Theme.gold, text: L10n.featureJokers)
                featureRow(systemIcon: "trophy.fill", color: Theme.gold, text: L10n.featureLeaderboard)
                featureRow(systemIcon: "arrow.triangle.2.circlepath", color: Theme.success, text: L10n.featureUpdates)
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusLG)
                .fill(Theme.bgCard)
                .overlay(RoundedRectangle(cornerRadius: Theme.radiusLG)
                    .stroke(Theme.gold.opacity(0.2)))
        )
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }

    // MARK: - 购买区

    private var purchaseSection: some View {
        VStack(spacing: 12) {
            // 主购买按钮
            Button {
                Task {
                    let success = await purchaseManager.purchaseFullVersion()
                    if success {
                        Analytics.shared.track(.paywallConverted, params: [
                            "price": purchaseManager.formattedPrice
                        ])
                        onContinue()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                    Text(L10n.unlockFullPrice(purchaseManager.formattedPrice))
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .fill(Theme.goldGradient)
                )
                .shadow(color: Theme.gold.opacity(pulseButton ? 0.5 : 0.2), radius: pulseButton ? 16 : 8, y: 4)
                .scaleEffect(pulseButton ? 1.02 : 1.0)
            }
            .disabled(purchaseManager.purchaseState == .purchasing)

            // 恢复购买
            Button(L10n.restorePurchase) {
                Task { await purchaseManager.restorePurchases() }
            }
            .font(Theme.fontCaption)
            .foregroundColor(Theme.textDisabled)

            // 每日挑战免费提示 + 返回
            HStack(spacing: 16) {
                Text(L10n.demoGateDailyFree)
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)

                Button(L10n.backToMenu) {
                    Analytics.shared.track(.paywallDismissed, params: [
                        "floor_reached": "\(floorsCleared)"
                    ])
                    onBack()
                }
                    .font(.caption.bold())
                    .foregroundColor(Theme.textTertiary)
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Helper

    private func featureRow(systemIcon: String, color: Color, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemIcon)
                .font(.body)
                .foregroundColor(color)
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
    }
}
