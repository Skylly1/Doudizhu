import SwiftUI
import SpriteKit
import Combine

struct BattleView: View {
    let onBack: () -> Void
    @ObservedObject var rogueRun: RogueRun
    let onShop: () -> Void
    @State private var battleScene: BattleScene?
    @State private var showPatternGuide = false
    @StateObject private var achievementTracker = AchievementTracker.shared
    /// Bumped by BattleScene.selectionChanged to force SwiftUI re-evaluation
    @State private var selectionVersion = 0

    init(rogueRun: RogueRun, onBack: @escaping () -> Void, onShop: @escaping () -> Void) {
        self.rogueRun = rogueRun
        self.onBack = onBack
        self.onShop = onShop
    }

    var body: some View {
        ZStack {
            // SpriteKit 牌桌
            if let scene = battleScene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }

            // SwiftUI 覆盖层
            VStack(spacing: 0) {
                topBar
                Spacer()
                scoreTargetBar
                    .padding(.bottom, 8)
                actionButtons
                    .padding(.bottom, 30)
            }

            // 过关/失败弹窗
            if rogueRun.phase == .floorWin {
                floorWinOverlay
                    .onAppear { FeedbackManager.shared.floorWin() }
            } else if rogueRun.phase == .floorFail {
                floorFailOverlay
                    .onAppear { FeedbackManager.shared.floorFail() }
            } else if rogueRun.phase == .victory {
                victoryOverlay
                    .onAppear { FeedbackManager.shared.victory() }
            }

            // 成就解锁提示
            if let ach = achievementTracker.latestUnlock {
                VStack {
                    HStack(spacing: Theme.spacingSM) {
                        Text(ach.icon)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("🎉 \(L10n.achievementUnlocked)")
                                .font(Theme.fontCaption)
                                .foregroundColor(Theme.gold)
                            Text(ach.name)
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                        }
                    }
                    .padding(.horizontal, Theme.spacingLG)
                    .padding(.vertical, Theme.spacingSM)
                    .background(
                        Capsule()
                            .fill(Theme.bgPrimary.opacity(0.95))
                            .stroke(Theme.gold.opacity(0.4))
                    )
                    .shadow(color: Theme.gold.opacity(0.3), radius: 12, y: 4)
                    .transition(.move(edge: .top).combined(with: .opacity))

                    Spacer()
                }
                .padding(.top, 60)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation { achievementTracker.dismissLatest() }
                    }
                }
            }
        }
        .onAppear {
            if battleScene == nil {
                let scene = BattleScene(size: UIScreen.main.bounds.size)
                scene.scaleMode = .resizeFill
                scene.rogueRun = rogueRun
                battleScene = scene
            }
            // Refresh hand when returning from shop
            battleScene?.refreshHand()
        }
        .onChange(of: rogueRun.phase) { _, newPhase in
            if case .scoring(let result) = newPhase {
                // 触觉反馈
                FeedbackManager.shared.playCards(score: result.score)
                if result.pattern.type == .bomb || result.pattern.type == .rocket {
                    FeedbackManager.shared.explosion()
                }
                if result.combo > 1 {
                    FeedbackManager.shared.comboHit(level: result.combo)
                }
                // 得分动画：延迟后切回选牌
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    rogueRun.onScoringComplete()
                    battleScene?.refreshHand()
                }
            }
        }
        .onReceive(
            battleScene?.selectionChanged.eraseToAnyPublisher()
                ?? Empty<Void, Never>().eraseToAnyPublisher()
        ) { _ in
            selectionVersion += 1
        }
    }

    // MARK: - 顶部信息栏

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.ultraThinMaterial)
                    .symbolRenderingMode(.hierarchical)
            }

            Spacer()

            // 关卡信息
            VStack(spacing: 2) {
                Text(L10n.floorNumber(rogueRun.currentFloorIndex + 1))
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textTertiary)
                Text(rogueRun.currentFloor.name)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
            }

            Spacer()

            // 金币
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(Theme.gold)
                Text("\(rogueRun.gold)")
                    .font(.headline.monospacedDigit())
                    .foregroundColor(Theme.gold)
            }

            // 牌型参考按钮
            Button {
                showPatternGuide = true
            } label: {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.ultraThinMaterial)
                    .symbolRenderingMode(.hierarchical)
            }
            .sheet(isPresented: $showPatternGuide) {
                PatternGuideView()
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - 分数进度条

    private var scoreTargetBar: some View {
        VStack(spacing: 6) {
            // 规则牌标签
            if !rogueRun.activeJokers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(rogueRun.activeJokers) { joker in
                            HStack(spacing: 3) {
                                Text(joker.icon).font(.caption2)
                                Text(joker.name).font(.caption2)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Theme.cyanDim))
                            .foregroundColor(Theme.cyan)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Buff 标签
            if !rogueRun.activeBuffs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(rogueRun.activeBuffs) { buff in
                            HStack(spacing: 3) {
                                Text(buff.icon).font(.caption2)
                                Text(buff.name).font(.caption2)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Theme.flameDim))
                            .foregroundColor(Theme.flame)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // 分数 + 进度条
            HStack(spacing: 12) {
                // 出牌次数
                Label("\(rogueRun.playsRemaining)", systemImage: "hand.raised.fill")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(rogueRun.playsRemaining <= 1 ? Theme.danger : Theme.cyan)

                // 换牌次数
                Label("\(rogueRun.discardsRemaining)", systemImage: "arrow.triangle.2.circlepath")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(rogueRun.discardsRemaining == 0 ? Theme.textDisabled : Theme.success)

                Spacer()

                // 分数
                Text("\(rogueRun.floorScore)")
                    .font(.title2.bold().monospacedDigit())
                    .foregroundColor(Theme.textPrimary)
                Text("/ \(rogueRun.currentFloor.targetScore)")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(Theme.textTertiary)
            }
            .padding(.horizontal)

            // 进度条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.bgCard)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: geo.size.width * rogueRun.floorProgress, height: 8)
                        .animation(.spring(response: 0.4), value: rogueRun.floorProgress)
                }
            }
            .frame(height: 8)
            .padding(.horizontal)

            // 连击提示
            if rogueRun.combo > 1 {
                Text("🔥 \(L10n.comboText(rogueRun.combo, bonus: Int(Double(rogueRun.combo - 1) * 15)))")
                    .font(.caption.bold())
                    .foregroundColor(Theme.flame)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var progressColor: LinearGradient {
        let progress = rogueRun.floorProgress
        if progress >= 1.0 {
            return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
        } else if progress >= 0.6 {
            return LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
        }
    }

    // MARK: - 操作按钮

    /// 实时识别选中牌的牌型（selectionVersion 触发 SwiftUI 重算）
    private var selectedPattern: CardPattern? {
        _ = selectionVersion // read to create SwiftUI dependency
        guard let scene = battleScene else { return nil }
        let selected = scene.getSelectedCards()
        guard !selected.isEmpty else { return nil }
        return PatternRecognizer.recognize(selected)
    }

    private var actionButtons: some View {
        VStack(spacing: 8) {
            // 牌型提示
            if let pattern = selectedPattern {
                HStack(spacing: 6) {
                    Text(pattern.type.displayName)
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.cyan)
                    Text(L10n.baseScore(pattern.baseScore))
                        .font(Theme.fontCaption)
                        .foregroundColor(Theme.textTertiary)
                }
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(Theme.cyanDim)
                        .stroke(Theme.cyan.opacity(0.3))
                )
                .transition(.scale.combined(with: .opacity))
            } else if battleScene?.getSelectedCards().isEmpty == false {
                Text("❌ \(L10n.invalidPattern)")
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.danger.opacity(0.8))
                    .transition(.opacity)
            }

            HStack(spacing: Theme.spacingMD) {
            // 弃牌按钮
            Button {
                guard let scene = battleScene else { return }
                let selected = scene.getSelectedCards()
                if rogueRun.discardCards(selected) {
                    FeedbackManager.shared.discard()
                    scene.clearSelection()
                    scene.refreshHand()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text(L10n.swap)
                    Text("(\(rogueRun.discardsRemaining))")
                        .font(.caption)
                }
                .font(.body.weight(.medium))
                .foregroundColor(rogueRun.discardsRemaining > 0 ? Theme.textPrimary : Theme.textDisabled)
                .frame(width: 120, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(rogueRun.discardsRemaining > 0 ? Theme.dangerDim : Theme.bgInset)
                        .stroke(rogueRun.discardsRemaining > 0 ? Theme.danger.opacity(0.5) : Theme.borderLight)
                )
            }
            .disabled(rogueRun.discardsRemaining <= 0 || rogueRun.phase != .selecting)

            // 出牌按钮
            Button {
                battleScene?.playSelectedCards()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                    Text(L10n.play)
                    Text("(\(rogueRun.playsRemaining))")
                        .font(.caption)
                }
                .font(.body.weight(.semibold))
                .foregroundColor(rogueRun.playsRemaining > 0 ? .black : Theme.textDisabled)
                .frame(width: 140, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(rogueRun.playsRemaining > 0 ? Theme.gold : Theme.bgInset)
                )
            }
            .disabled(rogueRun.playsRemaining <= 0 || rogueRun.phase != .selecting)
            }
        }
    }

    // MARK: - 过关弹窗

    private var floorWinOverlay: some View {
        overlayBase {
            VStack(spacing: Theme.spacingLG) {
                Text("✨ \(L10n.cleared)")
                    .font(.largeTitle.bold())
                    .foregroundColor(Theme.gold)

                Text(rogueRun.currentFloor.name)
                    .font(.title3)
                    .foregroundColor(Theme.textSecondary)

                VStack(spacing: Theme.spacingSM) {
                    statRow(L10n.floorScoreLabel, value: "\(rogueRun.floorScore)")
                    statRow(L10n.totalScoreLabel, value: "\(rogueRun.totalScore)")
                    statRow(L10n.goldEarned, value: "+\(rogueRun.currentFloor.targetScore / 10)")
                }
                .padding(Theme.spacingMD)
                .background(RoundedRectangle(cornerRadius: Theme.radiusSM).fill(Theme.bgCard))

                PrimaryButton(title: L10n.continueForward, icon: "arrow.right") {
                    rogueRun.advanceToNextFloor()
                    battleScene?.refreshHand()
                }
                .frame(width: 220)
            }
        }
    }

    private var floorFailOverlay: some View {
        overlayBase {
            VStack(spacing: Theme.spacingLG) {
                Text("💀 \(L10n.failed)")
                    .font(.largeTitle.bold())
                    .foregroundColor(Theme.danger)

                Text(L10n.targetNotReached)
                    .foregroundColor(Theme.textSecondary)

                VStack(spacing: Theme.spacingSM) {
                    statRow(L10n.floorScoreLabel, value: "\(rogueRun.floorScore)")
                    statRow(L10n.targetScoreLabel, value: "\(rogueRun.currentFloor.targetScore)")
                    statRow(L10n.totalScoreLabel, value: "\(rogueRun.totalScore)")
                }
                .padding(Theme.spacingMD)
                .background(RoundedRectangle(cornerRadius: Theme.radiusSM).fill(Theme.bgCard))

                Button(L10n.restart) {
                    rogueRun.restart()
                    battleScene?.refreshHand()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 220, height: 50)
                .background(RoundedRectangle(cornerRadius: Theme.radiusMD).fill(Theme.danger))
            }
        }
    }

    private var victoryOverlay: some View {
        overlayBase {
            VStack(spacing: Theme.spacingLG) {
                Text("🏆 \(L10n.victory)")
                    .font(.largeTitle.bold())
                    .foregroundColor(Theme.gold)

                Text(L10n.bossDefeated)
                    .font(.title3)
                    .foregroundColor(Theme.textPrimary)

                Text(L10n.totalScoreValue(rogueRun.totalScore))
                    .font(.title.bold().monospacedDigit())
                    .foregroundColor(Theme.gold)

                PrimaryButton(title: L10n.playAgain, icon: "arrow.clockwise") {
                    rogueRun.restart()
                    battleScene?.refreshHand()
                }
                .frame(width: 220)

                SecondaryButton(title: L10n.backToMenu, icon: "house") {
                    onBack()
                }
            }
        }
    }

    // MARK: - Helpers

    private func overlayBase<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
            VStack {
                content()
            }
            .padding(Theme.spacingXL)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusLG)
                    .fill(Theme.bgPrimary.opacity(0.95))
                    .stroke(Theme.gold.opacity(0.2))
            )
            .padding(Theme.spacingXL)
        }
    }

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.fontMono)
                .foregroundColor(Theme.textPrimary)
        }
    }
}

#Preview {
    BattleView(rogueRun: RogueRun(), onBack: {}, onShop: {})
}
