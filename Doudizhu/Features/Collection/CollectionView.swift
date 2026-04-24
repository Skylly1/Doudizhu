import SwiftUI

/// 卡牌图鉴 — 查看所有规则牌、增益、牌型
struct CollectionView: View {
    let onBack: () -> Void
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                GameNavBar(title: "图鉴", onBack: onBack)

                // Tab 切换
                HStack(spacing: 0) {
                    tabButton("规则牌", icon: "🃏", index: 0)
                    tabButton("增益", icon: "✨", index: 1)
                    tabButton("牌型", icon: "📖", index: 2)
                    tabButton("成就", icon: "🏆", index: 3)
                }
                .padding(.horizontal, Theme.spacingMD)
                .padding(.top, Theme.spacingSM)

                TabView(selection: $selectedTab) {
                    jokerCollection.tag(0)
                    buffCollection.tag(1)
                    patternCollection.tag(2)
                    AchievementView().tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }

    private func tabButton(_ title: String, icon: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
        } label: {
            VStack(spacing: 4) {
                Text("\(icon) \(title)")
                    .font(.subheadline.weight(selectedTab == index ? .bold : .medium))
                    .foregroundColor(selectedTab == index ? Theme.gold : Theme.textTertiary)
                Rectangle()
                    .fill(selectedTab == index ? Theme.gold : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - 规则牌收藏

    private var jokerCollection: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                Text("共 \(Joker.allJokers.count) 张规则牌")
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textTertiary)
                    .padding(.top, Theme.spacingSM)

                ForEach(Joker.allJokers) { joker in
                    jokerCard(joker)
                }
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.bottom, Theme.spacingXL)
        }
    }

    private func jokerCard(_ joker: Joker) -> some View {
        let rarityColor: Color = switch joker.rarity {
        case .common: Theme.success
        case .rare: Theme.cyan
        case .legendary: Theme.legendary
        }

        return HStack(spacing: 12) {
            Text(joker.icon)
                .font(.title)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(joker.name)
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.textPrimary)
                    Text(joker.rarity.rawValue)
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(rarityColor.opacity(0.2)))
                        .foregroundColor(rarityColor)
                }
                Text(joker.description)
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusSM)
                .fill(Theme.bgCard)
                .stroke(rarityColor.opacity(0.2))
        )
    }

    // MARK: - 增益收藏

    private var buffCollection: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                Text("共 \(Buff.allBuffs.count) 种增益道具")
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textTertiary)
                    .padding(.top, Theme.spacingSM)

                ForEach(Buff.allBuffs) { buff in
                    HStack(spacing: 12) {
                        Text(buff.icon)
                            .font(.title)
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
