import SwiftUI

struct StatsView: View {
    @ObservedObject var stats = PlayerStats.shared

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Theme.gold)
                    Text(L10n.isEnglish ? "Player Statistics" : "玩家统计")
                        .font(Theme.fontHeading)
                        .foregroundStyle(Theme.goldGradient)
                        .accessibilityAddTraits(.isHeader)
                }
                .padding(.top, Theme.spacingLG)

                if stats.totalRuns == 0 {
                    // Empty state for new users
                    VStack(spacing: Theme.spacingMD) {
                        Image(systemName: "target")
                            .font(Theme.fontStatNumber)
                            .foregroundColor(Theme.textTertiary)
                        Text(L10n.emptyStats)
                            .font(Theme.fontBody)
                            .foregroundColor(Theme.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingXXL)
                }

                // Overview cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: Theme.spacingMD) {
                    statCard(systemIcon: "figure.run", title: L10n.isEnglish ? "Total Runs" : "总冒险次数", value: "\(stats.totalRuns)")
                    statCard(systemIcon: "trophy.fill", title: L10n.isEnglish ? "Victories" : "通关次数", value: "\(stats.totalWins)")
                    statCard(systemIcon: "chart.line.uptrend.xyaxis", title: L10n.isEnglish ? "Win Rate" : "通关率", value: String(format: "%.0f%%", stats.winRate * 100))
                    statCard(systemIcon: "mountain.2.fill", title: L10n.isEnglish ? "Floors Cleared" : "通过关卡数", value: "\(stats.totalFloors)")
                    statCard(systemIcon: "suit.club.fill", title: L10n.isEnglish ? "Cards Played" : "出牌次数", value: "\(stats.totalCardsPlayed)")
                    statCard(systemIcon: "flame.fill", title: L10n.isEnglish ? "Best Combo" : "最高连击", value: "\(stats.highestCombo)")
                    statCard(systemIcon: "star.fill", title: L10n.isEnglish ? "Best Score" : "最高单次得分", value: "\(stats.highestSingleScore)")
                    statCard(systemIcon: "dollarsign.circle.fill", title: L10n.isEnglish ? "Gold Earned" : "总获金币", value: "\(stats.totalGoldEarned)")
                }
                .padding(.horizontal, Theme.spacingMD)

                // Play time
                CardPanel {
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.title2)
                            .foregroundColor(Theme.gold)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.isEnglish ? "Total Play Time" : "总游戏时长")
                                .font(Theme.fontCaption)
                                .foregroundColor(Theme.textTertiary)
                            Text(stats.formattedPlayTime)
                                .font(.title3.bold().monospacedDigit())
                                .foregroundColor(Theme.gold)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, Theme.spacingMD)
            }
            .padding(.bottom, Theme.spacingXXL)
            .frame(maxWidth: 600)
        }
        .frame(maxWidth: .infinity)
        .gameBackground()
    }

    private func statCard(systemIcon: String, title: String, value: String) -> some View {
        CardPanel {
            VStack(spacing: 8) {
                Image(systemName: systemIcon)
                    .font(.title2)
                    .foregroundColor(Theme.cyan)
                Text(value)
                    .font(.title3.bold().monospacedDigit())
                    .foregroundColor(Theme.gold)
                Text(title)
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}

#Preview {
    StatsView()
}
