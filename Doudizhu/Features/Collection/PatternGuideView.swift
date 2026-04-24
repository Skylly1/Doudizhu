import SwiftUI

/// 牌型参考指南 — 展示所有合法牌型及其得分
struct PatternGuideView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // 标题
                    HStack {
                        Text("🃏 牌型参考")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding(.horizontal)

                    // 基础牌型
                    sectionHeader("基础牌型", icon: "suit.club.fill")
                    patternRow(name: "单张", example: "任意一张牌", score: "5 分", tip: "效率最低，尽量避免")
                    patternRow(name: "对子", example: "两张相同点数", score: "12 分", tip: "6 分/张")
                    patternRow(name: "三条", example: "三张相同点数", score: "20 分", tip: "6.7 分/张")

                    // 组合牌型
                    sectionHeader("组合牌型", icon: "rectangle.stack.fill")
                    patternRow(name: "三带一", example: "三条 + 一张单牌", score: "35 分", tip: "⭐ 8.75 分/张，性价比高")
                    patternRow(name: "三带二", example: "三条 + 一对", score: "50 分", tip: "⭐⭐ 10 分/张，推荐！")
                    patternRow(name: "四带二", example: "四张同点 + 两张单牌", score: "150 分", tip: "⭐⭐ 25 分/张")

                    // 顺序牌型
                    sectionHeader("顺序牌型", icon: "arrow.right.circle.fill")
                    patternRow(name: "顺子", example: "5+ 张连续单牌 (3-7, 8-Q-K-A 等)", score: "75+ 分", tip: "越长越值！不含 2 和王")
                    patternRow(name: "连对", example: "3+ 连续对子 (33-44-55 等)", score: "66+ 分", tip: "长度奖励")
                    patternRow(name: "飞机", example: "2+ 连续三条 (333-444 等)", score: "110+ 分", tip: "强力！18.3 分/张")
                    patternRow(name: "飞机带翅膀", example: "飞机 + 等量单牌或对子", score: "122+ 分", tip: "出完大量牌")

                    // 炸弹类
                    sectionHeader("炸弹类 💥", icon: "flame.fill")
                    patternRow(name: "💣 炸弹", example: "四张相同点数", score: "120 分", tip: "⭐⭐⭐ 30 分/张！")
                    patternRow(name: "🚀 火箭", example: "大王 + 小王", score: "250 分", tip: "⭐⭐⭐ 最强！125 分/张")

                    // 策略提示
                    sectionHeader("策略要点", icon: "lightbulb.fill")
                    tipCard("连击加分", "连续出牌每次 +15%。换牌会减 1 点连击，不会归零。")
                    tipCard("出大牌", "三带二 > 三带一 > 三条。组合越复杂越值。")
                    tipCard("攒炸弹", "炸弹 120 分是普通出牌的 10 倍+，值得等！")
                    tipCard("规则牌", "商店的规则牌能改变玩法规则，不只是加分。")

                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.yellow)
            Text(title)
                .font(.headline)
                .foregroundColor(.yellow)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func patternRow(name: String, example: String, score: String, tip: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Spacer()
                Text(score)
                    .font(.subheadline.bold().monospacedDigit())
                    .foregroundColor(.cyan)
            }
            Text(example)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            Text(tip)
                .font(.caption)
                .foregroundColor(.orange.opacity(0.8))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.05))
        )
        .padding(.horizontal)
    }

    private func tipCard(_ title: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("💡")
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text(text)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.yellow.opacity(0.05))
                .stroke(.yellow.opacity(0.15))
        )
        .padding(.horizontal)
    }
}
