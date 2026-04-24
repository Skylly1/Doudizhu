import SwiftUI

struct StatsView: View {
    @ObservedObject var stats = PlayerStats.shared

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // Header
                VStack(spacing: 8) {
                    Text("📊")
                        .font(.system(size: 48))
                    Text(L10n.isEnglish ? "Player Statistics" : "玩家统计")
                        .font(Theme.fontHeading)
                        .foregroundStyle(Theme.goldGradient)
                }
                .padding(.top, Theme.spacingLG)

                if stats.totalRuns == 0 {
                    // Empty state for new users
                    VStack(spacing: Theme.spacingMD) {
                        Text("🎯")
                            .font(.system(size: 56))
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
                    statCard(icon: "🏃", title: L10n.isEnglish ? "Total Runs" : "总冒险次数", value: "\(stats.totalRuns)")
                    statCard(icon: "🏆", title: L10n.isEnglish ? "Victories" : "通关次数", value: "\(stats.totalWins)")
                    statCard(icon: "📈", title: L10n.isEnglish ? "Win Rate" : "通关率", value: String(format: "%.0f%%", stats.winRate * 100))
                    statCard(icon: "🏔️", title: L10n.isEnglish ? "Floors Cleared" : "通过关卡数", value: "\(stats.totalFloors)")
                    statCard(icon: "🃏", title: L10n.isEnglish ? "Cards Played" : "出牌次数", value: "\(stats.totalCardsPlayed)")
                    statCard(icon: "🔥", title: L10n.isEnglish ? "Best Combo" : "最高连击", value: "\(stats.highestCombo)")
                    statCard(icon: "⭐", title: L10n.isEnglish ? "Best Score" : "最高单次得分", value: "\(stats.highestSingleScore)")
                    statCard(icon: "💰", title: L10n.isEnglish ? "Gold Earned" : "总获金币", value: "\(stats.totalGoldEarned)")
                }
                .padding(.horizontal, Theme.spacingMD)

                // Play time
                CardPanel {
                    HStack {
                        Text("⏱️")
                            .font(.title2)
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
        }
        .gameBackground()
    }

    private func statCard(icon: String, title: String, value: String) -> some View {
        CardPanel {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.title2)
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
    }
}

#Preview {
    StatsView()
}
