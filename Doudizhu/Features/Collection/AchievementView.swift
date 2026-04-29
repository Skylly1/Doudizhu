import SwiftUI

/// 成就展示页面
struct AchievementView: View {
    @StateObject private var tracker = AchievementTracker.shared

    var body: some View {
        ZStack {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // 进度概览
                let prog = tracker.progress
                VStack(spacing: Theme.spacingSM) {
                    Text("\(prog.unlocked) / \(prog.total)")
                        .font(.title.bold().monospacedDigit())
                        .foregroundColor(Theme.gold)
                    Text(L10n.achievementsUnlocked)
                        .font(Theme.fontCaption)
                        .foregroundColor(Theme.textTertiary)
                        .accessibilityAddTraits(.isHeader)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.bgCard)
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.goldGradient)
                                .frame(width: geo.size.width * (prog.total > 0 ? CGFloat(prog.unlocked) / CGFloat(prog.total) : 0), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, Theme.spacingLG)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(L10n.a11yAchievementProgress)
                .accessibilityValue("\(prog.unlocked)已解锁，共\(prog.total)个")

                if prog.unlocked == 0 {
                    // Empty state
                    VStack(spacing: Theme.spacingMD) {
                        Image(systemName: "trophy.fill")
                            .font(Theme.fontStatNumber)
                            .foregroundColor(Theme.textTertiary)
                        Text(L10n.emptyAchievements)
                            .font(Theme.fontBody)
                            .foregroundColor(Theme.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingLG)
                }

                // 按分类展示
                ForEach(Achievement.Category.allCases, id: \.self) { category in
                    let items = Achievement.all.filter { $0.category == category }
                    VStack(alignment: .leading, spacing: Theme.spacingSM) {
                        Text(category.displayName)
                            .font(Theme.fontSection)
                            .foregroundColor(Theme.gold)
                            .padding(.horizontal, Theme.spacingLG)

                        ForEach(items) { ach in
                            achievementRow(ach)
                        }
                    }
                }
            }
            .padding(.top, Theme.spacingMD)
            .padding(.bottom, Theme.spacingXL)
            .frame(maxWidth: 600)
        }
        .frame(maxWidth: .infinity)

        ContextualHintOverlay(manager: ContextualHintManager.shared)
        }
        .onAppear {
            ContextualHintManager.shared.onAchievementPageViewed()
        }
    }

    private func achievementRow(_ ach: Achievement) -> some View {
        let unlocked = tracker.isUnlocked(ach.id)
        let accentColor: Color = switch ach.category {
        case .progress: Theme.cyan
        case .scoring:  Theme.gold
        case .mastery:  Theme.flame
        case .style:    Theme.legendary
        }

        // 成就→规则牌解锁关联
        let jokerUnlockLabel: String? = {
            switch ach.id {
            case "mid_run":    return L10n.isEnglish ? "🔓 Unlocks Rare Jokers" : "🔓 解锁稀有规则牌"
            case "full_clear": return L10n.isEnglish ? "🔓 Unlocks Legendary Jokers" : "🔓 解锁传说规则牌"
            default:           return nil
            }
        }()

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(unlocked ? accentColor.opacity(0.15) : Theme.bgInset)
                    .frame(width: 42, height: 42)
                Image(systemName: ach.icon)
                    .font(Theme.fontSection)
                    .foregroundColor(unlocked ? accentColor : Theme.textDisabled)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(ach.name)
                    .font(.subheadline.bold())
                    .foregroundColor(unlocked ? Theme.textPrimary : Theme.textDisabled)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(ach.description)
                    .font(Theme.fontCaption)
                    .foregroundColor(unlocked ? Theme.textSecondary : Theme.textDisabled)
                    .lineLimit(3)
                if let label = jokerUnlockLabel {
                    Text(label)
                        .font(.caption2.bold())
                        .foregroundColor(unlocked ? Theme.success : Theme.cyan)
                        .padding(.top, 1)
                }
            }

            Spacer()

            if unlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(Theme.gold)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(Theme.textDisabled)
                    .font(.caption)
            }
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusSM)
                .fill(unlocked ? Theme.bgCard : Theme.bgInset)
                .stroke(unlocked ? accentColor.opacity(0.2) : Theme.borderLight)
        )
        .shadow(color: unlocked ? accentColor.opacity(0.1) : .clear, radius: 4, y: 2)
        .padding(.horizontal, Theme.spacingMD)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(ach.name)")
        .accessibilityValue(unlocked ? "已解锁，\(ach.description)" : "未解锁")
    }
}
