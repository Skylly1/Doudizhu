import SwiftUI

/// 上下文智能提示管理器 — 事件驱动，与 TutorialManager 解耦
/// 每个提示只展示一次（hasSeenXxx flags），在关键节点主动引导用户
@MainActor
final class ContextualHintManager: ObservableObject {
    static let shared = ContextualHintManager()

    @Published var activeHint: ContextualHint?

    private init() {}

    // MARK: - 提示类型

    enum ContextualHint: Identifiable {
        case bossIntro(modifierNames: [String])
        case achievementIntro
        case upgradeIntro
        case lowGoldWarning
        case firstSwap

        var id: String {
            switch self {
            case .bossIntro:       return "boss_intro"
            case .achievementIntro: return "achievement_intro"
            case .upgradeIntro:    return "upgrade_intro"
            case .lowGoldWarning:  return "low_gold_warning"
            case .firstSwap:       return "first_swap"
            }
        }

        var title: String {
            switch self {
            case .bossIntro:
                return L10n.isEnglish ? "⚔️ Boss Battle!" : "⚔️ Boss 关卡！"
            case .achievementIntro:
                return L10n.isEnglish ? "🏆 Achievements Unlock Jokers!" : "🏆 成就可以解锁规则牌！"
            case .upgradeIntro:
                return L10n.isEnglish ? "📖 Pattern Upgrades" : "📖 牌型升级系统"
            case .lowGoldWarning:
                return L10n.isEnglish ? "💡 Low on Gold" : "💡 金币不足"
            case .firstSwap:
                return L10n.isEnglish ? "🔄 Swap Cards" : "🔄 换牌说明"
            }
        }

        var message: String {
            switch self {
            case .bossIntro(let names):
                let mods = names.joined(separator: "、")
                return L10n.isEnglish
                    ? "Boss floors have special rules: \(mods). Plan your strategy carefully!"
                    : "Boss 关有特殊规则：\(mods)。提前规划你的出牌策略！"
            case .achievementIntro:
                return L10n.isEnglish
                    ? "Complete achievements to unlock Rare and Legendary Jokers in the shop!\n\n🥈 Reach Floor 5 → Unlock Rare Jokers\n🥇 Full Clear → Unlock Legendary Jokers"
                    : "完成成就可以解锁更多稀有和传说规则牌！\n\n🥈 到达第5层 → 解锁稀有规则牌\n🥇 通关全部关卡 → 解锁传说规则牌"
            case .upgradeIntro:
                return L10n.isEnglish
                    ? "Use gold to permanently upgrade pattern base scores in the shop!\n\nUpgrades carry over between runs — invest wisely."
                    : "在商店用金币永久升级牌型基础分！\n\n升级效果跨局保留，合理投资！"
            case .lowGoldWarning:
                return L10n.isEnglish
                    ? "Save some gold for upgrades! Pattern upgrades are permanent and give long-term value."
                    : "留一些金币升级武功秘籍！牌型升级是永久的，长期收益更高。"
            case .firstSwap:
                return L10n.isEnglish
                    ? "Select the cards you don't want, then tap Swap to replace them with new cards from the deck.\n\n💡 Swapping does NOT consume a play, but it breaks your combo streak.\n\n📌 Each floor has limited swap chances — use them wisely!"
                    : "先选中不想要的牌，然后点「换牌」，这些牌会放回牌堆，并重新抽取等量新牌。\n\n💡 换牌不消耗出牌次数，但会打断连击。\n\n📌 每层的换牌次数有限，请合理使用！"
            }
        }

        var icon: String {
            switch self {
            case .bossIntro:        return "shield.lefthalf.filled"
            case .achievementIntro: return "trophy.fill"
            case .upgradeIntro:     return "book.closed.fill"
            case .lowGoldWarning:   return "dollarsign.circle"
            case .firstSwap:        return "arrow.triangle.2.circlepath"
            }
        }

        var accentColor: Color {
            switch self {
            case .bossIntro:        return Theme.flame
            case .achievementIntro: return Theme.gold
            case .upgradeIntro:     return Theme.gold
            case .lowGoldWarning:   return Theme.cyan
            case .firstSwap:        return Theme.cyan
            }
        }
    }

    // MARK: - 触发逻辑

    /// 进入 Boss 关时触发
    func onBossFloorEnter(modifierNames: [String]) {
        guard !hasSeen("boss_intro") else { return }
        show(.bossIntro(modifierNames: modifierNames))
    }

    /// 首次查看成就页时触发
    func onAchievementPageViewed() {
        guard !hasSeen("achievement_intro") else { return }
        show(.achievementIntro)
    }

    /// 首次看到武功秘籍区时触发
    func onUpgradeSectionViewed() {
        guard !hasSeen("upgrade_intro") else { return }
        show(.upgradeIntro)
    }

    /// 商店中金币不足但还没升级过
    func onLowGoldInShop(gold: Int) {
        guard gold < 30, !hasSeen("low_gold_warning") else { return }
        show(.lowGoldWarning)
    }

    /// 首次使用换牌时触发
    func onFirstSwap() {
        guard !hasSeen("first_swap") else { return }
        show(.firstSwap)
    }

    // MARK: - 展示 & 消除

    func dismiss() {
        guard let hint = activeHint else { return }
        markSeen(hint.id)
        withAnimation(.spring(response: 0.3)) {
            activeHint = nil
        }
    }

    private func show(_ hint: ContextualHint) {
        withAnimation(.spring(response: 0.4)) {
            activeHint = hint
        }
        Analytics.shared.track(.stuckHintShown, params: ["hint_type": hint.id])
    }

    // MARK: - 持久化

    private func hasSeen(_ key: String) -> Bool {
        UserDefaults.standard.bool(forKey: "ctxHint_\(key)")
    }

    private func markSeen(_ key: String) {
        UserDefaults.standard.set(true, forKey: "ctxHint_\(key)")
    }

    /// 重置所有提示（设置页面用）
    func resetAll() {
        for key in ["boss_intro", "achievement_intro", "upgrade_intro", "low_gold_warning", "first_swap"] {
            UserDefaults.standard.removeObject(forKey: "ctxHint_\(key)")
        }
    }
}

// MARK: - 通用上下文提示弹窗 View

struct ContextualHintOverlay: View {
    @ObservedObject var manager: ContextualHintManager

    var body: some View {
        if let hint = manager.activeHint {
            ZStack {
                Color.black.opacity(0.5).ignoresSafeArea()
                    .onTapGesture { manager.dismiss() }

                VStack(spacing: Theme.spacingLG) {
                    Image(systemName: hint.icon)
                        .font(.system(size: 36))
                        .foregroundColor(hint.accentColor)
                        .shadow(color: hint.accentColor.opacity(0.4), radius: 8)

                    Text(hint.title)
                        .font(.title3.bold())
                        .foregroundColor(Theme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(hint.message)
                        .font(Theme.fontBody)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        manager.dismiss()
                    } label: {
                        Text(L10n.isEnglish ? "Got it!" : "知道了！")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal, Theme.spacingXL)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(hint.accentColor))
                    }
                }
                .padding(Theme.spacingXL)
                .frame(maxWidth: 320)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusLG)
                        .fill(Theme.bgPrimary.opacity(0.95))
                        .stroke(hint.accentColor.opacity(0.3))
                )
                .shadow(color: hint.accentColor.opacity(0.15), radius: 16, y: 4)
                .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
                .padding(Theme.spacingLG)
            }
            .transition(.scale(scale: 0.85).combined(with: .opacity))
        }
    }
}
