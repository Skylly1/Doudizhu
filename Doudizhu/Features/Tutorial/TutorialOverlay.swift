import SwiftUI

/// 新手引导步骤
enum TutorialStep: Int, CaseIterable {
    case welcome = 0
    case selectCards
    case playCards
    case discardTip
    case comboTip
    case shopTip
    case done

    var title: String {
        switch self {
        case .welcome:     return "欢迎来到斗破乾坤！"
        case .selectCards: return "选牌"
        case .playCards:   return "出牌"
        case .discardTip:  return "换牌"
        case .comboTip:    return "连击"
        case .shopTip:     return "商店"
        case .done:        return ""
        }
    }

    var message: String {
        switch self {
        case .welcome:
            return "在这个 Roguelike 斗地主中，你需要在有限的出牌次数内凑够目标分数。\n\n点击任意位置继续。"
        case .selectCards:
            return "点击手中的卡牌来选中它们。\n组成合法的斗地主牌型（对子、顺子、炸弹等）可以得分。"
        case .playCards:
            return "选好牌后，点击「出牌」按钮打出。\n牌型越复杂、牌越多，得分越高！"
        case .discardTip:
            return "手牌不好？选中不需要的牌，点击「换牌」抽新牌。\n换牌次数有限，要省着用。"
        case .comboTip:
            return "连续出牌会触发连击加分！\n每次连击 +15%，不要中断。"
        case .shopTip:
            return "每隔几关会进入商店。\n购买规则牌和增益道具，打造你的流派！"
        case .done:
            return ""
        }
    }

    var next: TutorialStep? {
        let allCases = TutorialStep.allCases
        guard let idx = allCases.firstIndex(of: self),
              idx + 1 < allCases.count else { return nil }
        let nextStep = allCases[idx + 1]
        return nextStep == .done ? nil : nextStep
    }
}

/// 教程管理器
@MainActor
class TutorialManager: ObservableObject {
    @Published var currentStep: TutorialStep? = nil
    @Published var hasCompletedTutorial: Bool

    private let completedKey = "hasCompletedTutorial"

    init() {
        self.hasCompletedTutorial = UserDefaults.standard.bool(forKey: "hasCompletedTutorial")
    }

    func startIfNeeded() {
        guard !hasCompletedTutorial else { return }
        currentStep = .welcome
    }

    func advance() {
        guard let step = currentStep else { return }
        if let nextStep = step.next {
            currentStep = nextStep
        } else {
            complete()
        }
    }

    func skip() {
        complete()
    }

    private func complete() {
        currentStep = nil
        hasCompletedTutorial = true
        UserDefaults.standard.set(true, forKey: completedKey)
    }
}

/// 半透明教程弹窗覆盖层
struct TutorialOverlay: View {
    @ObservedObject var manager: TutorialManager

    var body: some View {
        if let step = manager.currentStep {
            ZStack {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .onTapGesture {
                        manager.advance()
                    }

                VStack(spacing: Theme.spacingLG) {
                    Text(step.title)
                        .font(Theme.fontHeading)
                        .foregroundColor(Theme.gold)

                    Text(step.message)
                        .font(Theme.fontBody)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    HStack(spacing: Theme.spacingLG) {
                        Button("跳过教程") {
                            manager.skip()
                        }
                        .font(.subheadline)
                        .foregroundColor(Theme.textDisabled)

                        Button(step.next != nil ? "下一步 →" : "开始游戏！") {
                            manager.advance()
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, Theme.spacingLG)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Theme.gold))
                    }
                }
                .padding(Theme.spacingXL)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusLG)
                        .fill(Theme.bgPrimary.opacity(0.95))
                        .stroke(Theme.gold.opacity(0.3))
                )
                .padding(Theme.spacingXL)
            }
            .transition(.opacity)
        }
    }
}
