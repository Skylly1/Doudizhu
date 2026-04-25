import SwiftUI

/// Roguelike 关卡间的构筑商店
struct ShopView: View {
    @ObservedObject var rogueRun: RogueRun
    let onLeave: () -> Void

    @State private var shopItems: [ShopItem] = []
    @State private var jokerItems: [JokerShopItem] = []

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // 标题
                GameNavBar(title: L10n.shop, subtitle: L10n.shopSubtitle)
                    .padding(.top, Theme.spacingSM)

                // 金币
                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(Theme.gold)
                    Text("\(rogueRun.gold)")
                        .font(.title3.bold().monospacedDigit())
                        .foregroundColor(Theme.gold)
                    Text(L10n.gold)
                        .font(Theme.fontCaption)
                        .foregroundColor(Theme.goldDark.opacity(0.7))
                }

                // 刷新按钮（刷新费用随关卡递增：基础10，每层+2，上限25）
                let refreshCost = min(25, 10 + rogueRun.currentFloorIndex * 2)
                Button {
                    if rogueRun.gold >= refreshCost {
                        rogueRun.gold -= refreshCost
                        FeedbackManager.shared.purchase()
                        SoundManager.shared.play(.shopBuy)
                        withAnimation(.spring(response: 0.3)) {
                            generateShopItems()
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                        Text(L10n.refreshShopCost(refreshCost))
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(rogueRun.gold >= refreshCost ? Theme.cyan : Theme.textDisabled)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(rogueRun.gold >= refreshCost ? Theme.cyanDim : Theme.bgInset)
                            .stroke(rogueRun.gold >= refreshCost ? Theme.cyan.opacity(0.3) : Theme.borderLight)
                    )
                }
                .disabled(rogueRun.gold < refreshCost)

                // 规则牌区
                if !jokerItems.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.spacingSM) {
                        HStack {
                            Label(L10n.jokerSection, systemImage: "suit.spade.fill")
                                .font(Theme.fontSection)
                                .foregroundColor(Theme.cyan)
                            Spacer()
                            Text("\(rogueRun.activeJokers.count)/\(Joker.maxSlots)")
                                .font(Theme.fontMono)
                                .foregroundColor(Theme.textTertiary)
                        }
                        .padding(.horizontal, Theme.spacingLG)

                        VStack(spacing: 10) {
                            ForEach(jokerItems) { item in
                                JokerShopRow(
                                    item: item,
                                    canAfford: rogueRun.gold >= item.cost,
                                    slotsFull: rogueRun.activeJokers.count >= Joker.maxSlots,
                                    onBuy: {
                                        if rogueRun.buyJoker(item.joker, cost: item.cost) {
                                            FeedbackManager.shared.purchase()
                                            SoundManager.shared.play(.shopBuy)
                                            withAnimation(.spring(response: 0.3)) {
                                                jokerItems.removeAll { $0.id == item.id }
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, Theme.spacingLG)
                    }
                }

                // 增益道具区
                if !shopItems.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.spacingSM) {
                        Label(L10n.buffSection, systemImage: "sparkles")
                            .font(Theme.fontSection)
                            .foregroundColor(Theme.flame)
                            .padding(.horizontal, Theme.spacingLG)

                        VStack(spacing: 10) {
                            ForEach(shopItems) { item in
                                ShopItemRow(
                                    item: item,
                                    canAfford: rogueRun.gold >= item.cost,
                                    onBuy: {
                                        if rogueRun.buyBuff(item.buff, cost: item.cost) {
                                            FeedbackManager.shared.purchase()
                                            SoundManager.shared.play(.shopBuy)
                                            withAnimation(.spring(response: 0.3)) {
                                                shopItems.removeAll { $0.id == item.id }
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, Theme.spacingLG)
                    }
                }

                // 武功秘籍区
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Label(L10n.isEnglish ? "Martial Arts Manuals" : "武功秘籍", systemImage: "book.closed.fill")
                        .font(Theme.fontSection)
                        .foregroundColor(Theme.gold)
                        .padding(.horizontal, Theme.spacingLG)

                    VStack(spacing: 6) {
                        ForEach(PatternType.allCases, id: \.self) { type in
                            PatternUpgradeRow(
                                type: type,
                                gold: rogueRun.gold,
                                onBuy: { cost in
                                    rogueRun.gold -= cost
                                    PatternUpgradeManager.shared.upgrade(type)
                                    FeedbackManager.shared.purchase()
                                    SoundManager.shared.play(.shopBuy)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Theme.spacingLG)
                }

                if shopItems.isEmpty && jokerItems.isEmpty {
                    VStack(spacing: Theme.spacingMD) {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 42))
                            .foregroundStyle(Theme.gold.opacity(0.4))
                        Text(L10n.shopRestocking)
                            .font(Theme.fontBody)
                            .foregroundColor(Theme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingXL)
                }

                // 已装备的规则牌
                if !rogueRun.activeJokers.isEmpty {
                    equippedSection(
                        title: L10n.equippedJokers,
                        color: Theme.cyan
                    ) {
                        FlowLayout(spacing: 6) {
                            ForEach(rogueRun.activeJokers) { joker in
                                HStack(spacing: 3) {
                                    Text(joker.icon).font(.caption2)
                                    Text(joker.name).font(.caption2)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(Theme.cyanDim))
                                .foregroundColor(Theme.cyan)
                            }
                        }
                    }
                }

                // 已有 Buff
                if !rogueRun.activeBuffs.isEmpty {
                    equippedSection(
                        title: L10n.equippedBuffs,
                        color: Theme.flame
                    ) {
                        FlowLayout(spacing: 6) {
                            ForEach(rogueRun.activeBuffs) { buff in
                                HStack(spacing: 3) {
                                    Text(buff.icon).font(.caption2)
                                    Text(buff.name).font(.caption2)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(Theme.flameDim))
                                .foregroundColor(Theme.flame)
                            }
                        }
                    }
                }

                Spacer(minLength: Theme.spacingMD)

                PrimaryButton(title: L10n.continueForward, icon: "arrow.right") {
                    onLeave()
                }
                .padding(.horizontal, Theme.spacingXXL)
                .padding(.bottom, Theme.spacingXL)
            }
        }
        .gameBackground()
        .onAppear { generateShopItems() }
    }

    private func equippedSection<Content: View>(title: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text(title)
                .font(Theme.fontCaption)
                .foregroundColor(color.opacity(0.6))
            content()
        }
        .padding(.horizontal, Theme.spacingLG)
    }

    private func generateShopItems() {
        let ownedEffects = Set(rogueRun.activeJokers.map(\.effect))
        let availableJokers = JokerUnlockManager.availableJokers.filter { !ownedEffects.contains($0.effect) }.shuffled()
        jokerItems = availableJokers.prefix(3).map { joker in
            let baseCost: Int
            switch joker.rarity {
            case .common:    baseCost = 40
            case .rare:      baseCost = 70
            case .legendary: baseCost = 120
            }
            return JokerShopItem(joker: joker, cost: baseCost + Int.random(in: 0...20))
        }

        let available = Buff.allBuffs.shuffled()
        shopItems = available.prefix(3).enumerated().map { index, buff in
            ShopItem(buff: buff, cost: (index + 1) * 25 + Int.random(in: 0...15))
        }
    }
}

struct ShopItem: Identifiable {
    let id = UUID()
    let buff: Buff
    let cost: Int
}

struct JokerShopItem: Identifiable {
    let id = UUID()
    let joker: Joker
    let cost: Int
}

struct JokerShopRow: View {
    let item: JokerShopItem
    let canAfford: Bool
    let slotsFull: Bool
    let onBuy: () -> Void

    private var rarityColor: Color {
        switch item.joker.rarity {
        case .common:    return Theme.success
        case .rare:      return Theme.cyan
        case .legendary: return Theme.legendary
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(item.joker.icon)
                .font(.title)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(item.joker.name)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    Text(item.joker.rarity.displayName)
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(rarityColor.opacity(0.25)))
                        .foregroundColor(rarityColor)
                }
                Text(item.joker.description)
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            Button(action: onBuy) {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                    Text("\(item.cost)")
                        .font(Theme.fontMono)
                }
                .foregroundColor(canAfford && !slotsFull ? .black : Theme.textDisabled)
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(canAfford && !slotsFull ? Theme.cyan : Theme.bgInset)
                )
            }
            .disabled(!canAfford || slotsFull)
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(Theme.bgCard)
                .stroke(rarityColor.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: rarityColor.opacity(item.joker.rarity == .legendary ? 0.35 : 0.15),
                radius: item.joker.rarity == .legendary ? 12 : 6)
    }
}

