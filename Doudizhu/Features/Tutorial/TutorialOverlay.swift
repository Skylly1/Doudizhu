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
        }
    }

    /// Steps grouped by tutorial phase
    /// Phase 1: 核心操作（含换牌——QA反馈必须前置）
    /// Phase 2: 进阶技巧
    /// Phase 3: 系统介绍
    static let phase1: [TutorialStep] = [.welcome, .patternBasics, .selectAndPlay, .discardTip]
    static let phase2: [TutorialStep] = [.comboTip, .bigPatterns]
    static let phase3: [TutorialStep] = [.shopTip, .goalExplain]

    static func stepsForPhase(_ phase: Int) -> [TutorialStep] {
        switch phase {
        case 0: return phase1
        case 1: return phase2
        case 2: return phase3
        default: return []
        }
    }
}

/// 教程管理器（三阶段渐进式教学）
@MainActor
class TutorialManager: ObservableObject {
    @Published var currentStep: TutorialStep? = nil
    @Published var tutorialPhase: Int

    private let phaseKey = "tutorialPhase"
    private let legacyKey = "hasCompletedTutorial"

    var hasCompletedTutorial: Bool {
        tutorialPhase >= 3
    }

    /// Steps for the currently active phase
    var currentPhaseSteps: [TutorialStep] {
        TutorialStep.stepsForPhase(tutorialPhase)
    }

    init() {
        // Migrate from legacy single-bool storage
        if UserDefaults.standard.bool(forKey: "hasCompletedTutorial") {
            let stored = UserDefaults.standard.integer(forKey: "tutorialPhase")
            if stored < 3 {
                UserDefaults.standard.set(3, forKey: "tutorialPhase")
            }
        }
        self.tutorialPhase = UserDefaults.standard.integer(forKey: "tutorialPhase")
    }

    func startIfNeeded() {
        switch tutorialPhase {
        case 0:
            currentStep = .welcome
        case 1:
            currentStep = .comboTip
        case 2:
            currentStep = .shopTip
        default:
            break
        }
        if currentStep != nil {
            Analytics.shared.track(.tutorialStart)
        }
    }

    func advance() {
        guard let step = currentStep else { return }
        if let next = nextStepInCurrentPhase(after: step) {
            currentStep = next
        } else {
            completePhase()
        }
    }

    func skip() {
        Analytics.shared.track(.tutorialSkip)
        completePhase()
    }

    /// Check whether the current step is the last one in its phase
    var isLastStepInPhase: Bool {
        guard let step = currentStep else { return true }
        return nextStepInCurrentPhase(after: step) == nil
    }

    private func completePhase() {
        currentStep = nil
        tutorialPhase += 1
        UserDefaults.standard.set(tutorialPhase, forKey: phaseKey)
        if tutorialPhase >= 3 {
            Analytics.shared.track(.tutorialComplete)
        }
    }

    private func nextStepInCurrentPhase(after step: TutorialStep) -> TutorialStep? {
        let steps = currentPhaseSteps
        guard let idx = steps.firstIndex(of: step),
              idx + 1 < steps.count else { return nil }
        return steps[idx + 1]
    }
}

/// 半透明教程弹窗覆盖层
struct TutorialOverlay: View {
    @ObservedObject var manager: TutorialManager

    var body: some View {
        if let step = manager.currentStep {
            let phaseSteps = manager.currentPhaseSteps
            let stepIndex = phaseSteps.firstIndex(of: step) ?? 0

            ZStack {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .onTapGesture {
                        manager.advance()
                    }

                VStack(spacing: Theme.spacingLG) {
                    // Step indicator (dots for current phase only)
                    HStack(spacing: 6) {
                        ForEach(0..<phaseSteps.count, id: \.self) { i in
                            Circle()
                                .fill(i == stepIndex ? Theme.gold : Theme.gold.opacity(0.25))
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

                    if step == .patternBasics || step == .bigPatterns {
                        patternExamplesView(for: step)
                    }

                    // Progress label
                    Text("\(stepIndex + 1) / \(phaseSteps.count)")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(Theme.textTertiary)

                    HStack(spacing: Theme.spacingLG) {
                        Button(L10n.skipTutorial) {
                            manager.skip()
                        }
                        .font(.subheadline)
                        .foregroundColor(Theme.textDisabled)

                        Button(manager.isLastStepInPhase ? L10n.startGame : L10n.nextStep) {
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

    @ViewBuilder
    private func patternExamplesView(for step: TutorialStep) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Divider().background(Theme.border)
            if step == .patternBasics {
                patternRow(L10n.patternSingle, "🂡", L10n.pts(10))
                patternRow(L10n.patternPair, "🂡🂱", L10n.pts(20))
                patternRow(L10n.patternTriple, "🂡🂱🃁", L10n.pts(40))
                patternRow(L10n.patternStraight, "🂣🂤🂥🂦🂧", L10n.pts(80))
                patternRow(L10n.patternPairStraight, "🂣🂳🂤🂴", L10n.pts(60))
            } else {
                patternRow(L10n.patternBomb, "🂡🂱🃁🃑", L10n.pts(240))
                patternRow(L10n.patternRocket, "🃟🃏", L10n.pts(400))
                patternRow(L10n.patternPlane, "🂣🂳🃃🂤🂴🃄", L10n.pts(160))
                patternRow(L10n.patternTripleOne, "🂡🂱🃁+🂣", L10n.pts(50))
            }
        }
        .padding(.horizontal, 8)
    }

    private func patternRow(_ name: String, _ example: String, _ score: String) -> some View {
        HStack {
            Text(name)
                .font(.caption.bold())
                .foregroundColor(Theme.cyan)
                .frame(width: 50, alignment: .leading)
            Text(example)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            Spacer()
            Text(score)
                .font(.caption.bold().monospacedDigit())
                .foregroundColor(Theme.gold)
        }
    }
}
