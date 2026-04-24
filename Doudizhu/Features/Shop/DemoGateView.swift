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

                Text("🎴")
                    .font(.system(size: 72))

                Text(L10n.demoOver)
                    .font(Theme.fontHeading)
                    .foregroundStyle(Theme.goldGradient)

                Text(L10n.demoDescription)
                    .font(Theme.fontBody)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // 完整版特权
                VStack(alignment: .leading, spacing: 14) {
                    featureRow(icon: "🏔️", text: "全部 15 层关卡 + 3 大 Boss 挑战")
                    featureRow(icon: "🔥", text: "挑战等级系统(Ascension) — 10级难度")
                    featureRow(icon: "🃏", text: "20 张规则牌，无限流派搭配")
                    featureRow(icon: "🏆", text: "排行榜 + 成就系统")
                    featureRow(icon: "🔄", text: "持续更新：新牌、新关卡、新模式")
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
                        Text(L10n.unlockFullPrice("¥18"))
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

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Text(icon).font(.title3)
            Text(text)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
    }
}