struct ShopItemRow: View {
    let item: ShopItem
    let canAfford: Bool
    let onBuy: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(item.buff.icon)
                .font(.title)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.buff.name)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                Text(item.buff.description)
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            Button(action: onBuy) {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                    Text("\(item.cost)")
                        .font(Theme.fontMono)
                }
                .foregroundColor(canAfford ? .black : Theme.textDisabled)
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(canAfford ? Theme.gold : Theme.bgInset)
                )
            }
            .disabled(!canAfford)
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(Theme.bgCard)
                .stroke(Theme.border)
        )
    }
}

/// 简易 FlowLayout（横向排列自动换行）
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

// MARK: - Pattern Upgrade Row

struct PatternUpgradeRow: View {
    let type: PatternType
    let gold: Int
    let onBuy: (Int) -> Void

    @ObservedObject private var mgr = PatternUpgradeManager.shared

    var body: some View {
        let level = mgr.level(for: type)
        let canUpgrade = mgr.canUpgrade(type)
        let cost = mgr.upgradeCost(for: type)

        HStack {
            Text(type.displayName)
                .font(.caption.bold())
                .foregroundColor(Theme.textPrimary)
                .frame(width: 80, alignment: .leading)

            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < level ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundColor(i < level ? Theme.gold : Theme.textSecondary)
                }
            }

            if level > 0 {
                Text("+\(level * PatternUpgradeManager.chipPerLevel)🔵 +\(String(format: "%.1f", Double(level) * PatternUpgradeManager.multPerLevel))×")
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            if canUpgrade {
                Button {
                    if gold >= cost {
                        onBuy(cost)
                    }
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption2)
                        Text("\(cost)")
                    }
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(gold >= cost ? Theme.gold : Theme.textSecondary.opacity(0.3))
                        )
                        .foregroundColor(Theme.bgPrimary)
                }
                .disabled(gold < cost)
            } else {
                Text("MAX")
                    .font(.caption2.bold())
                    .foregroundColor(Theme.gold)
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusSM)
                .fill(Theme.bgCard)
        )
    }
}

#Preview {
    ShopView(rogueRun: RogueRun(), onLeave: {})
}
