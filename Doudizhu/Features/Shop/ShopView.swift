import SwiftUI

/// Roguelike 关卡间的构筑商店
struct ShopView: View {
    @ObservedObject var rogueRun: RogueRun
    let onLeave: () -> Void

    @State private var shopItems: [ShopItem] = []

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                // 标题
                VStack(spacing: 4) {
                    Text("🏪 杂货铺")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text("选购增益道具，助你一臂之力")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 40)

                // 金币
                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(rogueRun.gold)")
                        .font(.title3.bold().monospacedDigit())
                        .foregroundColor(.yellow)
                    Text("金币")
                        .foregroundColor(.yellow.opacity(0.6))
                }

                // 商品列表
                VStack(spacing: 12) {
                    ForEach(shopItems) { item in
                        ShopItemRow(
                            item: item,
                            canAfford: rogueRun.gold >= item.cost,
                            onBuy: {
                                if rogueRun.buyBuff(item.buff, cost: item.cost) {
                                    withAnimation {
                                        shopItems.removeAll { $0.id == item.id }
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)

                if shopItems.isEmpty {
                    Text("已售罄")
                        .foregroundColor(.white.opacity(0.3))
                        .padding()
                }

                // 已有 Buff
                if !rogueRun.activeBuffs.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("已装备")
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.4))
                        FlowLayout(spacing: 6) {
                            ForEach(rogueRun.activeBuffs) { buff in
                                Text("\(buff.icon) \(buff.name)")
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Capsule().fill(.orange.opacity(0.15)))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                // 离开按钮
                Button("继续前进 →") {
                    onLeave()
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(width: 200, height: 50)
                .background(RoundedRectangle(cornerRadius: 12).fill(.yellow))
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            generateShopItems()
        }
    }

    private func generateShopItems() {
        // 随机挑选 3 个 Buff 出售
        let available = Buff.allBuffs.shuffled()
        shopItems = available.prefix(3).enumerated().map { index, buff in
            ShopItem(buff: buff, cost: (index + 1) * 30 + Int.random(in: 0...20))
        }
    }
}

struct ShopItem: Identifiable {
    let id = UUID()
    let buff: Buff
    let cost: Int
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
                    .foregroundColor(.white)
                Text(item.buff.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            Button(action: onBuy) {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                    Text("\(item.cost)")
                        .font(.body.bold().monospacedDigit())
                }
                .foregroundColor(canAfford ? .black : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(canAfford ? .yellow : .gray.opacity(0.2))
                )
            }
            .disabled(!canAfford)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
                .stroke(.white.opacity(0.1))
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
