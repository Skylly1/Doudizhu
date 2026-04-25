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
                GameNavBar(title: L10n.adventurePath, onBack: onBack)

                // Stats summary
                MapStatsSummary(
                    highestFloor: highestFloor,
                    totalRuns: stats.totalRuns,
                    highestScore: stats.highestSingleScore
                )
                .padding(.horizontal, Theme.spacingLG)
                .padding(.top, Theme.spacingSM)

                // 章节概览卡片
                chapterOverview
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

    // MARK: - 章节概览

    private var chapterOverview: some View {
        let chapters: [(name: String, icon: String, range: String, color: Color)] = [
            (L10n.isEnglish ? "Village" : "乡野篇", "leaf.fill", "1-4", Theme.success),
            (L10n.isEnglish ? "City" : "府城篇", "building.2.fill", "5-8", Theme.cyan),
            (L10n.isEnglish ? "Jianghu" : "江湖篇", "mountain.2.fill", "9-15", Theme.flame),
        ]
        return HStack(spacing: Theme.spacingSM) {
            ForEach(Array(chapters.enumerated()), id: \.offset) { _, ch in
                let chapterCleared: Bool = {
                    guard let last = ch.range.split(separator: "-").last,
                          let end = Int(last) else { return false }
                    return highestFloor >= end
                }()
                HStack(spacing: 6) {
                    Image(systemName: ch.icon)
                        .font(.caption)
                        .foregroundColor(chapterCleared ? ch.color : Theme.textTertiary)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(ch.name)
                            .font(.caption.bold())
                            .foregroundColor(chapterCleared ? ch.color : Theme.textSecondary)
                        Text(ch.range)
                            .font(.system(size: 10).monospacedDigit())
                            .foregroundColor(Theme.textTertiary)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, Theme.spacingSM)
        .background(.ultraThinMaterial)
        .cornerRadius(Theme.radiusMD)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .stroke(Theme.gold.opacity(0.12), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
    }
}

// MARK: - Stats Summary Bar

private struct MapStatsSummary: View {
    let highestFloor: Int
    let totalRuns: Int
    let highestScore: Int

    var body: some View {
        HStack(spacing: 0) {
            statItem(systemIcon: "trophy.fill", iconColor: Theme.gold, value: L10n.mapHighestFloor(max(1, highestFloor)))
            Rectangle().fill(Theme.border).frame(width: 1, height: 20)
            statItem(systemIcon: "bolt.fill", iconColor: Theme.flame, value: L10n.mapTotalRuns(totalRuns))
            Rectangle().fill(Theme.border).frame(width: 1, height: 20)
            statItem(systemIcon: "target", iconColor: Theme.cyan, value: L10n.mapHighestScore(highestScore))
        }
        .padding(.vertical, Theme.spacingSM)
        .background(.ultraThinMaterial)
        .cornerRadius(Theme.radiusMD)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .stroke(Theme.gold.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }

    private func statItem(systemIcon: String, iconColor: Color, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemIcon)
                .font(.caption)
                .foregroundColor(iconColor)
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
    @State private var flowOffset: CGFloat = 0

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
                    ZStack {
                        Rectangle()
                            .fill(topLineColor)
                            .frame(width: 2, height: 20)
                        if state == .cleared || state == .frontier {
                            Rectangle()
                                .fill(Theme.success.opacity(0.4))
                                .frame(width: 4, height: 20)
                                .blur(radius: 2)
                        }
                    }
                }

                ZStack {
                    // 外层辉光（仅 frontier）
                    if state == .frontier {
                        Circle()
                            .fill(Theme.gold.opacity(0.08))
                            .frame(width: nodeSize + 16, height: nodeSize + 16)
                            .blur(radius: 8)
                    }

                    Circle()
                        .fill(nodeAccent.opacity(0.15))
                        .frame(width: nodeSize, height: nodeSize)
                    Circle()
                        .stroke(nodeAccent, lineWidth: state == .frontier ? 3 : 2)
                        .frame(width: nodeSize, height: nodeSize)

                    // Node content
                    if state == .cleared {
                        Circle()
                            .fill(Theme.success.opacity(0.85))
                            .frame(width: nodeSize, height: nodeSize)
                        Image(systemName: "checkmark")
                            .font(.body.bold())
                            .foregroundColor(.white)
                    } else if floor.isShop {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title3)
                            .foregroundColor(Theme.gold)
                    } else if floor.isBoss {
                        Image(systemName: "flame.fill")
                            .font(.title3)
                            .foregroundColor(Theme.flame)
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
                    ZStack {
                        Rectangle()
                            .fill(bottomLineColor)
                            .frame(width: 2, height: 20)
                        if state == .cleared {
                            Rectangle()
                                .fill(Theme.success.opacity(0.4))
                                .frame(width: 4, height: 20)
                                .blur(radius: 2)
                        }
                    }
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
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(Theme.flame)
                    }

                    Spacer()

                    if !floor.isShop {
                        HStack(spacing: 3) {
                            Image(systemName: "target")
                                .font(.caption2)
                                .foregroundColor(state == .cleared ? Theme.textTertiary : Theme.gold)
                            Text("\(floor.targetScore)")
                                .font(Theme.fontCaption.monospacedDigit())
                                .foregroundColor(state == .cleared ? Theme.textTertiary : Theme.gold)
                        }
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
