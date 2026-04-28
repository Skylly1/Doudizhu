import SwiftUI
import SpriteKit
import Combine

struct BattleView: View {
    let onBack: () -> Void
    @ObservedObject var rogueRun: RogueRun
    let onShop: () -> Void
    var onUpgrade: (() -> Void)?
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
    @State private var showFailExitConfirm = false
    @State private var showRestartConfirm = false
    @State private var showRetryConfirm = false
    @State private var jokersExpanded = false
    @State private var showPauseMenu = false
    @State private var showHelpSheet = false
    @State private var showGestureGuide = false
    @ObservedObject private var hintManager = ContextualHintManager.shared
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true

    private var shouldShowGestureGuide: Bool {
        !UserDefaults.standard.bool(forKey: "gestureGuideCompleted")
    }

    init(rogueRun: RogueRun, onBack: @escaping () -> Void, onShop: @escaping () -> Void, onUpgrade: (() -> Void)? = nil) {
        self.rogueRun = rogueRun
        self.onBack = onBack
        self.onShop = onShop
        self.onUpgrade = onUpgrade
    }

    var body: some View {
        ZStack {
            // SpriteKit 牌桌
            // UX-TODO: SpriteKit scene is not accessible to VoiceOver — consider adding an accessibilityRepresentation overlay for card state
            if let scene = battleScene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                    .accessibilityLabel(L10n.isEnglish ? "Card table" : "牌桌")
            } else {
                Theme.bgPrimary.ignoresSafeArea()
            }

            // SwiftUI 覆盖层
            VStack(spacing: 0) {
                topBar
                // 每日挑战修改器常驻提示
                if let dc = rogueRun.dailyChallenge {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.caption2)
                                .foregroundColor(Theme.gold)
                            ForEach(dc.modifiers, id: \.rawValue) { mod in
                                HStack(spacing: 3) {
                                    Image(systemName: mod.icon)
                                        .font(.caption2)
                                    Text(mod.name)
                                        .font(.caption2.bold())
                                }
                                .foregroundColor(Theme.flame)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                    }
                    .background(Theme.flame.opacity(0.08))
                }
                // 本层出牌记录
                if !rogueRun.playHistory.isEmpty {
                    playHistoryBar
                }
                Spacer()
                scoreTargetBar
                    .padding(.bottom, 4)
                actionButtons
                    .padding(.bottom, 8)
            }
            .padding(.bottom, 0)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }

            // 过关/失败弹窗
            if rogueRun.phase == .floorWin {
                floorWinOverlay
                    .onAppear {
                        FeedbackManager.shared.floorWin()
                        SoundManager.shared.play(.floorClear)
                        ReviewManager.recordFloorWin()
                        battleScene?.playFloorClearCelebration()
                    }
            } else if case .specialEvent(let event) = rogueRun.phase {
                specialEventOverlay(event: event)
                    .onAppear {
                        SoundManager.shared.play(.buttonTap)
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
                        battleScene?.playVictoryCelebration()
                    }
            }

            // 暂停菜单覆盖层
            if showPauseMenu {
                pauseMenuOverlay
            }

            // 上下文智能提示
            ContextualHintOverlay(manager: hintManager)

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
                        Image(systemName: ach.icon)
                            .font(.title2)
                            .foregroundColor(Theme.gold)
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
                .padding(.top, 0)  // 使用系统安全区域（自动适配刘海屏/灵动岛）
                .onAppear {
                    SoundManager.shared.play(.achievementUnlock)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation { achievementTracker.dismissLatest() }
                    }
                }
            }

            // 首次手势引导
            if showGestureGuide {
                GestureGuideOverlay {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showGestureGuide = false
                    }
                }
                .transition(.opacity)
                .zIndex(100)
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
            // Start BGM（Boss 关使用暗调 BGM）
            SoundManager.shared.startBGM(mode: rogueRun.currentFloor.isBoss ? .boss : .battle)
            // Boss 入场音效
            if rogueRun.currentFloor.isBoss {
                SoundManager.shared.play(.bossAppear)
                // Boss 关上下文提示
                if let boss = rogueRun.bossState {
                    let modNames = boss.modifiers.map { $0.name }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        hintManager.onBossFloorEnter(modifierNames: modNames)
                    }
                }
            }
            // Show initial hint for new players
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showInitialHint()
            }
            // 首次手势引导
            if shouldShowGestureGuide {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        showGestureGuide = true
                    }
                }
            }
        }
        .onChange(of: rogueRun.phase) { _, newPhase in
            if case .scoring(let result) = newPhase {
                // Score-up sound (card-play/bomb/combo feedback already in BattleScene)
                SoundManager.shared.play(.scoreUp)

                // allOrNothing 修改器提醒：出牌得 0 分时弹出提示
                if result.score == 0,
                   rogueRun.dailyChallenge?.modifiers.contains(.allOrNothing) == true {
                    let hint = L10n.isEnglish
                        ? "⚡ All or Nothing: Only Bombs & Rockets score!"
                        : "⚡ 孤注一掷：仅炸弹和火箭可得分！"
                    withAnimation { contextHint = hint }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation { if contextHint == hint { contextHint = nil } }
                    }
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

    // MARK: - 顶部信息栏（紧凑单行）

    private var topBar: some View {
        HStack(spacing: 8) {
            // 暂停按钮
            Button { showPauseMenu = true } label: {
                Image(systemName: "pause.circle.fill")
                    .font(.title2)
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .accessibilityLabel("暂停")
            .accessibilityHint("打开暂停菜单")

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
                Image(systemName: "dollarsign.circle.fill")
                    .font(.caption)
                    .foregroundColor(Theme.gold)
                Text("\(rogueRun.gold)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundColor(Theme.gold)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("金币")
            .accessibilityValue("\(rogueRun.gold)")

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
            .accessibilityLabel("牌型参考")
            .accessibilityHint("查看所有牌型说明")
            .sheet(isPresented: $showPatternGuide) {
                PatternGuideView()
            }
            .sheet(isPresented: $showHelpSheet) {
                HelpView(onBack: { showHelpSheet = false })
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
                            .font(Theme.fontMicroBold)
                            .foregroundColor(Theme.cyan)
                        Text("+\(play.score)")
                            .font(Theme.fontSmallMono)
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
                                Image(systemName: mod.systemIcon)
                                    .font(.caption)
                                Text(mod.name).font(.caption.bold())
                            }
                            .foregroundColor(Theme.flame)
                        }
                        if let banned = boss.bannedPatternType {
                            HStack(spacing: 2) {
                                Image(systemName: "nosign")
                                    .font(.caption)
                                    .foregroundColor(Theme.danger)
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
                                        Image(systemName: joker.effect.systemIcon).font(.caption2)
                                        Text(joker.name).font(.caption2)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(.ultraThinMaterial))
                                    .foregroundColor(Theme.cyan)
                                }
                                ForEach(rogueRun.activeBuffs) { buff in
                                    HStack(spacing: 2) {
                                        Image(systemName: buff.type.systemIcon).font(.caption2)
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
                    .accessibilityLabel("剩余出牌次数")
                    .accessibilityValue("\(rogueRun.playsRemaining)")

                Label("\(rogueRun.discardsRemaining)", systemImage: "arrow.2.squarepath")
                    .font(.subheadline.bold().monospacedDigit())
                    .foregroundColor(rogueRun.discardsRemaining == 0 ? Theme.textDisabled : Theme.success)
                    .accessibilityLabel("剩余弃牌次数")
                    .accessibilityValue("\(rogueRun.discardsRemaining)")

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
                    .accessibilityLabel("当前分数")
                    .accessibilityValue("\(rogueRun.floorScore)")
                Text("/ \(rogueRun.effectiveTargetScore)")
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(Theme.textTertiary)
                    .accessibilityLabel("目标分数")
                    .accessibilityValue("\(rogueRun.effectiveTargetScore)")

                // Combo inline
                if rogueRun.combo > 1 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                        Text("×\(rogueRun.combo)")
                    }
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

    /// 出牌按钮颜色：正常=金色，剩余1次=橙色，0次=灰色
    private var playButtonFill: Color {
        if rogueRun.playsRemaining <= 0 { return Theme.bgInset }
        if rogueRun.playsRemaining == 1 && rogueRun.floorScore < rogueRun.effectiveTargetScore {
            return Theme.flame // 紧急红橙色
        }
        return Theme.gold
    }

    /// 弃牌边框颜色：正常=红50%，剩余1次=亮红，0次=灰
    private var discardBorderColor: Color {
        if rogueRun.discardsRemaining <= 0 { return Theme.borderLight }
        if rogueRun.discardsRemaining == 1 { return Theme.danger.opacity(0.8) }
        return Theme.danger.opacity(0.5)
    }

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
                VStack(spacing: 4) {
                    patternPreviewCapsule(pattern)
                    // 下方小字提示活跃的 Joker
                    if !rogueRun.activeJokers.isEmpty {
                        let jokerNames = rogueRun.activeJokers.prefix(3).map { "🃏 " + $0.name }.joined(separator: " · ")
                        Text(jokerNames)
                            .font(Theme.fontSmall)
                            .foregroundColor(Theme.gold.opacity(0.6))
                    }
                }
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
                HStack(spacing: 4) {
                    Image(systemName: selected.count >= 3 ? "xmark.circle.fill" : "lightbulb.fill")
                        .font(.caption2)
                        .foregroundColor(selected.count >= 3 ? Theme.danger : Theme.gold)
                    Text(hint)
                }
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.gold.opacity(0.8))
                    .transition(.opacity)
            }

            HStack(spacing: Theme.spacingMD) {
            Button {
                guard let scene = battleScene else { return }
                let selected = scene.getSelectedCards()
                if selected.isEmpty {
                    // 首次点换牌时先弹出说明
                    if !UserDefaults.standard.bool(forKey: "ctxHint_first_swap") {
                        hintManager.onFirstSwap()
                        return
                    }
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
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusMD)
                                .stroke(discardBorderColor, lineWidth: 0.6)
                        )
                )
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                .contentShape(Rectangle())
            }
            .disabled(rogueRun.discardsRemaining <= 0 || rogueRun.phase != .selecting)
            .accessibilityLabel("弃牌")
            .accessibilityHint("弃掉选中的牌并抽新牌")
            .accessibilityValue("剩余\(rogueRun.discardsRemaining)次")

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
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .fill(playButtonFill)
                )

                .shadow(color: rogueRun.playsRemaining > 0 ? Theme.gold.opacity(0.25) : .black.opacity(0.08), radius: 4, y: 2)
                .contentShape(Rectangle())
            }
            .disabled(rogueRun.playsRemaining <= 0 || rogueRun.phase != .selecting)
            .accessibilityLabel("出牌")
            .accessibilityHint("打出选中的牌型得分")
            .accessibilityValue("剩余\(rogueRun.playsRemaining)次")
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
                .frame(maxWidth: 280)

                SecondaryButton(
                    title: L10n.isEnglish ? "Save & Quit" : "暂离保存",
                    icon: "rectangle.portrait.and.arrow.right"
                ) {
                    SaveManager.shared.save(run: rogueRun, buildId: "")
                    SoundManager.shared.stopBGM()
                    onBack()
                }
                .frame(maxWidth: 280)
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
                    let gap = rogueRun.effectiveTargetScore - rogueRun.floorScore
                    if gap > 0 {
                        statRow(L10n.isEnglish ? "Gap" : "差距", value: "-\(gap)")
                    }
                    statRow(L10n.totalScoreLabel, value: "\(rogueRun.totalScore)")
                    statRow(L10n.isEnglish ? "Cards Played" : "出牌数", value: "\(rogueRun.playHistory.count)")
                    if let bestPlay = rogueRun.playHistory.max(by: { $0.score < $1.score }) {
                        statRow(L10n.isEnglish ? "Best Hand" : "最佳一手", value: "\(bestPlay.score)")
                    }
                    statRow(L10n.isEnglish ? "Best Combo" : "最高连击", value: "×\(rogueRun.playHistory.map(\.combo).max() ?? 0)")
                }
                .padding(Theme.spacingMD)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(.ultraThinMaterial)
                )

                // 免费用户玩过2局以上 → 价值导向付费提示（验证好玩后推）
                if !PurchaseManager.shared.isFullVersion && PlayerStats.shared.totalRuns >= 2, let onUpgrade = onUpgrade {
                    let totalFloors = FloorConfig.allFloors.count
                    let lockedFloors = totalFloors - PurchaseManager.demoMaxFloor
                    Button {
                        Analytics.shared.track(.paywallShown, params: ["source": "post_game_nudge", "runs": "\(PlayerStats.shared.totalRuns)"])
                        onUpgrade()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(Theme.gold)
                                .font(.body)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(L10n.isEnglish
                                     ? "Enjoying the game? There's so much more!"
                                     : "玩得开心？还有更多精彩！")
                                    .font(.caption.bold())
                                    .foregroundColor(Theme.textPrimary)
                                Text(L10n.isEnglish
                                     ? "\(lockedFloors) more floors · Rare Jokers · Endless mode"
                                     : "还有\(lockedFloors)层关卡 · 稀有丑角 · 无尽模式")
                                    .font(Theme.fontSmall)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            Spacer()
                            Text(L10n.isEnglish ? "See More" : "了解更多")
                                .font(.caption2.bold())
                                .foregroundColor(Theme.gold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(Theme.gold.opacity(0.15)))
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.radiusMD)
                                .fill(Theme.gold.opacity(0.06))
                                .overlay(RoundedRectangle(cornerRadius: Theme.radiusMD)
                                    .stroke(Theme.gold.opacity(0.18)))
                        )
                    }
                    .frame(maxWidth: 280)
                }

                // 重试本关按钮
                PrimaryButton(title: L10n.retryFloor, icon: "arrow.counterclockwise") {
                    rogueRun.retryCurrentFloor()
                    battleScene?.refreshHand()
                }
                .frame(maxWidth: 280)

                Button(L10n.restart) {
                    showRestartConfirm = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 220, height: 50)
                .background(RoundedRectangle(cornerRadius: Theme.radiusMD).fill(Theme.danger))
                .buttonStyle(GameButtonStyle())
                .alert(
                    L10n.isEnglish ? "Restart Run?" : "重新开始？",
                    isPresented: $showRestartConfirm
                ) {
                    Button(L10n.cancel, role: .cancel) { }
                    Button(L10n.restart, role: .destructive) {
                        rogueRun.restart()
                        battleScene?.refreshHand()
                    }
                } message: {
                    Text(L10n.isEnglish
                         ? "Current run progress will be lost. Start a fresh run from Floor 1."
                         : "当前冒险进度将丢失，从第1层重新开始。")
                }

                SecondaryButton(title: L10n.backToMenu, icon: "house") {
                    showFailExitConfirm = true
                }
                .alert(
                    L10n.isEnglish ? "Back to Menu?" : "返回主菜单？",
                    isPresented: $showFailExitConfirm
                ) {
                    Button(L10n.cancel, role: .cancel) { }
                    Button(L10n.isEnglish ? "Save & Quit" : "保存并退出", role: .none) {
                        SaveManager.shared.save(run: rogueRun, buildId: "")
                        SoundManager.shared.stopBGM()
                        onBack()
                    }
                    Button(L10n.isEnglish ? "Quit without saving" : "不保存退出", role: .destructive) {
                        rogueRun.clearSave()
                        SoundManager.shared.stopBGM()
                        onBack()
                    }
                } message: {
                    Text(L10n.isEnglish
                         ? "Save your run to retry later, or quit without saving."
                         : "保存后可以下次继续重试，不保存将丢失本局进度。")
                }
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

                // 战绩统计
                VStack(spacing: Theme.spacingSM) {
                    statRow(L10n.isEnglish ? "Floors Cleared" : "通过层数", value: "\(rogueRun.currentFloorIndex + 1)")
                    statRow(L10n.isEnglish ? "Cards Played" : "出牌总数", value: "\(rogueRun.playHistory.count)")
                    if let best = rogueRun.playHistory.max(by: { $0.score < $1.score }) {
                        statRow(L10n.isEnglish ? "Best Hand" : "最佳一手", value: "\(best.score)")
                    }
                    statRow(L10n.isEnglish ? "Jokers" : "规则牌", value: "\(rogueRun.activeJokers.count)")
                    statRow(L10n.isEnglish ? "Gold Remaining" : "剩余金币", value: "\(rogueRun.gold)")
                }
                .padding(Theme.spacingMD)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(.ultraThinMaterial)
                )

                PrimaryButton(title: L10n.playAgain, icon: "arrow.clockwise") {
                    rogueRun.restart()
                    battleScene?.refreshHand()
                }
                .frame(maxWidth: 280)
                .accessibilityLabel(L10n.playAgain)

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
                    .buttonStyle(GameButtonStyle())
                    .accessibilityLabel(L10n.ascensionChallenge(rogueRun.ascensionLevel + 1))
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
                .buttonStyle(GameButtonStyle())
                .accessibilityLabel(L10n.isEnglish ? "Share" : "分享战绩")

                SecondaryButton(title: L10n.backToMenu, icon: "house") {
                    SoundManager.shared.stopBGM()
                    onBack()
                }
            }
        }
    }

    // MARK: - Special Event Overlay

    private func specialEventOverlay(event: SpecialEvent) -> some View {
        overlayBase {
            VStack(spacing: Theme.spacingLG) {
                Image(systemName: event.icon)
                    .font(Theme.fontStatNumber)
                    .foregroundStyle(Theme.goldGradient)
                    .shadow(color: Theme.gold.opacity(0.4), radius: 8)

                Text(event.title)
                    .font(.title2.bold())
                    .foregroundColor(Theme.textPrimary)

                Text(event.description)
                    .font(Theme.fontBody)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: Theme.spacingSM) {
                    ForEach(event.choices) { choice in
                        Button {
                            FeedbackManager.shared.buttonTap()
                            SoundManager.shared.play(.buttonTap)
                            rogueRun.applyEventChoice(choice)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: choice.icon)
                                    .font(.title3)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(choice.label)
                                        .font(.headline)
                                        .foregroundColor(Theme.textPrimary)
                                    Text(choice.description)
                                        .font(Theme.fontCaption)
                                        .foregroundColor(Theme.textTertiary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Theme.textTertiary)
                            }
                            .padding(Theme.spacingMD)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.radiusSM)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.radiusSM)
                                            .stroke(Theme.gold.opacity(0.2))
                                    )
                            )
                        }
                    }
                    if event.choices.isEmpty {
                        Button {
                            FeedbackManager.shared.buttonTap()
                            SoundManager.shared.play(.buttonTap)
                            rogueRun.skipSpecialEvent()
                        } label: {
                            Text(L10n.isEnglish ? "Skip" : "跳过")
                                .font(.headline)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }
                .frame(maxWidth: 280)
            }
        }
    }

    // MARK: - Pattern Preview

    @ViewBuilder
    private func patternPreviewCapsule(_ pattern: CardPattern) -> some View {
        HStack(spacing: 6) {
            // 牌型名
            Text(pattern.type.displayName)
                .font(.subheadline.bold())
                .foregroundColor(Theme.cyan)

            // chips × mult = total 拆解
            HStack(spacing: 3) {
                Text("\(pattern.baseChips)")
                    .font(.caption.bold().monospacedDigit())
                    .foregroundColor(Theme.cyan)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Theme.cyan.opacity(0.15)))

                Text("×")
                    .font(.caption2)
                    .foregroundColor(Theme.textTertiary)

                Text(String(format: "%.1f", pattern.baseMult))
                    .font(.caption.bold().monospacedDigit())
                    .foregroundColor(Theme.flame)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Theme.flame.opacity(0.15)))

                Text("=")
                    .font(.caption2)
                    .foregroundColor(Theme.textTertiary)

                Text("\(pattern.baseScore)")
                    .font(.caption.bold().monospacedDigit())
                    .foregroundColor(Theme.gold)
            }
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(Theme.cyan.opacity(0.3)))
        )
    }

    // MARK: - Helpers

    private func overlayBase<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        let innerContent = content()
        return ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        innerContent
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
                    .frame(maxWidth: 500)
                    .padding(Theme.spacingXL)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geo.size.height)
                }
            }
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

    // MARK: - 暂停菜单

    private var pauseMenuOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { showPauseMenu = false }

            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    pauseMenuContent
                        .frame(maxWidth: 500)
                        .padding(Theme.spacingXL)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: geo.size.height)
                }
            }
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: showPauseMenu)
    }

    private var pauseMenuContent: some View {
            VStack(spacing: Theme.spacingLG) {
                Text(L10n.isEnglish ? "Paused" : "已暂停")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Theme.goldGradient)

                // 当前进度信息
                VStack(spacing: Theme.spacingSM) {
                    statRow(L10n.floorNumber(rogueRun.currentFloorIndex + 1),
                            value: rogueRun.currentFloor.name)
                    statRow(L10n.isEnglish ? "Score" : "得分",
                            value: "\(rogueRun.floorScore) / \(rogueRun.effectiveTargetScore)")
                    statRow(L10n.isEnglish ? "Gold" : "金币",
                            value: "\(rogueRun.gold)")
                }
                .padding(Theme.spacingMD)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(.ultraThinMaterial)
                )

                // 继续
                PrimaryButton(
                    title: L10n.isEnglish ? "Resume" : "继续游戏",
                    icon: "play.fill"
                ) {
                    showPauseMenu = false
                }
                .frame(maxWidth: 280)

                // 重试本关（需二次确认，因为会丢失本层进度）
                SecondaryButton(
                    title: L10n.retryFloor,
                    icon: "arrow.counterclockwise"
                ) {
                    showRetryConfirm = true
                }
                .frame(maxWidth: 280)
                .alert(
                    L10n.isEnglish ? "Retry Floor?" : "重试本关？",
                    isPresented: $showRetryConfirm
                ) {
                    Button(L10n.cancel, role: .cancel) { }
                    Button(L10n.isEnglish ? "Retry" : "重试", role: .destructive) {
                        showPauseMenu = false
                        rogueRun.retryCurrentFloor()
                        battleScene?.refreshHand()
                    }
                } message: {
                    Text(L10n.isEnglish
                         ? "Your progress on this floor will be reset."
                         : "本层进度将被重置。")
                }

                // 内联设置面板
                VStack(spacing: Theme.spacingSM) {
                    HStack {
                        Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .foregroundColor(soundEnabled ? Theme.gold : Theme.textDisabled)
                            .frame(width: 24)
                        Text(L10n.isEnglish ? "Sound" : "音效")
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                        Toggle("", isOn: $soundEnabled)
                            .labelsHidden()
                            .tint(Theme.gold)
                    }
                    HStack {
                        Image(systemName: musicEnabled ? "music.note" : "music.note.slash")
                            .foregroundColor(musicEnabled ? Theme.gold : Theme.textDisabled)
                            .frame(width: 24)
                        Text(L10n.isEnglish ? "Music" : "音乐")
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                        Toggle("", isOn: $musicEnabled)
                            .labelsHidden()
                            .tint(Theme.gold)
                    }
                    .onChange(of: musicEnabled) { _, newValue in
                        if newValue {
                            SoundManager.shared.startBGM()
                        } else {
                            SoundManager.shared.stopBGM()
                        }
                    }
                    HStack {
                        Image(systemName: hapticEnabled ? "hand.tap.fill" : "hand.raised.slash.fill")
                            .foregroundColor(hapticEnabled ? Theme.gold : Theme.textDisabled)
                            .frame(width: 24)
                        Text(L10n.isEnglish ? "Haptics" : "震动")
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                        Toggle("", isOn: $hapticEnabled)
                            .labelsHidden()
                            .tint(Theme.gold)
                    }
                }
                .padding(Theme.spacingMD)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusSM)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusSM)
                                .stroke(Theme.border)
                        )
                )
                .frame(maxWidth: 280)

                // 手牌排序
                Button {
                    rogueRun.toggleSortMode()
                    battleScene?.refreshHand()
                    FeedbackManager.shared.cardTap()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: rogueRun.handSortMode.icon)
                        Text(rogueRun.handSortMode == .byRank
                             ? (L10n.isEnglish ? "Sort by Suit" : "按花色排列")
                             : (L10n.isEnglish ? "Sort by Rank" : "按点数排列"))
                    }
                    .font(.headline)
                    .foregroundColor(Theme.gold)
                    .frame(width: 220, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.radiusMD)
                                    .stroke(Theme.gold.opacity(0.3))
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                }
                .buttonStyle(GameButtonStyle())
                .accessibilityLabel(rogueRun.handSortMode == .byRank
                    ? (L10n.isEnglish ? "Sort by Suit" : "按花色排列")
                    : (L10n.isEnglish ? "Sort by Rank" : "按点数排列"))

                // 游戏指南
                Button {
                    showPauseMenu = false
                    showPatternGuide = true
                    Analytics.shared.track(.guideOpened, params: ["source": "pause_menu"])
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                        Text(L10n.gameGuide)
                    }
                    .font(.headline)
                    .foregroundColor(Theme.cyan)
                    .frame(width: 220, height: 46)
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
                .buttonStyle(GameButtonStyle())
                .accessibilityLabel(L10n.gameGuide)

                // 帮助与FAQ
                Button {
                    showPauseMenu = false
                    showHelpSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "questionmark.circle.fill")
                        Text(L10n.helpAndFaq)
                    }
                    .font(.headline)
                    .foregroundColor(Theme.textSecondary)
                    .frame(width: 220, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.radiusMD)
                                    .stroke(Theme.textTertiary.opacity(0.3))
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                }
                .buttonStyle(GameButtonStyle())
                .accessibilityLabel(L10n.helpAndFaq)

                // 暂离保存（保留存档回主菜单）
                Button {
                    showPauseMenu = false
                    // 自动存档已由 autoSave 和 scenePhase 处理
                    SaveManager.shared.save(run: rogueRun, buildId: "")
                    SoundManager.shared.stopBGM()
                    onBack()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text(L10n.isEnglish ? "Save & Quit" : "暂离保存")
                    }
                    .font(.headline)
                    .foregroundColor(Theme.textSecondary)
                    .frame(width: 220, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.radiusMD)
                                    .stroke(Theme.textTertiary.opacity(0.3))
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                }
                .buttonStyle(GameButtonStyle())
                .accessibilityLabel(L10n.isEnglish ? "Save & Quit" : "暂离保存")

                // 放弃冒险（删档，需二次确认）
                Button {
                    showExitConfirm = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                        Text(L10n.isEnglish ? "Abandon Run" : "放弃冒险")
                    }
                    .font(.headline)
                    .foregroundColor(Theme.danger.opacity(0.7))
                    .frame(width: 220, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.radiusMD)
                                    .stroke(Theme.danger.opacity(0.2))
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                }
                .buttonStyle(GameButtonStyle())
                .accessibilityLabel(L10n.isEnglish ? "Abandon Run" : "放弃冒险")
                .alert(
                    L10n.isEnglish ? "Abandon Run?" : "确认放弃？",
                    isPresented: $showExitConfirm
                ) {
                    Button(L10n.cancel, role: .cancel) { }
                    Button(L10n.isEnglish ? "Abandon" : "放弃", role: .destructive) {
                        showPauseMenu = false
                        rogueRun.clearSave()
                        SoundManager.shared.stopBGM()
                        onBack()
                    }
                } message: {
                    Text(L10n.isEnglish
                         ? "All progress in this run will be lost."
                         : "本局所有进度将丢失，无法恢复。")
                }
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

        // 卡关策略提示：分数<目标50%且剩余出牌≤1
        if hint == nil && rogueRun.playsRemaining <= 1 {
            let progress = rogueRun.floorProgress
            if progress < 0.5 {
                let stuckHints = [L10n.stuckHintBomb, L10n.stuckHintStraight, L10n.stuckHintCombo]
                let stuckHint = rogueRun.discardsRemaining > 0 ? L10n.stuckHintSwap : stuckHints.randomElement()
                Analytics.shared.track(.stuckHintShown, params: ["progress": String(format: "%.0f%%", progress * 100)])
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation { contextHint = stuckHint }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    withAnimation { contextHint = nil }
                }
                return
            }
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
