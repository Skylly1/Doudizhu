import SwiftUI

/// 试玩结束 → 付费解锁引导页
struct DemoGateView: View {
    @ObservedObject var purchaseManager: PurchaseManager
    let onContinue: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            // 金色光晕
            RadialGradient(
                colors: [Theme.gold.opacity(0.08), Color.clear],
                center: .center, startRadius: 0, endRadius: 300
            )
            .ignoresSafeArea()

            VStack(spacing: Theme.spacingLG) {
                Spacer()

                Image(systemName: "suit.spade.fill")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(Theme.goldGradient)

                Text(L10n.demoOver)
                    .font(Theme.fontHeading)
                    .foregroundStyle(Theme.goldGradient)

                Text(L10n.demoDescription)
                    .font(Theme.fontBody)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // 进度指示器 — 展示已解锁比例
                let demoFloors = 5
                let totalFloors = FloorConfig.allFloors.count
                let unlockedPercent = Int(Double(demoFloors) / Double(totalFloors) * 100)
                VStack(spacing: 6) {
                    HStack {
                        Text(L10n.isEnglish ? "Content Unlocked" : "已解锁内容")
                            .font(.caption.bold())
                            .foregroundColor(Theme.textSecondary)
                        Spacer()
                        Text("\(unlockedPercent)%")
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

                    let remainingFloors = totalFloors - demoFloors
                    let totalJokers = Joker.allJokers.count
                    Text(L10n.isEnglish
                         ? "Purchase to unlock \(remainingFloors) more floors, \(totalJokers)+ Jokers & all future updates"
                         : "购买解锁\(remainingFloors)层关卡、\(totalJokers)+规则牌及所有后续更新")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Theme.spacingLG)

                // 完整版特权
                VStack(alignment: .leading, spacing: 14) {
                    featureRow(systemIcon: "mountain.2.fill", color: Theme.cyan, text: L10n.featureAllFloors)
                    featureRow(systemIcon: "flame.fill", color: Theme.flame, text: L10n.featureAscension)
                    featureRow(systemIcon: "suit.spade.fill", color: Theme.gold, text: L10n.featureJokers)
                    featureRow(systemIcon: "trophy.fill", color: Theme.gold, text: L10n.featureLeaderboard)
                    featureRow(systemIcon: "arrow.triangle.2.circlepath", color: Theme.success, text: L10n.featureUpdates)
                }
                .padding(Theme.spacingLG)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusLG)
                        .fill(Theme.bgCard)
                        .stroke(Theme.gold.opacity(0.2))
                )

                Spacer()

                // 购买按钮
                Button {
                    Task {
                        let success = await purchaseManager.purchaseFullVersion()
                        if success { onContinue() }
                    }
                } label: {
                    HStack {
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
                    .shadow(color: Theme.gold.opacity(0.3), radius: 10, y: 4)
                }
                .padding(.horizontal, Theme.spacingXL)

                Button(L10n.restorePurchase) {
                    Task { await purchaseManager.restorePurchases() }
                }
                .font(Theme.fontCaption)
                .foregroundColor(Theme.textDisabled)

                Button(L10n.backToMenu, action: onBack)
                    .font(.subheadline)
                    .foregroundColor(Theme.textTertiary)
                    .padding(.bottom, Theme.spacingMD)
            }
            .padding()
        }
    }

    private func featureRow(systemIcon: String, color: Color, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemIcon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
    }
}
