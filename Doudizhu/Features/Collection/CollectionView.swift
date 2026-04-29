import SwiftUI

/// 卡牌图鉴 — 查看所有规则牌、增益、牌型
struct CollectionView: View {
    let onBack: () -> Void
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                GameNavBar(title: L10n.collection, onBack: onBack)

                // Tab 切换
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        tabButton(L10n.jokerSection, systemIcon: "suit.spade.fill", index: 0)
                        tabButton(L10n.buffSection, systemIcon: "sparkles", index: 1)
                        tabButton(L10n.patternTab, systemIcon: "book.fill", index: 2)
                        tabButton(L10n.achievements, systemIcon: "trophy.fill", index: 3)
                        tabButton(L10n.statsTab, systemIcon: "chart.bar.fill", index: 4)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, Theme.spacingMD)
                .padding(.top, Theme.spacingSM)
                .accessibilityElement(children: .contain)
                .accessibilityLabel(L10n.isEnglish ? "Collection tabs" : "收藏标签页")

                TabView(selection: $selectedTab) {
                    jokerCollection.tag(0)
                    buffCollection.tag(1)
                    patternCollection.tag(2)
                    AchievementView().tag(3)
                    StatsView().tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
        .gameBackground()
    }

    private func tabButton(_ title: String, systemIcon: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: systemIcon)
                        .font(.caption)
                    if !Theme.isCompactScreen {
                        Text(title)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                .font(.subheadline.weight(selectedTab == index ? .bold : .medium))
                .foregroundColor(selectedTab == index ? Theme.gold : Theme.textTertiary)
                Rectangle()
                    .fill(selectedTab == index ? Theme.gold : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
        }
        .accessibilityLabel(title)
        .accessibilityHint(L10n.isEnglish ? "Switch to \(title) tab" : "切换到\(title)标签页")
        .accessibilityValue(selectedTab == index ? (L10n.isEnglish ? "Selected" : "已选中") : "")
    }

    // MARK: - 规则牌收藏

    private var jokerCollection: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                // 新手说明
                Text(L10n.isEnglish
                     ? "Jokers are permanent abilities that change game rules"
                     : "规则牌 — 永久改变游戏规则的特殊能力卡")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.top, Theme.spacingSM)

                Text(L10n.jokerCount(Joker.allJokers.count))
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textTertiary)

                ForEach(Joker.allJokers) { joker in
                    jokerCard(joker)
                }
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.bottom, Theme.spacingXL)
        }
    }

    private func jokerCard(_ joker: Joker) -> some View {
        let isLocked = !JokerUnlockManager.isUnlocked(joker)
        let rarityColor: Color = switch joker.rarity {
        case .common: Theme.success
        case .rare: Theme.cyan
        case .legendary: Theme.legendary
        }

        return HStack(spacing: 12) {
            if isLocked {
                ZStack {
                    Circle()
                        .fill(Theme.bgInset)
                        .frame(width: 44, height: 44)
                    Image(systemName: "lock.fill")
                        .font(.body)
                        .foregroundColor(Theme.textDisabled)
                }
            } else {
                Image(systemName: joker.effect.systemIcon)
                    .font(.title)
                    .foregroundColor(rarityColor)
                    .frame(width: 44)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(joker.name)
                        .font(.subheadline.bold())
                        .foregroundColor(isLocked ? Theme.textTertiary : Theme.textPrimary)
                    Text(joker.rarity.displayName)
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(rarityColor.opacity(isLocked ? 0.1 : 0.2)))
                        .foregroundColor(isLocked ? rarityColor.opacity(0.4) : rarityColor)
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(Theme.textDisabled)
                    }
                }
                Text(isLocked ? (L10n.isEnglish ? "Unlock via achievements" : "通过成就解锁") : joker.description)
                    .font(Theme.fontCaption)
                    .foregroundColor(isLocked ? Theme.textTertiary : Theme.textSecondary)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusSM)
                .fill(isLocked ? Theme.bgCard.opacity(0.5) : Theme.bgCard)
                .stroke(rarityColor.opacity(isLocked ? 0.08 : 0.2))
        )
        .opacity(isLocked ? 0.6 : 1.0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isLocked ? "\(joker.name)，已锁定" : "\(joker.name)，\(joker.rarity.displayName)")
        .accessibilityValue(isLocked ? "通过成就解锁" : joker.description)
    }

    // MARK: - 增益收藏

    private var buffCollection: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                Text(L10n.isEnglish
                     ? "Buffs are temporary boosts that last for the current run"
                     : "增益 — 本局冒险中的临时强化效果")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.top, Theme.spacingSM)

                Text(L10n.buffCount(Buff.allBuffs.count))
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textTertiary)

                ForEach(Buff.allBuffs) { buff in
                    HStack(spacing: 12) {
                        Image(systemName: buff.type.systemIcon)
                            .font(.title)
                            .foregroundColor(Theme.flame)
                            .frame(width: 44)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(buff.name)
                                .font(.subheadline.bold())
                                .foregroundColor(Theme.textPrimary)
                            Text(buff.description)
                                .font(Theme.fontCaption)
                                .foregroundColor(Theme.textSecondary)
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusSM)
                            .fill(Theme.bgCard)
                            .stroke(Theme.flame.opacity(0.15))
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(buff.name)")
                    .accessibilityValue(buff.description)
                }
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.bottom, Theme.spacingXL)
        }
    }

    // MARK: - 牌型指南 (复用 PatternGuideView 的内容)

    private var patternCollection: some View {
        PatternGuideView()
    }
}

#Preview {
    CollectionView(onBack: {})
}
