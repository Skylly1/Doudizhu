import SwiftUI

/// Daily challenge detail screen — shows today's modifiers and lets the player start
struct DailyChallengeView: View {
    let onStart: (DailyChallenge) -> Void
    let onBack: () -> Void

    private let challenge = DailyChallenge.today
    private var played: Bool { DailyChallenge.hasPlayedToday }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                GameNavBar(
                    title: L10n.dailyChallengeTitle,
                    onBack: onBack
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Theme.spacingLG) {
                        // Date card
                        dateCard

                        // Modifiers section
                        modifiersSection

                        // Rewards section
                        rewardsSection

                        // Best score (if played)
                        if played {
                            bestScoreCard
                        }

                        // Start button
                        startButton
                    }
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.top, Theme.spacingSM)
                    .padding(.bottom, Theme.spacingXXL)
                }
            }
        }
        .gameBackground()
    }

    private var dateCard: some View {
        HStack {
            Image(systemName: "calendar")
                .font(.system(size: 32))
                .foregroundColor(Theme.gold)

            VStack(alignment: .leading, spacing: 4) {
                Text(dateString)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                Text(played
                     ? L10n.dailyChallengeCompleted
                     : L10n.dailyChallenge)
                    .font(.subheadline)
                    .foregroundColor(played ? Theme.success : Theme.gold)
            }

            Spacer()
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(Theme.bgCard)
                .stroke(Theme.border)
        )
    }

    private var modifiersSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text(L10n.todayModifiers)
                .font(Theme.fontSection)
                .foregroundColor(Theme.textPrimary)

            ForEach(challenge.modifiers, id: \.rawValue) { modifier in
                HStack(spacing: 12) {
                    Image(systemName: modifier.icon)
                        .font(.title2)
                        .foregroundColor(Theme.flame)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(modifier.name)
                            .font(.body.bold())
                            .foregroundColor(Theme.textPrimary)
                        Text(modifierDescription(modifier))
                            .font(Theme.fontCaption)
                            .foregroundColor(Theme.textTertiary)
                    }

                    Spacer()
                }
                .padding(Theme.spacingSM)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(Theme.bgInset)
                        .stroke(Theme.borderLight)
                )
            }
        }
    }

    private var rewardsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack(spacing: Theme.spacingSM) {
                rewardItem(
                    systemIcon: "sparkles",
                    iconColor: Theme.gold,
                    title: L10n.rewardMultiplier,
                    value: scoreMultiplierText
                )
                rewardItem(
                    systemIcon: "dollarsign.circle.fill",
                    iconColor: Theme.gold,
                    title: L10n.bonusGoldLabel,
                    value: "+\(challenge.bonusGold)"
                )
            }
        }
    }

    private func rewardItem(systemIcon: String, iconColor: Color, title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemIcon)
                .font(.title)
                .foregroundColor(iconColor)
            Text(title)
                .font(Theme.fontCaption)
                .foregroundColor(Theme.textTertiary)
            Text(value)
                .font(.body.bold().monospacedDigit())
                .foregroundColor(Theme.gold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingSM)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusSM)
                .fill(Theme.bgCard)
                .stroke(Theme.borderLight)
        )
    }

    private var bestScoreCard: some View {
        let best = DailyChallenge.todayBest
        return HStack {
            Image(systemName: "trophy.fill")
                .foregroundColor(Theme.gold)
                .font(.title2)
            Text(L10n.dailyBestScore(best))
                .font(.body.bold().monospacedDigit())
                .foregroundColor(Theme.textPrimary)
            Spacer()
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(Theme.gold.opacity(0.1))
                .stroke(Theme.gold.opacity(0.3))
        )
    }

    private var startButton: some View {
        Group {
            if played {
                SecondaryButton(
                    title: L10n.dailyChallengeCompleted,
                    icon: "checkmark.circle.fill",
                    color: Theme.textDisabled
                ) { }
                .disabled(true)
            } else {
                PrimaryButton(title: L10n.startDailyChallenge, icon: "play.fill") {
                    onStart(challenge)
                }
            }
        }
        .padding(.horizontal, Theme.spacingMD)
    }

    // MARK: - Helpers

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: challenge.date)
    }

    private var scoreMultiplierText: String {
        let hasDouble = challenge.modifiers.contains(.doubleScore)
        return hasDouble ? "×2.0" : "×1.0"
    }

    private func modifierDescription(_ modifier: DailyChallengeModifier) -> String {
        switch modifier {
        case .noBombs: return L10n.dailyChallengeNoBombs
        case .halfGold: return L10n.isEnglish ? "Start with half the normal gold" : "起始金币减半"
        case .extraPlays: return L10n.isEnglish ? "+2 extra plays per floor" : "每层额外 +2 次出牌"
        case .noDiscards: return L10n.dailyChallengeNoDiscards
        case .doubleScore: return L10n.isEnglish ? "All scores are doubled" : "所有得分翻倍"
        case .speedRun: return L10n.isEnglish ? "Max 3 plays per floor" : "每层最多 3 次出牌"
        case .bossRush: return L10n.isEnglish ? "Every 3rd floor is a boss" : "每 3 层出现 Boss"
        case .giantHand: return L10n.isEnglish ? "Hand size +5 cards" : "手牌数量 +5 张"
        case .tinyDeck: return L10n.isEnglish ? "Deck reduced to 36 cards" : "牌堆缩减至 36 张"
        case .allOrNothing: return L10n.isEnglish ? "Only bombs & rockets score" : "仅炸弹和火箭可得分"
        case .goldRush: return L10n.isEnglish ? "×3 gold, but shop prices ×2" : "金币×3，商店价格×2"
        case .mirrorMatch: return L10n.isEnglish ? "Boss modifiers on every floor" : "每层都有Boss修改器"
        }
    }
}

#Preview {
    DailyChallengeView(onStart: { _ in }, onBack: { })
}
