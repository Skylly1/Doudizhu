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
    @State private var showNoSelectionHint = false
    /// Progressive hint system
    @State private var contextHint: String? = nil
    @State private var playsUsedThisFloor: Int = 0
    @State private var showExitConfirm = false
    @State private var jokersExpanded = false

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
                Color(red: 0.22, green: 0.16, blue: 0.11).ignoresSafeArea()
            }

            // SwiftUI 覆盖层
            VStack(spacing: 0) {
                topBar
                // 本层出牌记录
                if !rogueRun.playHistory.isEmpty {
                    playHistoryBar
                }
                Spacer()
                scoreTargetBar
                    .padding(.bottom, 6)
                actionButtons
                    .padding(.bottom, 16)
            }
            .padding(.bottom, 0)
            .ignoresSafeArea(edges: .bottom)

            // 过关/失败弹窗
            if rogueRun.phase == .floorWin {
                floorWinOverlay
                    .onAppear {
                        FeedbackManager.shared.floorWin()
                        SoundManager.shared.play(.floorClear)
                        ReviewManager.recordFloorWin()
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

            // Score breakdown popup during scoring phase
            if case .scoring = rogueRun.phase {
                VStack {
                    Spacer()
                    scoreBreakdownView
                        .padding(.bottom, 120)
                }
                .animation(.spring(response: 0.3), value: rogueRun.phase == .selecting)
            }

            // 成就解锁提示
            if let ach = achievementTracker.latestUnlock {
                VStack {
                    HStack(spacing: Theme.spacingSM) {
                        Text(ach.icon)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(Theme.gold)
                                Text(L10n.achievementUnlocked)
                                    .font(Theme.fontCaption)
                                    .foregroundColor(Theme.gold)
                            }
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
            playsUsedThisFloor = 0
            // Show initial hint for new players
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showInitialHint()
            }
        }
        .onChange(of: rogueRun.phase) { _, newPhase in
            if case .scoring(_) = newPhase {
                // Score-up sound (card-play/bomb/combo feedback already in BattleScene)
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
            Button { showExitConfirm = true } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .alert(L10n.exitConfirmTitle, isPresented: $showExitConfirm) {
                Button(L10n.exitConfirmContinue, role: .cancel) { }
                Button(L10n.exitConfirmQuit, role: .destructive) { onBack() }
            } message: {
                Text(L10n.exitConfirmMessage)
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
                        .background(Capsule().fill(.ultraThinMaterial))
                }
                Text(rogueRun.currentFloor.name)
                    .font(Theme.subtitleFont)
                    .foregroundColor(rogueRun.currentFloor.isBoss ? Theme.flame : Theme.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            // 金币
            HStack(spacing: 3) {
                Image(systemName: "circle.circle.fill")
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
                    .font(.title3)
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .sheet(isPresented: $showPatternGuide) {
                PatternGuideView()
            }
        }
        .padding(.horizontal, Theme.spacingSM)
        .padding(.top, 4)
        .padding(.bottom, 4)
        .background(.ultraThinMaterial)
        .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
    }

    // MARK: - 出牌记录

    private var playHistoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Array(rogueRun.playHistory.enumerated()), id: \.offset) { idx, play in
                    VStack(spacing: 1) {
                        Text(play.pattern.type.displayName)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Theme.cyan)
                        Text("+\(play.score)")
                            .font(.system(size: 10, weight: .semibold).monospacedDigit())
                            .foregroundColor(Theme.gold)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(play.isFloorCleared ? Theme.gold.opacity(0.4) : Theme.borderLight, lineWidth: 0.5)
                            )
                    )
                    .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
                }
            }
            .padding(.horizontal, Theme.spacingSM)
        }
        .frame(height: 32)
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
                                Text(mod.name).font(.caption.bold())
                                Text(mod.description).font(.caption)
                            }
                            .foregroundColor(Theme.flame)
                        }
                        if let banned = boss.bannedPatternType {
                            HStack(spacing: 2) {
                                Text("⛔").font(.caption)
                                Text(L10n.bannedPatternLabel(banned.displayName))
                                    .font(.caption.bold())
                                    .foregroundColor(Theme.danger)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                }
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Theme.flame.opacity(0.3))
                        )
                )
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                .padding(.horizontal)
            }

            // Jokers + Buffs — 可折叠条
            if !rogueRun.activeJokers.isEmpty || !rogueRun.activeBuffs.isEmpty {
                VStack(spacing: 0) {
                    // Toggle header
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            jokersExpanded.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "suit.spade.fill")
                                .font(.caption2)
                                .foregroundColor(Theme.cyan)
                            Text("\(rogueRun.activeJokers.count)")
                                .font(.caption2.monospacedDigit())
                                .foregroundColor(Theme.cyan)
                            if !rogueRun.activeBuffs.isEmpty {
                                Text("·")
                                    .foregroundColor(Theme.textTertiary)
                                Image(systemName: "sparkles")
                                    .font(.caption2)
                                    .foregroundColor(Theme.flame)
                                Text("\(rogueRun.activeBuffs.count)")
                                    .font(.caption2.monospacedDigit())
                                    .foregroundColor(Theme.flame)
                            }
                            Image(systemName: jokersExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption2)
                                .foregroundColor(Theme.textTertiary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Theme.bgCard.opacity(0.8)))
                    }

                    if jokersExpanded {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(rogueRun.activeJokers) { joker in
                                    HStack(spacing: 2) {
                                        Text(joker.icon).font(.caption2)
                                        Text(joker.name).font(.caption2)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(.ultraThinMaterial))
                                    .foregroundColor(Theme.cyan)
                                }
                                ForEach(rogueRun.activeBuffs) { buff in
                                    HStack(spacing: 2) {
                                        Text(buff.icon).font(.caption2)
                                        Text(buff.name).font(.caption2)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(.ultraThinMaterial))
                                    .foregroundColor(Theme.flame)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }

            // Score row: plays / discards / score + progress bar inline
            HStack(spacing: 8) {
                Label("\(rogueRun.playsRemaining)", systemImage: "suit.spade.fill")
                    .font(.subheadline.bold().monospacedDigit())
                    .foregroundColor(rogueRun.playsRemaining <= 1 ? Theme.danger : Theme.cyan)

                Label("\(rogueRun.discardsRemaining)", systemImage: "arrow.2.squarepath")
                    .font(.subheadline.bold().monospacedDigit())
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
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusSM)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusSM)
                            .stroke(Theme.gold.opacity(0.12), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
            .padding(.horizontal, Theme.spacingSM)
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
            // Last-play warning
            if rogueRun.playsRemaining == 1 && rogueRun.floorScore < rogueRun.effectiveTargetScore && rogueRun.phase == .selecting {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(L10n.isEnglish ? "Last play! Need \(rogueRun.effectiveTargetScore - rogueRun.floorScore) more" : "最后一次出牌！还差 \(rogueRun.effectiveTargetScore - rogueRun.floorScore) 分")
                }
                .font(.caption.bold())
                .foregroundColor(Theme.danger)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Theme.danger.opacity(0.15)))
                .transition(.scale.combined(with: .opacity))
            }

            // 牌型提示 / 操作提示
            if showNoSelectionHint {
                Text(L10n.selectCardsFirst)
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.gold.opacity(0.9))
                    .transition(.scale.combined(with: .opacity))
            } else if let hint = contextHint {
                Text(hint)
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.gold.opacity(0.8))
                    .transition(.opacity)
            } else if let pattern = selectedPattern {
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
                    Capsule().fill(.ultraThinMaterial)
                        .overlay(Capsule().stroke(Theme.cyan.opacity(0.3)))
                )
                .transition(.scale.combined(with: .opacity))
            } else if let selected = battleScene?.getSelectedCards(), !selected.isEmpty {
                let count = selected.count
                let hint: String = {
                    switch count {
                    case 1: return L10n.isEnglish ? "Play single cards" : "单张可以直接出"
                    case 2: return L10n.isEnglish ? "Need a pair (same rank)" : "需要两张相同点数组成对子"
                    case 3: return L10n.isEnglish ? "Need three of a kind" : "需要三张相同点数"
                    case 4: return L10n.isEnglish ? "Try 3+1, bomb, or extend to straight" : "试试三带一、炸弹，或凑顺子"
                    case 5...: return L10n.isEnglish ? "Try a straight (5+ consecutive)" : "试试顺子（5张以上连续）"
                    default: return L10n.invalidPattern
                    }
                }()
                Text("💡 \(hint)")
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.gold.opacity(0.8))
                    .transition(.opacity)
            }

            HStack(spacing: Theme.spacingMD) {
            // 手牌排序切换
            Button {
                rogueRun.toggleSortMode()
                battleScene?.refreshHand()
                FeedbackManager.shared.cardTap()
            } label: {
                Image(systemName: rogueRun.handSortMode.icon)
                    .font(.body.weight(.medium))
                    .foregroundColor(Theme.gold)
                    .frame(width: 44, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusSM)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.radiusSM)
                                    .stroke(Theme.gold.opacity(0.3), lineWidth: 0.6)
                            )
                    )
                    .shadow(color: .black.opacity(0.18), radius: 5, y: 3)
            }
            .accessibilityLabel(rogueRun.handSortMode.label)
            Button {
                guard let scene = battleScene else { return }
                let selected = scene.getSelectedCards()
                if selected.isEmpty {
                    // Show hint: select cards first
                    withAnimation { showNoSelectionHint = true }
                    FeedbackManager.shared.cardTap()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { showNoSelectionHint = false }
                    }
                    return
                }
                if rogueRun.discardCards(selected) {
                    FeedbackManager.shared.discard()
                    SoundManager.shared.play(.cardDiscard)
                    scene.clearSelection()
                    scene.refreshHand()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(L10n.swap)
                    Text("(\(rogueRun.discardsRemaining))")
                        .font(.caption)
                }
                .font(.body.weight(.medium))
                .foregroundColor(rogueRun.discardsRemaining > 0 ? Theme.textPrimary : Theme.textDisabled)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusSM)
                                .stroke(rogueRun.discardsRemaining > 0 ? Theme.danger.opacity(0.5) : Theme.borderLight, lineWidth: 0.6)
                        )
                )
                .shadow(color: .black.opacity(0.18), radius: 5, y: 3)
                .contentShape(Rectangle())
            }
            .disabled(rogueRun.discardsRemaining <= 0 || rogueRun.phase != .selecting)

            // 出牌按钮
            Button {
                guard let scene = battleScene else { return }
                let selected = scene.getSelectedCards()
                if selected.isEmpty {
                    withAnimation { showNoSelectionHint = true }
                    FeedbackManager.shared.cardTap()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { showNoSelectionHint = false }
                    }
                    return
                }
                scene.playSelectedCards()
                playsUsedThisFloor += 1
                showProgressiveHint()
            } label: {
                HStack(spacing: 4) {
                    Text(L10n.play)
                    Text("(\(rogueRun.playsRemaining))")
                        .font(.caption)
                }
                .font(.body.weight(.semibold))
                .foregroundColor(rogueRun.playsRemaining > 0 ? .black : Theme.textDisabled)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(rogueRun.playsRemaining > 0 ? Theme.gold : Theme.bgInset)
                )
                .shadow(color: rogueRun.playsRemaining > 0 ? Theme.gold.opacity(0.3) : .black.opacity(0.1), radius: 6, y: 3)
                .contentShape(Rectangle())
            }
            .disabled(rogueRun.playsRemaining <= 0 || rogueRun.phase != .selecting)
            }
            .padding(.horizontal, Theme.spacingMD)
        }
    }

    // MARK: - Score Breakdown Popup

    @ViewBuilder
    private var scoreBreakdownView: some View {
        if case .scoring(let result) = rogueRun.phase {
            VStack(spacing: 2) {
                // 牌型名称
                HStack {
                    Text(result.pattern.type.displayName)
                        .font(.caption.bold())
                        .foregroundColor(Theme.cyan)
                    Spacer()
                }
                // chips × mult 核心展示（Balatro 风格）— 使用实际最终值
                HStack(spacing: 4) {
                    Text("\(result.chips)")
                        .font(.caption.bold().monospacedDigit())
                        .foregroundColor(Theme.cyan)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.ultraThinMaterial))
                    Text("×")
                        .font(.caption2)
                        .foregroundColor(Theme.textSecondary)
                    Text(String(format: "%.1f", result.mult))
                        .font(.caption.bold().monospacedDigit())
                        .foregroundColor(Theme.flame)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.ultraThinMaterial))
                    Text("=")
                        .font(.caption2)
                        .foregroundColor(Theme.textSecondary)
                    Text("\(Int(Double(result.chips) * result.mult))")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(Theme.textSecondary)
                }
                let bonus = result.score - result.pattern.baseScore
                if bonus > 0 {
                    HStack {
                        Text(L10n.isEnglish ? "Bonus" : "加成")
                            .font(.caption)
                            .foregroundColor(Theme.gold.opacity(0.8))
                        Spacer()
                        Text("+\(bonus)")
                            .font(.caption.monospacedDigit())
                            .foregroundColor(Theme.gold)
                    }
                } else if bonus < 0 {
                    HStack {
                        Text(L10n.isEnglish ? "Penalty" : "减益")
                            .font(.caption)
                            .foregroundColor(Theme.danger.opacity(0.8))
                        Spacer()
                        Text("\(bonus)")
                            .font(.caption.monospacedDigit())
                            .foregroundColor(Theme.danger)
                    }
                }
                Divider().background(Theme.border)
                HStack {
                    Text(L10n.isEnglish ? "Earned" : "得分")
                        .font(.caption.bold())
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    Text("+\(result.score)")
                        .font(.subheadline.bold().monospacedDigit())
                        .foregroundColor(Theme.gold)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: 220)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.gold.opacity(0.25), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 10, y: 5)
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - 过关弹窗

    private var floorWinOverlay: some View {
        overlayBase {
            VStack(spacing: Theme.spacingLG) {
                Text(L10n.cleared)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Theme.goldGradient)

                Text(rogueRun.currentFloor.name)
                    .font(Theme.subtitleFont)
                    .foregroundColor(Theme.textSecondary)

                VStack(spacing: Theme.spacingSM) {
                    statRow(L10n.floorScoreLabel, value: "\(rogueRun.floorScore)")
                    statRow(L10n.totalScoreLabel, value: "\(rogueRun.totalScore)")
                    let baseGold = rogueRun.currentFloor.targetScore / 10
                    let overScore = max(0, rogueRun.floorScore - rogueRun.effectiveTargetScore)
                    let overBonus = min(baseGold, overScore / 20)
                    statRow(L10n.goldEarned, value: "+\(baseGold)")
                    if overBonus > 0 {
                        statRow(L10n.overscoreBonus, value: "+\(overBonus)")
                    }
                }
                .padding(Theme.spacingMD)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(.ultraThinMaterial)
                )

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
                Text(L10n.failed)
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
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(.ultraThinMaterial)
                )

                // 重试本关按钮
                PrimaryButton(title: L10n.retryFloor, icon: "arrow.counterclockwise") {
                    rogueRun.retryCurrentFloor()
                    battleScene?.refreshHand()
                }
                .frame(width: 220)

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
                Text(L10n.victory)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Theme.goldGradient)

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
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                                        .stroke(Theme.flame.opacity(0.4))
                                )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    }
                }

                // Share button
                Button {
                    let image = ShareManager.generateShareImage(
                        title: L10n.isEnglish ? "Victory!" : "斗破乾坤",
                        score: rogueRun.totalScore,
                        floor: rogueRun.currentFloorIndex + 1,
                        jokerCount: rogueRun.activeJokers.count,
                        ascension: rogueRun.ascensionLevel
                    )
                    let text = L10n.isEnglish
                        ? "I scored \(rogueRun.totalScore) in Dou Po Qian Kun! 🏆"
                        : "我在斗破乾坤中取得了 \(rogueRun.totalScore) 分！🏆"
                    ShareManager.share(image: image, text: text)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text(L10n.isEnglish ? "Share" : "分享战绩")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.cyan)
                    .frame(width: 220, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.radiusMD)
                                    .stroke(Theme.cyan.opacity(0.3))
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
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
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack {
                content()
            }
            .padding(Theme.spacingXL)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusLG)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusLG)
                            .stroke(Theme.gold.opacity(0.2), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.35), radius: 20, y: 8)
            .shadow(color: Theme.gold.opacity(0.1), radius: 30)
            .padding(Theme.spacingXL)
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: rogueRun.phase)
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

    // MARK: - Progressive Hints

    private func showInitialHint() {
        guard contextHint == nil else { return }
        withAnimation {
            contextHint = L10n.hintSelectCards
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation {
                if contextHint == L10n.hintSelectCards { contextHint = nil }
            }
        }
    }

    private func showProgressiveHint() {
        let hint: String?
        switch playsUsedThisFloor {
        case 1:
            hint = rogueRun.discardsRemaining > 0 ? L10n.hintTrySwap : nil
        case 2:
            hint = L10n.hintPairsWorthMore
        case 3:
            hint = rogueRun.combo >= 2 ? L10n.hintComboBonus : nil
        default:
            hint = nil
        }
        guard let hint else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { contextHint = hint }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation { contextHint = nil }
        }
    }
}

#Preview {
    BattleView(rogueRun: RogueRun(), onBack: {}, onShop: {})
}
