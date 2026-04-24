import SwiftUI

/// 开局前选择起始流派
struct BuildSelectView: View {
    let onSelect: (StarterBuild) -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("选择流派")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange],
                                       startPoint: .top, endPoint: .bottom)
                    )

                Text("不同流派影响你的起始装备和金币")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))

                ForEach(StarterBuild.allBuilds) { build in
                    BuildCard(build: build) {
                        onSelect(build)
                    }
                }

                Spacer()

                Button("返回", action: onBack)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom)
            }
            .padding(.top, 60)
            .padding(.horizontal)
        }
    }
}

private struct BuildCard: View {
    let build: StarterBuild
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Text(build.icon)
                    .font(.system(size: 40))

                VStack(alignment: .leading, spacing: 4) {
                    Text(build.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(build.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)

                    HStack(spacing: 12) {
                        if let joker = build.startingJoker {
                            Label(joker.name, systemImage: "sparkles")
                                .font(.caption2)
                                .foregroundColor(.cyan)
                        }
                        if let buff = build.startingBuff {
                            Label(buff.name, systemImage: "bolt.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                        if build.goldAdjustment != 0 {
                            let sign = build.goldAdjustment > 0 ? "+" : ""
                            Label("\(sign)\(build.goldAdjustment)", systemImage: "dollarsign.circle")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(0.06))
                    .stroke(.white.opacity(0.12))
            )
        }
    }
}
