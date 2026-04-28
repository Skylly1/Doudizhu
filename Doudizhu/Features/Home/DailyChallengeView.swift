import SwiftUI

/// Daily challenge detail screen — shows today's modifiers and lets the player start
struct DailyChallengeView: View {
    let onStart: (DailyChallenge) -> Void
    let onResume: (() -> Void)?
    let onBack: () -> Void

    private let challenge = DailyChallenge.today
    private var completed: Bool { DailyChallenge.hasCompletedToday }
    private var inProgress: Bool { DailyChallenge.hasInProgressToday }

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

                        // 连续挑战 streak
                        if DailyChallenge.currentStreak > 0 {
                            streakBadge
                        }

                        // Modifiers section
                        modifiersSection

                        // Rewards section
                        rewardsSection

                        // Best score (if completed)
                        if completed {
                            bestScoreCard
                        }

                        // Start button
                        startButton
                    }
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.top, Theme.spacingSM)
                    .padding(.bottom, Theme.spacingXXL)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .gameBackground()
    }

    private var dateCard: some View {
        HStack {
            Image(systemName: "calendar")
                .font(Theme.fontIconMedium)
                .foregroundColor(Theme.gold)

            VStack(alignment: .leading, spacing: 4) {
                Text(dateString)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                Text(completed
                     ? L10n.dailyChallengeCompleted
                     : (inProgress ? (L10n.isEnglish ? "In Progress" : "挑战进行中") : L10n.dailyChallenge))
                    .font(.subheadline)
                    .foregroundColor(completed ? Theme.success : (inProgress ? Theme.flame : Theme.gold))
            }

            Spacer()
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(Theme.bgCard)
                .stroke(Theme.border)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.isEnglish ? "Daily Challenge" : "每日挑战")
        .accessibilityValue(completed ? L10n.dailyChallengeCompleted : (inProgress ? (L10n.isEnglish ? "In Progress" : "进行中") : dateString))
    }

    private var streakBadge: some View {
        let streak = DailyChallenge.currentStreak
        return VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundColor(streak >= 7 ? Theme.gold : Theme.flame)
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.isEnglish ? "\(streak)-Day Streak!" : "连续\(streak)天挑战！")
                        .font(.subheadline.bold())
                        .foregroundColor(streak >= 7 ? Theme.gold : Theme.flame)
                    Text(L10n.isEnglish ? "Keep it going — don't break the chain!" : "继续保持，不要断链！")
                        .font(.caption)
                        .foregroundColor(Theme.textTertiary)
                }
                Spacer()
                if streak >= 7 {
                    Image(systemName: "star.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.gold)
                }
            }

            // 下一个里程碑奖励预告
            if let next = DailyChallenge.nextMilestone {
                HStack(spacing: 6) {
                    Text(next.icon)
                        .font(.caption)
                    Text(L10n.isEnglish
                         ? "Day \(next.milestone): \(next.description)"
                         : "第\(next.milestone)天: \(next.description)")
                        .font(.caption2)
                        .foregroundColor(Theme.gold)
                    Spacer()
                    // 进度条
                    let progress = min(Double(streak) / Double(next.milestone), 1.0)
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Theme.bgInset)
                            .frame(width: 50, height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Theme.goldGradient)
                            .frame(width: 50 * progress, height: 4)
                    }
                }
            }
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(streak >= 7 ? Theme.gold.opacity(0.08) : Theme.flame.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .stroke(streak >= 7 ? Theme.gold.opacity(0.2) : Theme.flame.opacity(0.2)))
        )
        .accessibilityLabel(L10n.isEnglish ? "\(streak) day streak" : "连续\(streak)天")
    }

    private var modifiersSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text(L10n.todayModifiers)
                .font(Theme.fontSection)
                .foregroundColor(Theme.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text(L10n.isEnglish
                 ? "Today's special rules that change the challenge"
                 : "今日挑战的特殊规则，改变游戏玩法")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)

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
            HStack(spacing: Theme.spacingSM) {
                rewardItem(
                    systemIcon: "map.fill",
                    iconColor: Theme.flame,
                    title: L10n.isEnglish ? "Floors" : "关卡数",
                    value: "\(challenge.floorCount)"
                )
                rewardItem(
                    systemIcon: "suit.spade.fill",
                    iconColor: Theme.cyan,
                    title: L10n.isEnglish ? "Starter Joker" : "赠送规则牌",
                    value: "×1"
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
            if completed {
                SecondaryButton(
                    title: L10n.dailyChallengeCompleted,
                    icon: "checkmark.circle.fill",
                    color: Theme.textDisabled
                ) { }
                .disabled(true)
            } else if inProgress, let onResume {
                // UX-TODO: "Resume Challenge" / "继续挑战" should be added to L10n for proper 8-language support
                PrimaryButton(title: L10n.isEnglish ? "Resume Challenge" : "继续挑战", icon: "play.fill") {
                    onResume()
                }
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

    // UX-TODO: Move all modifier descriptions to L10n for full 8-language support
    // Currently only zh/en — ja/ko/fr/de/es/pt will show English fallback
    private func modifierDescription(_ modifier: DailyChallengeModifier) -> String {
        switch modifier {
        case .noBombs: return L10n.dailyChallengeNoBombs
        case .halfGold: return L10n.isEnglish ? "Start with half the normal gold" : "起始金币减半"
        case .extraPlays: return L10n.isEnglish ? "+2 extra plays per floor" : "每层额外 +2 次出牌"
        case .noDiscards: return L10n.dailyChallengeNoDiscards
        case .doubleScore: return L10n.isEnglish ? "All scores are doubled" : "所有得分翻倍"
        case .speedRun: return L10n.isEnglish ? "Max 3 plays per floor" : "每层最多 3 次出牌"
        case .bossRush: return L10n.isEnglish ? "Every non-shop floor has a boss" : "每层非商店关卡都有Boss"
        case .giantHand: return L10n.isEnglish ? "Hand size +5 cards" : "手牌数量 +5 张"
        case .tinyDeck: return L10n.isEnglish ? "Deck reduced to 36 cards" : "牌堆缩减至 36 张"
        case .allOrNothing: return L10n.isEnglish ? "Only bombs & rockets score" : "仅炸弹和火箭可得分"
        case .goldRush: return L10n.isEnglish ? "×3 gold, but shop prices ×2" : "金币×3，商店价格×2"
        case .mirrorMatch: return L10n.isEnglish ? "Boss modifiers on every floor" : "每层都有Boss修改器"
        }
    }
}

#Preview {
    DailyChallengeView(onStart: { _ in }, onResume: nil, onBack: { })
}
