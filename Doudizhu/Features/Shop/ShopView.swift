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

                if shopItems.isEmpty && jokerItems.isEmpty {
                    Text(L10n.soldOut)
                        .foregroundColor(Theme.textDisabled)
                        .padding(Theme.spacingXL)
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
        let availableJokers = Joker.allJokers.filter { !ownedEffects.contains($0.effect) }.shuffled()
        jokerItems = availableJokers.prefix(2).map { joker in
            let baseCost: Int
            switch joker.rarity {
            case .common:    baseCost = 40
            case .rare:      baseCost = 70
            case .legendary: baseCost = 120
            }
            return JokerShopItem(joker: joker, cost: baseCost + Int.random(in: 0...20))
        }

        let available = Buff.allBuffs.shuffled()
        shopItems = available.prefix(2).enumerated().map { index, buff in
            ShopItem(buff: buff, cost: (index + 1) * 30 + Int.random(in: 0...20))
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
                    Text(item.joker.rarity.rawValue)
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

#Preview {
    ShopView(rogueRun: RogueRun(), onLeave: {})
}
