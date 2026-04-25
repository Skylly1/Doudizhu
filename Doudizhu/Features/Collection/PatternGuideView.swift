import SwiftUI

/// 牌型参考指南 — 展示所有合法牌型及其得分
struct PatternGuideView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingMD) {
                // 标题
                HStack {
                    Text(L10n.patternGuide)
                        .font(Theme.fontHeading)
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.ultraThinMaterial)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .padding(.horizontal, Theme.spacingMD)

                // Basic patterns
                sectionHeader(L10n.sectionBasicPatterns, icon: "suit.club.fill")
                patternRow(name: L10n.patternSingle, example: L10n.exampleSingle, score: L10n.pts(5), tip: L10n.tipSingle)
                patternRow(name: L10n.patternPair, example: L10n.examplePair, score: L10n.pts(12), tip: L10n.tipPair)
                patternRow(name: L10n.patternTriple, example: L10n.exampleTriple, score: L10n.pts(20), tip: L10n.tipTriple)

                // Combo patterns
                sectionHeader(L10n.sectionComboPatterns, icon: "rectangle.stack.fill")
                patternRow(name: L10n.patternTripleOne, example: L10n.exampleTripleOne, score: L10n.pts(35), tip: L10n.tipTripleOne)
                patternRow(name: L10n.patternTriplePair, example: L10n.exampleTriplePair, score: L10n.pts(50), tip: L10n.tipTriplePair)
                patternRow(name: L10n.patternFourTwo, example: L10n.exampleFourTwo, score: L10n.pts(150), tip: L10n.tipFourTwo)

                // Sequence patterns
                sectionHeader(L10n.sectionSequencePatterns, icon: "arrow.right.circle.fill")
                patternRow(name: L10n.patternStraight, example: L10n.exampleStraight, score: L10n.ptsPlus(75), tip: L10n.tipStraight)
                patternRow(name: L10n.patternPairStraight, example: L10n.examplePairStraight, score: L10n.ptsPlus(66), tip: L10n.tipPairStraight)
                patternRow(name: L10n.patternPlane, example: L10n.examplePlane, score: L10n.ptsPlus(110), tip: L10n.tipPlane)
                patternRow(name: L10n.patternPlaneWings, example: L10n.examplePlaneWings, score: L10n.ptsPlus(122), tip: L10n.tipPlaneWings)

                // Bombs
                sectionHeader(L10n.sectionBombs, icon: "flame.fill")
                patternRow(name: "💣 \(L10n.patternBomb)", example: L10n.exampleBomb, score: L10n.pts(120), tip: L10n.tipBomb)
                patternRow(name: "🚀 \(L10n.patternRocket)", example: L10n.exampleRocket, score: L10n.pts(250), tip: L10n.tipRocket)

                // Strategy tips
                sectionHeader(L10n.sectionStrategy, icon: "lightbulb.fill")
                tipCard(L10n.strategyComboTitle, L10n.strategyComboDesc)
                tipCard(L10n.strategyBigTitle, L10n.strategyBigDesc)
                tipCard(L10n.strategySaveBombsTitle, L10n.strategySaveBombsDesc)
                tipCard(L10n.strategyJokersTitle, L10n.strategyJokersDesc)

                Spacer(minLength: Theme.spacingXL)
            }
            .padding(.top, Theme.spacingMD)
        }
        .gameBackground()
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: icon)
                .foregroundColor(Theme.gold)
            Text(title)
                .font(Theme.fontSection)
                .foregroundColor(Theme.gold)
            Spacer()
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.top, Theme.spacingSM)
    }

    private func patternRow(name: String, example: String, score: String, tip: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text(score)
                    .font(Theme.fontMono)
                    .foregroundColor(Theme.cyan)
            }
            Text(example)
                .font(Theme.fontCaption)
                .foregroundColor(Theme.textTertiary)
            Text(tip)
                .font(Theme.fontCaption)
                .foregroundColor(Theme.flame.opacity(0.9))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusSM)
                .fill(Theme.bgCard)
        )
        .padding(.horizontal, Theme.spacingMD)
    }

    private func tipCard(_ title: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(Theme.gold)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textPrimary)
                Text(text)
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusSM)
                .fill(Theme.gold.opacity(0.05))
                .stroke(Theme.gold.opacity(0.15))
        )
        .padding(.horizontal, Theme.spacingMD)
    }
}
