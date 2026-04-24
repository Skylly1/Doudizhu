import SwiftUI

/// 开局前选择起始流派
struct BuildSelectView: View {
    let onSelect: (StarterBuild) -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Compact inline header
                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.ultraThinMaterial)
                            .symbolRenderingMode(.hierarchical)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.chooseBuild)
                            .font(Theme.fontSection)
                            .foregroundColor(Theme.textPrimary)
                        Text(L10n.buildHint)
                            .font(Theme.fontCaption)
                            .foregroundColor(Theme.textTertiary)
                    }

                    Spacer()
                }
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ], spacing: 10) {
                        ForEach(StarterBuild.allBuilds) { build in
                            BuildCard(build: build) {
                                onSelect(build)
                            }
                        }
                    }
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.top, Theme.spacingSM)
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
            VStack(spacing: 6) {
                Text(build.icon)
                    .font(.system(size: 28))

                Text(build.name)
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textPrimary)

                Text(build.description)
                    .font(.caption2)
                    .foregroundColor(Theme.textTertiary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Divider().background(Theme.border)

                VStack(spacing: 3) {
                    if let joker = build.startingJoker {
                        HStack(spacing: 2) {
                            Text(joker.icon).font(.caption2)
                            Text(joker.name).font(.caption2)
                        }
                        .foregroundColor(Theme.cyan)
                        .lineLimit(1)
                    }
                    if let buff = build.startingBuff {
                        HStack(spacing: 2) {
                            Text(buff.icon).font(.caption2)
                            Text(buff.name).font(.caption2)
                        }
                        .foregroundColor(Theme.flame)
                        .lineLimit(1)
                    }
                    if build.goldAdjustment != 0 {
                        let sign = build.goldAdjustment > 0 ? "+" : ""
                        Text("💰 \(sign)\(build.goldAdjustment)")
                            .font(.caption2)
                            .foregroundColor(Theme.gold)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .fill(Theme.bgCard)
                    .stroke(Theme.border)
            )
        }
    }
}
