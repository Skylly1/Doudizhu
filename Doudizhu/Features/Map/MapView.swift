import SwiftUI

/// Roguelike 地图：冒险入口 — 纵向旅途可视化
struct MapView: View {
    let onStart: () -> Void
    let onBack: () -> Void

    @ObservedObject private var stats = PlayerStats.shared
    @State private var appeared = false

    private var highestFloor: Int { stats.highestFloor }

    var body: some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                GameNavBar(title: L10n.adventurePath, subtitle: L10n.mapSubtitle, onBack: onBack)

                // Stats summary
                MapStatsSummary(
                    highestFloor: highestFloor,
                    totalRuns: stats.totalRuns,
                    highestScore: stats.highestSingleScore
                )
                .padding(.horizontal, Theme.spacingLG)
                .padding(.top, Theme.spacingSM)

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(FloorConfig.allFloors.enumerated()), id: \.offset) { index, floor in
                                FloorNode(
                                    floor: floor,
                                    index: index,
                                    isLast: index == FloorConfig.allFloors.count - 1,
                                    highestFloor: highestFloor,
                                    hasPlayed: stats.totalRuns > 0
                                )
                                .id(index)
                                .opacity(appeared ? 1 : 0)
                                .animation(
                                    .easeOut(duration: 0.35).delay(Double(index) * 0.05),
                                    value: appeared
                                )
                            }
                        }
                        .padding(.top, Theme.spacingLG)
                        .padding(.bottom, 100)
                    }
                    .onAppear {
                        appeared = true
                        if highestFloor > 5 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    proxy.scrollTo(highestFloor, anchor: .center)
                                }
                            }
                        }
                    }
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

// MARK: - Stats Summary Bar

private struct MapStatsSummary: View {
    let highestFloor: Int
    let totalRuns: Int
    let highestScore: Int

    var body: some View {
        HStack(spacing: 0) {
            statItem(icon: "🏆", value: L10n.mapHighestFloor(max(1, highestFloor)))
            Rectangle().fill(Theme.border).frame(width: 1, height: 20)
            statItem(icon: "⚡", value: L10n.mapTotalRuns(totalRuns))
            Rectangle().fill(Theme.border).frame(width: 1, height: 20)
            statItem(icon: "🎯", value: L10n.mapHighestScore(highestScore))
        }
        .padding(.vertical, Theme.spacingSM)
        .background(Theme.bgCard)
        .cornerRadius(Theme.radiusMD)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private func statItem(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(icon)
            Text(value)
                .font(Theme.fontCaption.monospacedDigit())
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Floor Node

private enum FloorNodeState {
    case cleared, frontier, locked
}

private struct FloorNode: View {
    let floor: FloorConfig
    let index: Int
    let isLast: Bool
    let highestFloor: Int
    let hasPlayed: Bool

    @State private var pulseScale: CGFloat = 1.0

    private var state: FloorNodeState {
        if hasPlayed && index < highestFloor { return .cleared }
        if hasPlayed && index == highestFloor { return .frontier }
        return .locked
    }

    private var nodeSize: CGFloat { state == .frontier ? 52 : 44 }

    private var topLineColor: Color {
        (hasPlayed && index > 0 && index <= highestFloor) ? Theme.success : Theme.border
    }

    private var bottomLineColor: Color {
        (hasPlayed && !isLast && index < highestFloor) ? Theme.success : Theme.border
    }

    private var nodeAccent: Color {
        switch state {
        case .cleared:  return Theme.success
        case .frontier: return Theme.gold
        case .locked:
            if floor.isShop { return Theme.flame }
            if floor.isBoss { return Theme.flame }
            return Theme.cyan
        }
    }

    var body: some View {
        HStack(spacing: Theme.spacingMD) {
            // 左侧连线 + 节点
            VStack(spacing: 0) {
                if index > 0 {
                    Rectangle()
                        .fill(topLineColor)
                        .frame(width: 2, height: 20)
                }

                ZStack {
                    Circle()
                        .fill(nodeAccent.opacity(0.15))
                        .frame(width: nodeSize, height: nodeSize)
                    Circle()
                        .stroke(nodeAccent, lineWidth: state == .frontier ? 3 : 2)
                        .frame(width: nodeSize, height: nodeSize)

                    // Node content
                    if state == .cleared {
                        // Green checkmark overlay
                        Circle()
                            .fill(Theme.success.opacity(0.85))
                            .frame(width: nodeSize, height: nodeSize)
                        Image(systemName: "checkmark")
                            .font(.body.bold())
                            .foregroundColor(.white)
                    } else if floor.isShop {
                        Text("🏪").font(.title3)
                    } else if floor.isBoss {
                        Text("💀").font(.title3)
                    } else {
                        Text("\(floor.floor)")
                            .font(.body.bold().monospacedDigit())
                            .foregroundColor(nodeAccent)
                    }
                }
                .scaleEffect(state == .frontier ? pulseScale : 1.0)
                .onAppear {
                    guard state == .frontier else { return }
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        pulseScale = 1.08
                    }
                }

                if !isLast {
                    Rectangle()
                        .fill(bottomLineColor)
                        .frame(width: 2, height: 20)
                }
            }

            // 右侧信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(floor.name)
                        .font(Theme.subtitleFont)
                        .foregroundColor(state == .cleared ? Theme.textTertiary : Theme.textPrimary)

                    if state == .frontier {
                        Text(L10n.mapHighestProgress)
                            .font(.caption2.bold())
                            .foregroundColor(Theme.gold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.gold.opacity(0.15))
                            .cornerRadius(4)
                    }

                    if floor.isBoss && !floor.isShop {
                        Text("🔥").font(.caption)
                    }

                    Spacer()

                    if !floor.isShop {
                        Text("🎯 \(floor.targetScore)")
                            .font(Theme.fontCaption.monospacedDigit())
                            .foregroundColor(state == .cleared ? Theme.textTertiary : Theme.gold)
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
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .fill(Theme.gold.opacity(state == .frontier ? 0.05 : 0))
                .padding(.horizontal, Theme.spacingSM)
        )
    }
}

#Preview {
    MapView(onStart: {}, onBack: {})
}
