import SwiftUI

/// Roguelike 关卡间的构筑商店
struct ShopView: View {
    @ObservedObject var rogueRun: RogueRun
    let onLeave: () -> Void
    var onQuit: (() -> Void)? = nil

    @State private var shopItems: [ShopItem] = []
    @State private var jokerItems: [JokerShopItem] = []
    @AppStorage("hasSeenShopIntro") private var hasSeenShopIntro = false
    @State private var showShopIntro = false
    @AppStorage("hasSeenFirstJokerGuide") private var hasSeenFirstJokerGuide = false
    @State private var showFirstJokerGuide = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 标题 + 返回（固定顶部，不随滚动）
                GameNavBar(
                    title: L10n.shop,
                    onBack: onQuit,
                    trailing: AnyView(
                        HStack(spacing: 6) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(Theme.gold)
                            Text("\(rogueRun.gold)")
                                .font(.title3.bold().monospacedDigit())
                                .foregroundColor(Theme.gold)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("金币")
                        .accessibilityValue("\(rogueRun.gold)")
                    )
                )

            ScrollView {
                VStack(spacing: Theme.spacingLG) {

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
                .accessibilityLabel("刷新商店")
                .accessibilityHint("花费\(refreshCost)金币刷新商品")

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
                                            SoundManager.shared.play(.goldCoin)
                                            withAnimation(.spring(response: 0.3)) {
                                                jokerItems.removeAll { $0.id == item.id }
                                            }
                                            // 首次购买规则牌引导
                                            if !hasSeenFirstJokerGuide {
                                                Analytics.shared.track(.firstJokerPurchase, joker: item.joker.name)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    withAnimation(.spring(response: 0.4)) { showFirstJokerGuide = true }
                                                }
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, Theme.spacingLG)
                    }
                }

                // 锁定的高级规则牌预览（仅试玩用户可见）
                if !PurchaseManager.shared.isFullVersion {
                    lockedJokerTeaser
                        .padding(.horizontal, Theme.spacingLG)
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
                                            SoundManager.shared.play(.goldCoin)
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
                    VStack(alignment: .leading, spacing: 2) {
                        Label(L10n.isEnglish ? "Martial Arts Manuals" : "武功秘籍", systemImage: "book.closed.fill")
                            .font(Theme.fontSection)
                            .foregroundColor(Theme.gold)
                        Text(L10n.isEnglish
                             ? "Upgrade pattern base scores for higher combos"
                             : "升级牌型基础分，提高得分上限")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(.horizontal, Theme.spacingLG)
                    .onAppear {
                        ContextualHintManager.shared.onUpgradeSectionViewed()
                    }

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
                                    Image(systemName: joker.effect.systemIcon).font(.caption2)
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
                                    Image(systemName: buff.type.systemIcon).font(.caption2)
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
            } // end ScrollView
            } // end outer VStack

        // 首次商店引导弹窗
        if showShopIntro {
            shopIntroOverlay
        }

        // 首次规则牌购买引导
        if showFirstJokerGuide {
            firstJokerGuideOverlay
        }

        // 上下文智能提示
        ContextualHintOverlay(manager: ContextualHintManager.shared)
        }
        .gameBackground()
        .onAppear {
            generateShopItems()
            if !hasSeenShopIntro {
                Analytics.shared.track(.shopFirstVisit)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.4)) { showShopIntro = true }
                }
            }
        }
    }

    // MARK: - 锁定规则牌预览

    private var lockedJokerTeaser: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.bgInset)
                        .frame(width: 44, height: 44)
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundColor(Theme.gold.opacity(0.5))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.isEnglish ? "Premium Jokers" : "高级规则牌")
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.gold)
                    Text(L10n.isEnglish ? "Unlock 60 unique Jokers & 3 more shops" : "完整版解锁 60 张规则牌 + 3 个商店")
                        .font(.caption)
                        .foregroundColor(Theme.textTertiary)
                }

                Spacer()

                Text(L10n.isEnglish ? "37%OFF" : "省37%")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Theme.flame))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(Theme.bgCard.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .stroke(Theme.gold.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [6, 3]))
                )
        )
    }

    // MARK: - 首次商店引导

    private var shopIntroOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture {
                    dismissShopIntro()
                }

            VStack(spacing: Theme.spacingLG) {
                Text(L10n.shopIntroTitle)
                    .font(.title2.bold())
                    .foregroundStyle(Theme.goldGradient)

                Text(L10n.shopIntroMsg)
                    .font(Theme.fontBody)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                // 三个图标卡片
                HStack(spacing: Theme.spacingMD) {
                    introIconCard(icon: "suit.spade.fill", label: L10n.jokerSection, color: Theme.cyan)
                    introIconCard(icon: "sparkles", label: L10n.buffSection, color: Theme.flame)
                    introIconCard(icon: "book.closed.fill", label: L10n.isEnglish ? "Manuals" : "秘籍", color: Theme.gold)
                }

                Button {
                    dismissShopIntro()
                } label: {
                    Text(L10n.shopIntroGotIt)
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, Theme.spacingXL)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Theme.gold))
                }
                .accessibilityLabel("我知道了")
                .accessibilityHint("关闭商店介绍")
            }
            .padding(Theme.spacingXL)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusLG)
                    .fill(Theme.bgPrimary.opacity(0.95))
                    .stroke(Theme.gold.opacity(0.3))
            )
            .shadow(color: .black.opacity(0.35), radius: 20, y: 8)
            .padding(Theme.spacingLG)
        }
        .transition(.opacity)
    }

    private func introIconCard(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(label)
                .font(.caption.bold())
                .foregroundColor(Theme.textSecondary)
        }
        .frame(width: 80, height: 70)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusSM)
                .fill(color.opacity(0.08))
                .stroke(color.opacity(0.2))
        )
    }

    private func dismissShopIntro() {
        withAnimation(.spring(response: 0.3)) { showShopIntro = false }
        hasSeenShopIntro = true
    }

    // MARK: - 首次规则牌购买引导

    private var firstJokerGuideOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture {
                    dismissFirstJokerGuide()
                }

            VStack(spacing: Theme.spacingLG) {
                Text(L10n.firstJokerTitle)
                    .font(.title2.bold())
                    .foregroundStyle(Theme.goldGradient)

                Text(L10n.firstJokerMsg)
                    .font(Theme.fontBody)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    dismissFirstJokerGuide()
                } label: {
                    Text(L10n.shopIntroGotIt)
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, Theme.spacingXL)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Theme.gold))
                }
                .accessibilityLabel("我知道了")
                .accessibilityHint("关闭规则牌介绍")
            }
            .padding(Theme.spacingXL)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusLG)
                    .fill(Theme.bgPrimary.opacity(0.95))
                    .stroke(Theme.cyan.opacity(0.3))
            )
            .shadow(color: Theme.cyan.opacity(0.2), radius: 16, y: 4)
            .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
            .padding(Theme.spacingLG)
        }
        .transition(.scale(scale: 0.85).combined(with: .opacity))
    }

    private func dismissFirstJokerGuide() {
        withAnimation(.spring(response: 0.3)) { showFirstJokerGuide = false }
        hasSeenFirstJokerGuide = true
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
        let priceMultiplier = rogueRun.dailyChallenge?.modifiers.contains(.goldRush) == true ? 2 : 1

        let ownedEffects = Set(rogueRun.activeJokers.map(\.effect))
        let availableJokers = JokerUnlockManager.availableJokers.filter { !ownedEffects.contains($0.effect) }.shuffled()
        jokerItems = availableJokers.prefix(3).map { joker in
            let baseCost: Int
            switch joker.rarity {
            case .common:    baseCost = 40
            case .rare:      baseCost = 70
            case .legendary: baseCost = 120
            }
            return JokerShopItem(joker: joker, cost: (baseCost + Int.random(in: 0...20)) * priceMultiplier)
        }

        let available = Buff.allBuffs.shuffled()
        shopItems = available.prefix(3).enumerated().map { index, buff in
            ShopItem(buff: buff, cost: ((index + 1) * 25 + Int.random(in: 0...15)) * priceMultiplier)
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
            Image(systemName: item.joker.effect.systemIcon)
                .font(.title)
                .foregroundColor(rarityColor)

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
            .accessibilityLabel("购买\(item.joker.name)")
            .accessibilityHint("花费\(item.cost)金币购买此规则牌")
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .stroke(rarityColor.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: rarityColor.opacity(item.joker.rarity == .legendary ? 0.35 : 0.15),
                radius: item.joker.rarity == .legendary ? 12 : 6)
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(item.joker.name)，\(item.joker.rarity.displayName)，\(item.joker.description)")
    }
}

struct ShopItemRow: View {
    let item: ShopItem
    let canAfford: Bool
    let onBuy: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.buff.type.systemIcon)
                .font(.title)
                .foregroundColor(Theme.flame)

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
            .accessibilityLabel("购买\(item.buff.name)")
            .accessibilityHint("花费\(item.cost)金币购买此增益")
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .stroke(Theme.border)
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(item.buff.name)，\(item.buff.description)")
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
                Text(L10n.isEnglish
                     ? "Chips+\(level * PatternUpgradeManager.chipPerLevel)  Mult+\(String(format: "%.1f", Double(level) * PatternUpgradeManager.multPerLevel))"
                     : "筹码+\(level * PatternUpgradeManager.chipPerLevel)  倍率+\(String(format: "%.1f", Double(level) * PatternUpgradeManager.multPerLevel))")
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
                        Image(systemName: "circle.circle.fill")
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
                .fill(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
    }
}

#Preview {
    ShopView(rogueRun: RogueRun(), onLeave: {}, onQuit: {})
}
