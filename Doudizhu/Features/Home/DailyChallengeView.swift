import SwiftUI

/// Daily challenge detail screen — shows today's modifiers and lets the player start
struct DailyChallengeView: View {
    let onStart: (DailyChallenge) -> Void
    let onBack: () -> Void

    private let challenge = DailyChallenge.today
    private var played: Bool { DailyChallenge.hasPlayedToday }

    var body: some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.ultraThinMaterial)
                            .symbolRenderingMode(.hierarchical)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.dailyChallengeTitle)
                            .font(Theme.fontSection)
                            .foregroundColor(Theme.textPrimary)
                        Text(L10n.dailyChallengeSubtitle)
                            .font(Theme.fontCaption)
                            .foregroundColor(Theme.textTertiary)
                    }

                    Spacer()
                }
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)

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
    }

    // MARK: - Subviews

    private var dateCard: some View {
        HStack {
            Text("📅")
                .font(.system(size: 40))

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
                    Text(modifier.icon)
                        .font(.title2)

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
                    icon: "✨",
                    title: L10n.rewardMultiplier,
                    value: scoreMultiplierText
                )
                rewardItem(
                    icon: "💰",
                    title: L10n.bonusGoldLabel,
                    value: "+\(challenge.bonusGold)"
                )
            }
        }
    }

    private func rewardItem(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(icon)
                .font(.title)
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
        }
    }
}

#Preview {
    DailyChallengeView(onStart: { _ in }, onBack: { })
}
