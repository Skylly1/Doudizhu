import SwiftUI

/// 试玩结束 → 付费解锁引导页（转化优化版 v2）
/// 优化：祝贺过渡、损失规避、首次免费体验、重复访客适配、SF Symbols
struct DemoGateView: View {
    @ObservedObject var purchaseManager: PurchaseManager
    let onContinue: () -> Void
    let onBack: () -> Void
    var equippedJokers: [Joker] = []
    var equippedBuffs: [Buff] = []

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

    /// 付费墙展示次数 — 首次 vs 回访用不同话术
    private var paywallViewCount: Int {
        Analytics.shared.totalEventCount(for: .paywallShown)
    }
    private var isFirstView: Bool { paywallViewCount <= 1 }

    @AppStorage("demo_gate_free_peek_used") private var freePeekUsed = false
    @State private var showContent = false
    @State private var pulseButton = false
    @State private var congratsScale: CGFloat = 0.6
    @State private var congratsOpacity: Double = 0

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
                VStack(spacing: 18) {
                    Spacer().frame(height: 16)

                    // === 祝贺过渡（缓解付费墙突兀感）===
                    congratsHeader

                    // === 试玩成绩回顾（情感锚点）===
                    trialStatsSection

                    // === 社交证明 ===
                    socialProofSection

                    // === 当前装备展示（损失规避）===
                    if !equippedJokers.isEmpty || !equippedBuffs.isEmpty {
                        equippedSection
                    }

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
                "best_combo": "\(bestCombo)",
                "view_count": "\(paywallViewCount)"
            ])
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                congratsScale = 1.0
                congratsOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.8)) {
                pulseButton = true
            }
        }
        .fullScreenCover(isPresented: $showPurchaseSuccess) {
            PurchaseSuccessView {
                showPurchaseSuccess = false
                onContinue()
            }
        }
    }

    // MARK: - 祝贺过渡

    private var congratsHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "trophy.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.goldGradient)
                .shadow(color: Theme.gold.opacity(0.4), radius: 12)

            Text(isFirstView
                 ? (L10n.isEnglish ? "Impressive Run!" : "精彩的冒险！")
                 : (L10n.isEnglish ? "Welcome Back, Challenger!" : "欢迎回来，挑战者！"))
                .font(.title2.bold())
                .foregroundStyle(Theme.goldGradient)

            Text(isFirstView
                 ? (L10n.isEnglish ? "You've conquered the Village — the real challenge begins now." : "你已征服乡野 — 真正的挑战才刚开始。")
                 : (L10n.isEnglish ? "The City and Jianghu chapters await your return." : "府城暗局与江湖争霸，等你再战。"))
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .scaleEffect(congratsScale)
        .opacity(congratsOpacity)
    }

    // MARK: - 社交证明

    private var socialProofSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 2) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(Theme.gold)
                }
            }
            
            Text(L10n.isEnglish
                 ? "\"Best card game since Balatro!\" — loved by players"
                 : "\"自 Balatro 以来最好的卡牌游戏！\" — 玩家好评")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .italic()
        }
        .padding(.vertical, 10)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(value)
    }

    // MARK: - 当前装备（损失规避）

    private var equippedSection: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(Theme.flame)
                Text(L10n.isEnglish ? "Your Build Will Be Lost" : "你的构筑将会丢失")
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.flame)
                Spacer()
            }

            if !equippedJokers.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(equippedJokers) { joker in
                        HStack(spacing: 3) {
                            Image(systemName: joker.effect.systemIcon).font(.caption2)
                            Text(joker.name).font(.caption2)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Theme.cyanDim))
                        .foregroundColor(Theme.cyan)
                    }
                }
            }

            if !equippedBuffs.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(equippedBuffs) { buff in
                        HStack(spacing: 3) {
                            Image(systemName: buff.type.systemIcon).font(.caption2)
                            Text(buff.name).font(.caption2)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Theme.flameDim))
                        .foregroundColor(Theme.flame)
                    }
                }
            }

            Text(L10n.isEnglish
                 ? "Unlock full version to keep your jokers & buffs for the next chapter!"
                 : "解锁完整版，你的规则牌和增益将伴随你闯入下一章！")
                .font(.caption)
                .foregroundColor(Theme.textTertiary)
                .multilineTextAlignment(.leading)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusLG)
                .fill(Theme.flame.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: Theme.radiusLG)
                    .stroke(Theme.flame.opacity(0.2)))
        )
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
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

            VStack(spacing: 8) {
                nextFloorRow(
                    systemIcon: "building.2.fill", name: L10n.floor6Name,
                    desc: L10n.isEnglish ? "Boss modifier: Hand Shrink + Pair Tax" : "Boss修改器：手牌缩减 + 对子税",
                    color: Theme.cyan
                )
                nextFloorRow(
                    systemIcon: "shield.lefthalf.filled", name: L10n.floor8Name,
                    desc: L10n.isEnglish ? "Magistrate Boss — bans one pattern!" : "县令Boss — 禁用一种牌型！",
                    color: Theme.flame
                )
                nextFloorRow(
                    systemIcon: "crown.fill", name: L10n.floor15Name,
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

    private func nextFloorRow(systemIcon: String, name: String, desc: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemIcon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.bold())
                    .foregroundColor(color)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundColor(Theme.textDisabled)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name)，\(desc)")
    }

    // MARK: - 完整版特权

    private var featuresSection: some View {
        VStack(spacing: 0) {
            // 进度条
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

    @State private var showPurchaseSuccess = false

    private var purchaseSection: some View {
        VStack(spacing: 12) {
            // 待审批提示
            if purchaseManager.purchaseState == .pending {
                HStack(spacing: 8) {
                    Image(systemName: "clock.badge.checkmark")
                        .foregroundColor(Theme.gold)
                    Text(purchaseManager.pendingMessage)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .fill(Theme.gold.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .stroke(Theme.gold.opacity(0.2)))
                )
            }

            // 价格锚定（首发限时标签）
            if isFirstView {
                HStack(spacing: 6) {
                    Text(L10n.isEnglish ? "Launch Special" : "首发特惠")
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Theme.gold))
                    
                    Text(L10n.isEnglish ? "Limited-time price" : "限时价格")
                        .font(.caption)
                        .foregroundColor(Theme.gold.opacity(0.8))
                }
            }

            // 主购买按钮
            Button {
                Task {
                    let success = await purchaseManager.purchaseFullVersion()
                    if success {
                        Analytics.shared.track(.paywallConverted, params: [
                            "price": purchaseManager.formattedPrice,
                            "view_count": "\(paywallViewCount)"
                        ])
                        showPurchaseSuccess = true
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if purchaseManager.purchaseState == .purchasing {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Image(systemName: "crown.fill")
                    }
                    Text(purchaseManager.purchaseState == .purchasing
                         ? (L10n.isEnglish ? "Processing..." : "处理中...")
                         : L10n.unlockFullPrice(purchaseManager.formattedPrice))
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
            .accessibilityLabel("解锁完整版")
            .accessibilityHint("购买完整版游戏，价格\(purchaseManager.formattedPrice)")

            // 购买失败提示
            if case .failed(let msg) = purchaseManager.purchaseState {
                Text(msg)
                    .font(.caption)
                    .foregroundColor(Theme.flame)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }

            // 免费体验一层（仅首次展示且未使用过）
            if !freePeekUsed && isFirstView {
                Button {
                    freePeekUsed = true
                    Analytics.shared.track(.paywallFreePeek, params: [
                        "floor_reached": "\(floorsCleared)"
                    ])
                    onContinue()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "gift.fill")
                            .font(.subheadline)
                        Text(L10n.isEnglish ? "Try 1 More Floor Free" : "免费体验下一层")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(Theme.cyan)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .fill(Theme.cyanDim)
                            .overlay(RoundedRectangle(cornerRadius: Theme.radiusMD)
                                .stroke(Theme.cyan.opacity(0.3)))
                    )
                }
                .accessibilityLabel("免费体验下一层")
                .accessibilityHint("免费体验一层，不需要付费")
            }

            // 恢复购买
            Button(L10n.restorePurchase) {
                Task { await purchaseManager.restorePurchases() }
            }
            .font(Theme.fontCaption)
            .foregroundColor(Theme.textDisabled)
            .accessibilityLabel("恢复购买")
            .accessibilityHint("恢复之前的购买记录")

            // 每日挑战免费提示 + 返回
            HStack(spacing: 16) {
                Text(L10n.demoGateDailyFree)
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)

                Button(L10n.backToMenu) {
                    Analytics.shared.track(.paywallDismissed, params: [
                        "floor_reached": "\(floorsCleared)",
                        "action": "back"
                    ])
                    onBack()
                }
                .font(.caption.bold())
                .foregroundColor(Theme.textTertiary)
                .accessibilityLabel("返回主菜单")
                .accessibilityHint("不购买，返回主菜单")
            }
            .padding(.top, 4)

            // 回访用户加强文案
            if !isFirstView {
                Text(L10n.isEnglish
                     ? "💡 Launch price — one-time purchase. No ads, no subscriptions."
                     : "💡 首发限时价 — 一次购买，永久拥有。无广告、无订阅。")
                    .font(.caption)
                    .foregroundColor(Theme.gold.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
            }
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}
