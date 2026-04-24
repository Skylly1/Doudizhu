import SwiftUI

/// 新手引导步骤
enum TutorialStep: Int, CaseIterable {
    case welcome = 0
    case goalExplain
    case patternBasics
    case bigPatterns
    case selectAndPlay
    case discardTip
    case comboTip
    case shopTip
    case done

    var title: String {
        switch self {
        case .welcome:       return L10n.tutorialWelcomeTitle
        case .goalExplain:   return L10n.tutorialGoalTitle
        case .patternBasics: return L10n.tutorialPatternTitle
        case .bigPatterns:   return L10n.tutorialBigPatternTitle
        case .selectAndPlay: return L10n.tutorialSelectTitle
        case .discardTip:    return L10n.tutorialDiscardTitle
        case .comboTip:      return L10n.tutorialComboTitle
        case .shopTip:       return L10n.tutorialShopTitle
        case .done:          return ""
        }
    }

    var message: String {
        switch self {
        case .welcome:       return L10n.tutorialWelcomeMsg
        case .goalExplain:   return L10n.tutorialGoalMsg
        case .patternBasics: return L10n.tutorialPatternMsg
        case .bigPatterns:   return L10n.tutorialBigPatternMsg
        case .selectAndPlay: return L10n.tutorialSelectMsg
        case .discardTip:    return L10n.tutorialDiscardMsg
        case .comboTip:      return L10n.tutorialComboMsg
        case .shopTip:       return L10n.tutorialShopMsg
        case .done:          return ""
        }
    }

    /// Total displayable steps (excludes .done)
    static var displayableCount: Int {
        allCases.filter { $0 != .done }.count
    }

    /// 1-based step number for display
    var stepNumber: Int { rawValue + 1 }

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
                    // Step indicator
                    HStack(spacing: 6) {
                        ForEach(0..<TutorialStep.displayableCount, id: \.self) { i in
                            Circle()
                                .fill(i == step.rawValue ? Theme.gold : Theme.gold.opacity(0.25))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 4)

                    Text(step.title)
                        .font(Theme.fontHeading)
                        .foregroundColor(Theme.gold)

                    Text(step.message)
                        .font(Theme.fontBody)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)

                    // Progress label
                    Text("\(step.stepNumber) / \(TutorialStep.displayableCount)")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(Theme.textTertiary)

                    HStack(spacing: Theme.spacingLG) {
                        Button(L10n.skipTutorial) {
                            manager.skip()
                        }
                        .font(.subheadline)
                        .foregroundColor(Theme.textDisabled)

                        Button(step.next != nil ? L10n.nextStep : L10n.startGame) {
                            manager.advance()
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, Theme.spacingLG)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Theme.gold))
                    }
                }
                .padding(.horizontal, Theme.spacingXL + 4)
                .padding(.vertical, Theme.spacingXL)
                .frame(maxWidth: 360)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusLG)
                        .fill(Theme.bgPrimary.opacity(0.95))
                        .stroke(Theme.gold.opacity(0.3))
                )
                .padding(.horizontal, Theme.spacingLG)
            }
            .transition(.opacity)
        }
    }
}
