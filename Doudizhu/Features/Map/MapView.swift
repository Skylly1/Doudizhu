import SwiftUI

/// Roguelike 地图：冒险入口 — 纵向旅途可视化
struct MapView: View {
    let onStart: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                GameNavBar(title: L10n.adventurePath, subtitle: L10n.mapSubtitle, onBack: onBack)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(FloorConfig.allFloors.enumerated()), id: \.offset) { index, floor in
                            FloorNode(floor: floor, index: index, isLast: index == FloorConfig.allFloors.count - 1)
                        }
                    }
                    .padding(.top, Theme.spacingLG)
                    .padding(.bottom, 100)
                }

                // 出发按钮
                PrimaryButton(title: L10n.depart, icon: "figure.walk") {
                    onStart()
                }
                .padding(.horizontal, Theme.spacingXL)
                .padding(.bottom, Theme.spacingLG)
            }
        }
    }
}

private struct FloorNode: View {
    let floor: FloorConfig
    let index: Int
    let isLast: Bool

    var body: some View {
        HStack(spacing: Theme.spacingMD) {
            // 左侧连线 + 节点
            VStack(spacing: 0) {
                if index > 0 {
                    Rectangle()
                        .fill(Theme.border)
                        .frame(width: 2, height: 20)
                }

                ZStack {
                    Circle()
                        .fill(floor.isShop ? Theme.flame.opacity(0.2) : Theme.cyan.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Circle()
                        .stroke(floor.isShop ? Theme.flame : Theme.cyan, lineWidth: 2)
                        .frame(width: 44, height: 44)
                    Text(floor.isShop ? "🏪" : "\(floor.floor)")
                        .font(floor.isShop ? .title3 : .body.bold().monospacedDigit())
                        .foregroundColor(floor.isShop ? Theme.flame : Theme.cyan)
                }

                if !isLast {
                    Rectangle()
                        .fill(Theme.border)
                        .frame(width: 2, height: 20)
                }
            }

            // 右侧信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(floor.name)
                        .font(Theme.fontSection)
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    if !floor.isShop {
                        Text("🎯 \(floor.targetScore)")
                            .font(Theme.fontCaption.monospacedDigit())
                            .foregroundColor(Theme.gold)
                    }
                }

                Text(floor.description)
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textTertiary)

                if !floor.isShop {
                    HStack(spacing: Theme.spacingSM) {
                        Label(L10n.playsLabel(floor.maxPlays), systemImage: "hand.raised.fill")
                        Label(L10n.discardsLabel(floor.maxDiscards), systemImage: "arrow.triangle.2.circlepath")
                    }
                    .font(.caption2)
                    .foregroundColor(Theme.textTertiary)
                }
            }
            .padding(.vertical, Theme.spacingSM)
        }
        .padding(.horizontal, Theme.spacingLG)
    }
}

#Preview {
    MapView(onStart: {}, onBack: {})
}
