import SwiftUI

/// 成就展示页面
struct AchievementView: View {
    @StateObject private var tracker = AchievementTracker.shared

    var body: some View {
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

                if prog.unlocked == 0 {
                    // Empty state
                    VStack(spacing: Theme.spacingMD) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 44))
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
                        Text(category.rawValue)
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
        }
        .gameBackground()
    }

    private func achievementRow(_ ach: Achievement) -> some View {
        let unlocked = tracker.isUnlocked(ach.id)
        return HStack(spacing: 12) {
            Text(ach.icon)
                .font(.title2)
                .opacity(unlocked ? 1.0 : 0.3)

            VStack(alignment: .leading, spacing: 2) {
                Text(ach.name)
                    .font(.subheadline.bold())
                    .foregroundColor(unlocked ? Theme.textPrimary : Theme.textDisabled)
                Text(ach.description)
                    .font(Theme.fontCaption)
                    .foregroundColor(unlocked ? Theme.textSecondary : Theme.textDisabled)
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
                .stroke(unlocked ? Theme.gold.opacity(0.15) : Theme.borderLight)
        )
        .padding(.horizontal, Theme.spacingMD)
    }
}
