import SwiftUI

/// 开局前选择起始流派
struct BuildSelectView: View {
    let onSelect: (StarterBuild) -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                GameNavBar(title: L10n.chooseBuild, subtitle: L10n.buildHint, onBack: onBack)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(StarterBuild.allBuilds) { build in
                            BuildCard(build: build) {
                                onSelect(build)
                            }
                        }
                    }
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.top, Theme.spacingMD)
                    .padding(.bottom, Theme.spacingXXL)
                }
            }
        }
    }
}

private struct BuildCard: View {
    let build: StarterBuild
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 10) {
                Text(build.icon)
                    .font(.system(size: 36))

                Text(build.name)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)

                Text(build.description)
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Divider().background(Theme.border)

                // 起始装备标签
                VStack(spacing: 4) {
                    if let joker = build.startingJoker {
                        HStack(spacing: 3) {
                            Text(joker.icon).font(.caption2)
                            Text(joker.name).font(.caption2)
                        }
                        .foregroundColor(Theme.cyan)
                    }
                    if let buff = build.startingBuff {
                        HStack(spacing: 3) {
                            Text(buff.icon).font(.caption2)
                            Text(buff.name).font(.caption2)
                        }
                        .foregroundColor(Theme.flame)
                    }
                    if build.goldAdjustment != 0 {
                        let sign = build.goldAdjustment > 0 ? "+" : ""
                        Text("💰 \(sign)\(build.goldAdjustment)")
                            .font(.caption2)
                            .foregroundColor(Theme.gold)
                    }
                }
            }
            .padding(Theme.spacingMD)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .fill(Theme.bgCard)
                    .stroke(Theme.border)
            )
        }
    }
}
