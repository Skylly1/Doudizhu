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
                    .padding(.bottom, 4)
                actionButtons
                    .padding(.bottom, 30)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.6), .black.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .padding(.top, -60)
                        .ignoresSafeArea(edges: .bottom)
                    )
            }

            // 过关/失败弹窗
            if rogueRun.phase == .floorWin {
                floorWinOverlay
                    .onAppear {
                        FeedbackManager.shared.floorWin()
                        SoundManager.shared.play(.floorClear)
                    }
            } else if rogueRun.phase == .floorFail {
                floorFailOverlay
                    .onAppear {
                        FeedbackManager.shared.floorFail()
                        SoundManager.shared.play(.floorFail)
                    }
            } else if rogueRun.phase == .victory {
                victoryOverlay
                    .onAppear {
                        FeedbackManager.shared.victory()
                        SoundManager.shared.play(.victory)
                    }
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
                    SoundManager.shared.play(.achievementUnlock)
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
                SoundManager.shared.play(.cardPlay)
                if result.pattern.type == .bomb || result.pattern.type == .rocket {
                    FeedbackManager.shared.explosion()
                    SoundManager.shared.play(.bombExplosion)
                }
                if result.combo > 1 {
                    FeedbackManager.shared.comboHit(level: result.combo)
                    SoundManager.shared.play(.comboHit(level: result.combo))
                }
                SoundManager.shared.play(.scoreUp)
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

    // MARK: - 顶部信息栏（紧凑单行）

    private var topBar: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.ultraThinMaterial)
                    .symbolRenderingMode(.hierarchical)
            }

            // 关卡名 + 目标分，合并为一行
            HStack(spacing: 4) {
                Text(L10n.floorNumber(rogueRun.currentFloorIndex + 1))
                    .font(.caption2)
                    .foregroundColor(Theme.textTertiary)
                if rogueRun.ascensionLevel > 0 {
                    Text("A\(rogueRun.ascensionLevel)")
                        .font(.caption2.bold())
                        .foregroundColor(Theme.flame)
                        .padding(.horizontal, 3)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(Theme.flameDim))
                }
                Text(rogueRun.currentFloor.name)
                    .font(.subheadline.bold())
                    .foregroundColor(rogueRun.currentFloor.isBoss ? Theme.flame : Theme.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            // 金币
            HStack(spacing: 3) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.caption)
                    .foregroundColor(Theme.gold)
                Text("\(rogueRun.gold)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundColor(Theme.gold)
            }

            // 牌型参考按钮
            Button {
                showPatternGuide = true
            } label: {
                Image(systemName: "questionmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(.ultraThinMaterial)
                    .symbolRenderingMode(.hierarchical)
            }
            .sheet(isPresented: $showPatternGuide) {
                PatternGuideView()
            }
        }
        .padding(.horizontal, Theme.spacingSM)
        .padding(.top, 4)
    }

    // MARK: - 分数进度条

    private var scoreTargetBar: some View {
        VStack(spacing: 3) {
            // Boss 修改器警告（compact inline）
            if let boss = rogueRun.bossState {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(boss.modifiers, id: \.rawValue) { mod in
                            HStack(spacing: 3) {
                                Text(mod.name).font(.caption2.bold())
                                Text(mod.description).font(.caption2)
                            }
                            .foregroundColor(Theme.flame)
                        }
                        if let banned = boss.bannedPatternType {
                            HStack(spacing: 2) {
                                Text("⛔").font(.caption2)
                                Text(L10n.bannedPatternLabel(banned.displayName))
                                    .font(.caption2.bold())
                                    .foregroundColor(Theme.danger)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                }
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.flameDim)
                        .stroke(Theme.flame.opacity(0.3))
                )
                .padding(.horizontal)
            }

            // Jokers + Buffs merged into one scrollable row
            if !rogueRun.activeJokers.isEmpty || !rogueRun.activeBuffs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(rogueRun.activeJokers) { joker in
                            HStack(spacing: 2) {
                                Text(joker.icon).font(.caption2)
                                Text(joker.name).font(.caption2)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Theme.cyanDim))
                            .foregroundColor(Theme.cyan)
                        }
                        ForEach(rogueRun.activeBuffs) { buff in
                            HStack(spacing: 2) {
                                Text(buff.icon).font(.caption2)
                                Text(buff.name).font(.caption2)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Theme.flameDim))
                            .foregroundColor(Theme.flame)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Score row: plays / discards / score + progress bar inline
            HStack(spacing: 8) {
                Label("\(rogueRun.playsRemaining)", systemImage: "hand.raised.fill")
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(rogueRun.playsRemaining <= 1 ? Theme.danger : Theme.cyan)

                Label("\(rogueRun.discardsRemaining)", systemImage: "arrow.triangle.2.circlepath")
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(rogueRun.discardsRemaining == 0 ? Theme.textDisabled : Theme.success)

                // Inline progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Theme.bgCard)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(progressColor)
                            .frame(width: geo.size.width * rogueRun.floorProgress, height: 6)
                            .animation(.spring(response: 0.4), value: rogueRun.floorProgress)
                    }
                    .frame(height: 6)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                .frame(height: 14)

                // Score
                Text("\(rogueRun.floorScore)")
                    .font(.headline.bold().monospacedDigit())
                    .foregroundColor(Theme.textPrimary)
                Text("/ \(rogueRun.effectiveTargetScore)")
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(Theme.textTertiary)

                // Combo inline
                if rogueRun.combo > 1 {
                    Text("🔥×\(rogueRun.combo)")
                        .font(.caption2.bold())
                        .foregroundColor(Theme.flame)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal)
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
                    SoundManager.shared.play(.cardDiscard)
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

                // Ascension 升级提示
                if rogueRun.ascensionLevel < 10 {
                    Button {
                        rogueRun.ascensionLevel += 1
                        rogueRun.restart()
                        battleScene?.refreshHand()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                            Text(L10n.ascensionChallenge(rogueRun.ascensionLevel + 1))
                        }
                        .font(.headline)
                        .foregroundColor(Theme.flame)
                        .frame(width: 220, height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.radiusMD)
                                .fill(Theme.flameDim)
                                .stroke(Theme.flame.opacity(0.4))
                        )
                    }
                }

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
