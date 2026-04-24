import SwiftUI

/// 试玩结束 → 付费解锁引导页
struct DemoGateView: View {
    @ObservedObject var purchaseManager: PurchaseManager
    let onContinue: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // 标题
                Text("🎴")
                    .font(.system(size: 72))

                Text("试玩结束")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange],
                                       startPoint: .top, endPoint: .bottom)
                    )

                Text("你已体验了斗破乾坤的核心玩法！\n解锁完整版，继续挑战更高层数。")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // 完整版特权
                VStack(alignment: .leading, spacing: 12) {
                    featureRow(icon: "🏔️", text: "全部 8 层关卡 + 终极 Boss")
                    featureRow(icon: "🃏", text: "10 张规则牌，无限流派搭配")
                    featureRow(icon: "🏆", text: "排行榜 + 成就系统（即将推出）")
                    featureRow(icon: "🔄", text: "持续更新：新牌、新关卡、新模式")
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.05))
                        .stroke(.yellow.opacity(0.2))
                )

                Spacer()

                // 购买按钮
                Button {
                    Task {
                        let success = await purchaseManager.purchaseFullVersion()
                        if success {
                            onContinue()
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("解锁完整版 — ¥18")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(colors: [.yellow, .orange],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                    )
                }
                .padding(.horizontal, 32)

                // 恢复购买
                Button("恢复购买") {
                    Task { await purchaseManager.restorePurchases() }
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))

                // 返回主菜单
                Button("返回主菜单", action: onBack)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 20)
            }
            .padding()
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Text(icon).font(.title3)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
        }
    }
}
