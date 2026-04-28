import SwiftUI

/// 游戏帮助与 FAQ — 玩家随时可查阅的完整指南
struct HelpView: View {
    let onBack: () -> Void
    @State private var expandedSections: Set<String> = []

    var body: some View {
        VStack(spacing: 0) {
            GameNavBar(title: L10n.helpTitle, onBack: onBack)

            ScrollView {
                VStack(spacing: Theme.spacingMD) {
                    // 快速入门
                    faqSection(
                        id: "quickstart",
                        icon: "play.circle.fill",
                        title: L10n.helpQuickStartTitle,
                        content: L10n.helpQuickStartBody
                    )

                    // 牌型说明
                    faqSection(
                        id: "patterns",
                        icon: "rectangle.stack.fill",
                        title: L10n.helpPatternsTitle,
                        content: L10n.helpPatternsBody
                    )

                    // 计分系统
                    faqSection(
                        id: "scoring",
                        icon: "number.circle.fill",
                        title: L10n.helpScoringTitle,
                        content: L10n.helpScoringBody
                    )

                    // 规则牌
                    faqSection(
                        id: "jokers",
                        icon: "sparkles",
                        title: L10n.helpJokersTitle,
                        content: L10n.helpJokersBody
                    )

                    // 增益道具
                    faqSection(
                        id: "buffs",
                        icon: "bolt.fill",
                        title: L10n.helpBuffsTitle,
                        content: L10n.helpBuffsBody
                    )

                    // 商店
                    faqSection(
                        id: "shop",
                        icon: "cart.fill",
                        title: L10n.helpShopTitle,
                        content: L10n.helpShopBody
                    )

                    // Boss关
                    faqSection(
                        id: "boss",
                        icon: "shield.lefthalf.filled",
                        title: L10n.helpBossTitle,
                        content: L10n.helpBossBody
                    )

                    // 成就与解锁
                    faqSection(
                        id: "achievements",
                        icon: "trophy.fill",
                        title: L10n.helpAchievementsTitle,
                        content: L10n.helpAchievementsBody
                    )

                    // 每日挑战
                    faqSection(
                        id: "daily",
                        icon: "calendar.badge.clock",
                        title: L10n.helpDailyTitle,
                        content: L10n.helpDailyBody
                    )

                    // Ascension 挑战
                    faqSection(
                        id: "ascension",
                        icon: "flame.fill",
                        title: L10n.helpAscensionTitle,
                        content: L10n.helpAscensionBody
                    )

                    // 策略小贴士
                    faqSection(
                        id: "tips",
                        icon: "lightbulb.fill",
                        title: L10n.helpTipsTitle,
                        content: L10n.helpTipsBody
                    )
                }
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingMD)
            }
            .frame(maxWidth: 600)
        }
        .frame(maxWidth: .infinity)
        .gameBackground()
    }

    // MARK: - FAQ 折叠区块

    private func faqSection(id: String, icon: String, title: String, content: String) -> some View {
        let isExpanded = expandedSections.contains(id)
        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if isExpanded {
                        expandedSections.remove(id)
                    } else {
                        expandedSections.insert(id)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(Theme.gold)
                        .frame(width: 28)

                    Text(title)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(Theme.textTertiary)
                        .accessibilityHidden(true)
                }
                .padding(Theme.spacingMD)
            }
            .accessibilityLabel(title)
            .accessibilityHint(isExpanded ? "双击收起" : "双击展开查看详情")

            if isExpanded {
                Divider().background(Theme.border)

                Text(content)
                    .font(Theme.fontBody)
                    .foregroundColor(Theme.textSecondary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(Theme.spacingMD)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .stroke(Theme.gold.opacity(isExpanded ? 0.2 : 0.08), lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }
}

#Preview {
    HelpView(onBack: {})
}
