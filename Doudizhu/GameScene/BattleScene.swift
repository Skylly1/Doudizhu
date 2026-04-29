import SpriteKit
import Combine

/// 牌桌 SpriteKit 场景
class BattleScene: SKScene {
    var rogueRun: RogueRun?

    private var cardNodes: [CardNode] = []
    private var selectedCards: Set<UUID> = []
    private var playedAreaNode: SKNode = SKNode()

    /// Incremented on every selection change so SwiftUI can react
    let selectionChanged = PassthroughSubject<Void, Never>()

    // 布局常量（基准值，实际会根据手牌数动态缩放）
    private let baseCardWidth: CGFloat = 72
    private let baseCardHeight: CGFloat = 104
    private let cardOverlap: CGFloat = 34

    override func willMove(from view: SKView) {
        removeAllActions()
        removeAllChildren()
        cardNodes.removeAll()
        selectedCards.removeAll()
    }

    override func didMove(to view: SKView) {
        // 暖棕底色 — 大幅提亮，OLED 可见
        backgroundColor = SKColor(red: 0.22, green: 0.16, blue: 0.11, alpha: 1.0)

        // 内存警告时清除卡牌纹理缓存
        NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: .main) { _ in
            CardNode.clearCache()
        }

        // 顶部暖光渐变层
        let bgGrad = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.5))
        bgGrad.fillColor = SKColor(red: 0.30, green: 0.22, blue: 0.15, alpha: 0.40)
        bgGrad.strokeColor = .clear
        bgGrad.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        bgGrad.zPosition = -100
        bgGrad.alpha = 0.7
        addChild(bgGrad)

        // 出牌区域
        playedAreaNode.position = CGPoint(x: size.width / 2, y: size.height * 0.52)
        addChild(playedAreaNode)

        // 桌面装饰
        drawTableDecor()

        layoutHand()
    }

    private func drawTableDecor() {
        // 外层木质桌框（暖色大椭圆）
        let tableFrame = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.82, height: size.height * 0.38))
        tableFrame.fillColor = SKColor(red: 0.24, green: 0.17, blue: 0.11, alpha: 0.5)
        tableFrame.strokeColor = SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 0.18)
        tableFrame.lineWidth = 2
        tableFrame.position = CGPoint(x: size.width / 2, y: size.height * 0.54)
        tableFrame.zPosition = -12
        addChild(tableFrame)

        // 内层毡布面 — 深墨绿（更可见）
        let table = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.72, height: size.height * 0.30))
        table.fillColor = SKColor(red: 0.08, green: 0.18, blue: 0.12, alpha: 0.75)
        table.strokeColor = SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 0.25)
        table.lineWidth = 1.5
        table.position = CGPoint(x: size.width / 2, y: size.height * 0.54)
        table.zPosition = -10
        addChild(table)

        // 中央出牌区域 — 金色双圆
        let circle = SKShapeNode(circleOfRadius: 50)
        circle.fillColor = SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 0.06)
        circle.strokeColor = SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 0.22)
        circle.lineWidth = 1.5
        circle.position = CGPoint(x: size.width / 2, y: size.height * 0.54)
        circle.zPosition = -5
        addChild(circle)

        let outerCircle = SKShapeNode(circleOfRadius: 65)
        outerCircle.fillColor = .clear
        outerCircle.strokeColor = SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 0.08)
        outerCircle.lineWidth = 1
        outerCircle.position = circle.position
        outerCircle.zPosition = -5
        addChild(outerCircle)

        // 四角金色回纹装饰
        for (dx, dy) in [(-1.0, 1.0), (1.0, 1.0), (-1.0, -1.0), (1.0, -1.0)] {
            let corner = SKShapeNode()
            let path = CGMutablePath()
            let cx = size.width / 2 + dx * size.width * 0.38
            let cy = size.height * 0.54 + dy * size.height * 0.17
            let len: CGFloat = 12
            path.move(to: CGPoint(x: cx - dx * len, y: cy))
            path.addLine(to: CGPoint(x: cx, y: cy))
            path.addLine(to: CGPoint(x: cx, y: cy - dy * len))
            corner.path = path
            corner.strokeColor = SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 0.15)
            corner.lineWidth = 1.5
            corner.fillColor = .clear
            corner.zPosition = -10
            addChild(corner)
        }

        // Subtle felt texture — concentric dashed ellipses
        let feltCenter = CGPoint(x: size.width / 2, y: size.height * 0.54)
        let feltScales: [(w: CGFloat, h: CGFloat, alpha: CGFloat)] = [
            (0.60, 0.24, 0.06),
            (0.48, 0.19, 0.07),
            (0.34, 0.13, 0.05)
        ]
        for spec in feltScales {
            let ellipseW = size.width * spec.w
            let ellipseH = size.height * spec.h
            let feltPath = CGMutablePath()
            feltPath.addEllipse(in: CGRect(x: -ellipseW / 2, y: -ellipseH / 2,
                                           width: ellipseW, height: ellipseH))
            let feltRing = SKShapeNode(path: feltPath.copy(dashingWithPhase: 0,
                                                           lengths: [4, 6]))
            feltRing.strokeColor = SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: spec.alpha)
            feltRing.lineWidth = 0.5
            feltRing.fillColor = .clear
            feltRing.position = feltCenter
            feltRing.zPosition = -9
            addChild(feltRing)
        }
    }

    /// 排列手牌 — 扇形布局，动态缩放卡牌尺寸
    func layoutHand() {
        guard let cards = rogueRun?.handCards, !cards.isEmpty else {
            cardNodes.forEach { $0.removeFromParent() }
            cardNodes.removeAll()
            selectedCards.removeAll()
            return
        }

        let count = cards.count

        // Dynamic card sizing: smoother curve, higher minimum for readability
        let scaleFactor: CGFloat
        if count <= 8 {
            scaleFactor = 1.0
        } else {
            scaleFactor = max(0.70, 1.0 - CGFloat(count - 8) * 0.04)
        }
        let cardWidth = baseCardWidth * scaleFactor
        let cardHeight = baseCardHeight * scaleFactor

        // 动态计算 overlap 确保不超出屏幕
        let maxWidth = size.width - 24
        let idealOverlap = cardOverlap * scaleFactor
        let overlap = min(idealOverlap, (maxWidth - cardWidth) / CGFloat(max(count - 1, 1)))
        let totalWidth = CGFloat(count - 1) * overlap + cardWidth
        let startX = (size.width - totalWidth) / 2 + cardWidth / 2
        // Adaptive baseY: reserve proportional space for SwiftUI bottom overlay
        let bottomReserve = size.height * 0.22
        let baseY = bottomReserve + cardHeight / 2 + 8

        // 扇形弧度参数 — 更动感的弧线
        let maxAngle: CGFloat = count > 5 ? 0.032 : 0.018
        let arcHeight: CGFloat = count > 5 ? 12 : 5

        // PERF-02: Incremental update — only add/remove changed cards
        let currentCardIds = Set(cards.map { $0.id })
        let existingCardIds = Set(cardNodes.map { $0.card.id })

        // Remove cards no longer in hand
        cardNodes.removeAll { node in
            if !currentCardIds.contains(node.card.id) {
                node.removeFromParent()
                return true
            }
            return false
        }
        selectedCards = selectedCards.filter { currentCardIds.contains($0) }

        // Create map of existing nodes
        var nodeMap: [UUID: CardNode] = [:]
        for node in cardNodes { nodeMap[node.card.id] = node }

        // Rebuild cardNodes array in correct order, creating new nodes as needed
        var newCardNodes: [CardNode] = []
        for (index, card) in cards.enumerated() {
            let node: CardNode
            let isNewNode: Bool
            if let existing = nodeMap[card.id] {
                node = existing
                isNewNode = false
            } else {
                // New card — create with entrance animation
                node = CardNode(card: card, size: CGSize(width: cardWidth, height: cardHeight))
                node.alpha = 0
                addChild(node)
                isNewNode = true
            }

            // Calculate target position
            let progress = count > 1 ? CGFloat(index) / CGFloat(count - 1) : 0.5
            let centered = progress - 0.5
            let arcY = -arcHeight * (centered * centered * 4)
            let rotation = -centered * maxAngle * CGFloat(count)
            let targetPos = CGPoint(x: startX + CGFloat(index) * overlap, y: baseY + arcY)

            // Animate to new position (slower for new cards, fast for repositioning)
            let duration: TimeInterval = isNewNode ? 0.35 : 0.15
            node.run(SKAction.group([
                SKAction.move(to: targetPos, duration: duration),
                SKAction.rotate(toAngle: rotation, duration: duration),
                SKAction.fadeIn(withDuration: 0.2)
            ]))
            node.zPosition = CGFloat(index)

            newCardNodes.append(node)
        }
        cardNodes = newCardNodes

        // phantomCards: 幻影牌半透明 + 问号标记
        if let boss = rogueRun?.bossState {
            for node in cardNodes where boss.phantomCardIds.contains(node.card.id) {
                node.alpha = 0.5
                if node.childNode(withName: "phantomMark") == nil {
                    let phantom = SKLabelNode(text: "?")
                    phantom.fontName = Theme.spriteKitSerifFontName
                    phantom.fontSize = node.size.width * 0.4
                    phantom.fontColor = SKColor(red: 0.82, green: 0.22, blue: 0.18, alpha: 0.8)
                    phantom.verticalAlignmentMode = .center
                    phantom.zPosition = 10
                    phantom.name = "phantomMark"
                    node.addChild(phantom)
                }
            }
        }
    }

    // MARK: - 公开接口

    func refreshHand() {
        // 清除出牌区
        playedAreaNode.removeAllChildren()
        layoutHand()
    }

    func getSelectedCards() -> [Card] {
        cardNodes
            .filter { selectedCards.contains($0.card.id) }
            .map(\.card)
    }

    func clearSelection() {
        for node in cardNodes where selectedCards.contains(node.card.id) {
            node.deselect()
        }
        selectedCards.removeAll()
        selectionChanged.send()
    }

    /// 出牌
    func playSelectedCards() {
        let selectedCardList = getSelectedCards()
        guard !selectedCardList.isEmpty else { return }

        guard let result = rogueRun?.playCards(selectedCardList) else {
            shakeSelected()
            return
        }

        Analytics.shared.track(.cardPlay, params: ["pattern": result.pattern.type.displayName, "score": "\(result.score)"])

        // 触觉 + 音效反馈
        Task { @MainActor in
            FeedbackManager.shared.playCards(score: result.score)
            SoundManager.shared.play(.cardPlay)
            if result.pattern.type == .bomb {
                FeedbackManager.shared.explosion()
                SoundManager.shared.play(.bombExplosion)
            }
            if result.pattern.type == .rocket {
                FeedbackManager.shared.explosion()
                SoundManager.shared.play(.rocketLaunch)
            }
            if result.combo > 1 {
                FeedbackManager.shared.comboHit(level: result.combo)
                SoundManager.shared.play(.comboHit(level: result.combo))
            }
        }

        // 出牌动画：选中的牌飞到中央
        showPlayedCards(selectedCardList, pattern: result.pattern)

        // 显示得分
        showScorePopup(result)

        // 移除已出的牌节点 — 增强飞行动画
        let playedIds = selectedCards
        cardNodes.filter { playedIds.contains($0.card.id) }.forEach { node in
            // Remove highlight immediately
            node.childNode(withName: "highlight")?.removeFromParent()
            
            let flyTo = CGPoint(x: size.width / 2, y: size.height * 0.52)
            let move = SKAction.move(to: flyTo, duration: 0.22)
            move.timingMode = .easeIn
            let scale = SKAction.scale(to: 0.6, duration: 0.22)
            let spin = SKAction.rotate(byAngle: .pi * 0.15, duration: 0.22)
            let fadeHalf = SKAction.fadeAlpha(to: 0.7, duration: 0.22)
            
            node.run(SKAction.sequence([
                SKAction.group([move, scale, spin, fadeHalf]),
                SKAction.group([
                    SKAction.scale(to: 0.1, duration: 0.1),
                    SKAction.fadeOut(withDuration: 0.1)
                ]),
                .removeFromParent()
            ]))
        }
        cardNodes.removeAll { playedIds.contains($0.card.id) }
        selectedCards.removeAll()
    }

    // MARK: - 触摸交互（手势引擎）

    // --- 手势跟踪状态 ---
    private var touchStartPoint: CGPoint?
    private var touchStartTime: TimeInterval = 0
    private var isSwipeSelecting = false
    private var swipeTouchedCardIds: Set<UUID> = []
    private var swipeSelectMode: Bool? = nil  // true = selecting, false = deselecting, nil = not started
    private var lastTapTime: TimeInterval = 0
    private var lastTapCardId: UUID?

    // 阈值常量
    private let doubleTapInterval: TimeInterval = 0.35
    private let swipeSelectThreshold: CGFloat = 15   // 横向移动超过此值进入横滑模式
    private let swipeActionThreshold: CGFloat = 50    // 上/下滑触发出牌/弃牌
    private let tapDistanceThreshold: CGFloat = 12    // 小于此距离视为点击

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard rogueRun?.phase == .selecting else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let now = touch.timestamp

        // 双击检测
        if let lastId = lastTapCardId,
           now - lastTapTime < doubleTapInterval,
           let node = cardNodes.reversed().first(where: { $0.frame.contains(location) }),
           node.card.id == lastId {
            handleDoubleTap(node)
            lastTapCardId = nil
            touchStartPoint = nil
            return
        }

        touchStartPoint = location
        touchStartTime = now
        isSwipeSelecting = false
        swipeTouchedCardIds.removeAll()
        swipeSelectMode = nil
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard rogueRun?.phase == .selecting else { return }
        guard let touch = touches.first, let startPoint = touchStartPoint else { return }
        let location = touch.location(in: self)
        let dx = location.x - startPoint.x
        let dy = location.y - startPoint.y

        // 判断是否进入横滑选牌模式
        if !isSwipeSelecting && abs(dx) > swipeSelectThreshold && abs(dx) > abs(dy) * 2 {
            isSwipeSelecting = true
        }

        guard isSwipeSelecting else { return }

        // 横滑经过的牌 → 逐张选中/取消
        for node in cardNodes {
            let cardId = node.card.id
            guard !swipeTouchedCardIds.contains(cardId) else { continue }

            // 使用更宽松的碰撞检测（横向扩展）
            let expandedFrame = node.frame.insetBy(dx: -4, dy: -8)
            guard expandedFrame.contains(location) else { continue }

            // 幻影牌跳过
            if let boss = rogueRun?.bossState, boss.phantomCardIds.contains(cardId) { continue }

            swipeTouchedCardIds.insert(cardId)

            // 首张牌决定模式：已选→取消模式，未选→选中模式
            if swipeSelectMode == nil {
                swipeSelectMode = !selectedCards.contains(cardId)
            }

            let shouldSelect = swipeSelectMode ?? true
            if shouldSelect && !selectedCards.contains(cardId) {
                selectedCards.insert(cardId)
                node.select()
                Task { @MainActor in
                    FeedbackManager.shared.cardTap()
                }
            } else if !shouldSelect && selectedCards.contains(cardId) {
                selectedCards.remove(cardId)
                node.deselect()
                Task { @MainActor in
                    FeedbackManager.shared.cardTap()
                }
            }
            selectionChanged.send()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard rogueRun?.phase == .selecting else { return }
        guard let touch = touches.first, let startPoint = touchStartPoint else {
            touchStartPoint = nil
            return
        }
        let location = touch.location(in: self)
        let dx = location.x - startPoint.x
        let dy = location.y - startPoint.y
        let distance = hypot(dx, dy)

        defer { touchStartPoint = nil }

        // 横滑选牌模式 — 已在 touchesMoved 处理完，直接返回
        if isSwipeSelecting { return }

        // 上滑出牌（SpriteKit y轴向上）
        if dy > swipeActionThreshold && abs(dy) > abs(dx) * 1.5 {
            if !selectedCards.isEmpty {
                Task { @MainActor in
                    FeedbackManager.shared.playCards(score: 0)
                    SoundManager.shared.play(.cardPlay)
                }
                playSelectedCards()
            }
            return
        }

        // 下滑弃牌
        if dy < -swipeActionThreshold && abs(dy) > abs(dx) * 1.5 {
            if !selectedCards.isEmpty {
                handleSwipeDiscard()
            }
            return
        }

        // 短距离 = 单点选牌
        if distance < tapDistanceThreshold {
            let now = touch.timestamp
            if let node = cardNodes.reversed().first(where: { $0.frame.contains(location) }) {
                toggleSelection(node)
                lastTapTime = now
                lastTapCardId = node.card.id
            }
            return
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartPoint = nil
        isSwipeSelecting = false
        swipeTouchedCardIds.removeAll()
        swipeSelectMode = nil
    }

    // MARK: - 双击智能选牌

    private func handleDoubleTap(_ node: CardNode) {
        guard let hand = rogueRun?.handCards else { return }
        let card = node.card

        guard let pattern = PatternRecognizer.bestPattern(containing: card, from: hand) else { return }

        // 清除当前选中
        clearSelection()

        // 选中最佳牌型中的所有牌
        for patternCard in pattern.cards {
            if let cardNode = cardNodes.first(where: { $0.card.id == patternCard.id }) {
                selectedCards.insert(patternCard.id)
                cardNode.select()
            }
        }
        selectionChanged.send()

        Task { @MainActor in
            FeedbackManager.shared.playCards(score: 0)
            SoundManager.shared.play(.cardTap)
        }
    }

    // MARK: - 下滑弃牌

    private func handleSwipeDiscard() {
        let selectedCardList = getSelectedCards()
        guard !selectedCardList.isEmpty else { return }
        guard let rogueRun = rogueRun else { return }

        let success = rogueRun.discardCards(selectedCardList)
        if success {
            // 弃牌成功动画 — 牌飞向下方消失
            let discardedIds = selectedCards
            cardNodes.filter { discardedIds.contains($0.card.id) }.forEach { node in
                node.childNode(withName: "highlight")?.removeFromParent()
                let flyDown = SKAction.moveBy(x: 0, y: -200, duration: 0.25)
                flyDown.timingMode = .easeIn
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                node.run(SKAction.sequence([
                    SKAction.group([flyDown, fadeOut]),
                    .removeFromParent()
                ]))
            }
            cardNodes.removeAll { discardedIds.contains($0.card.id) }
            selectedCards.removeAll()
            selectionChanged.send()

            Task { @MainActor in
                FeedbackManager.shared.cardTap()
                SoundManager.shared.play(.cardDiscard)
            }

            // 补牌后重新布局
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.layoutHand()
            }
        } else {
            shakeSelected()
        }
    }

    private func toggleSelection(_ node: CardNode) {
        let cardId = node.card.id

        // phantomCards: 被标记为幻影的牌无法选中
        if let boss = rogueRun?.bossState, boss.phantomCardIds.contains(cardId) {
            let shake = SKAction.sequence([
                .moveBy(x: -4, y: 0, duration: 0.03),
                .moveBy(x: 8, y: 0, duration: 0.03),
                .moveBy(x: -8, y: 0, duration: 0.03),
                .moveBy(x: 4, y: 0, duration: 0.03),
            ])
            node.run(shake)
            return
        }

        Task { @MainActor in
            FeedbackManager.shared.cardTap()
            SoundManager.shared.play(.cardTap)
        }

        if selectedCards.contains(cardId) {
            selectedCards.remove(cardId)
            node.deselect()
        } else {
            selectedCards.insert(cardId)
            node.select()
        }
        selectionChanged.send()
    }

    // MARK: - 动画

    private func showPlayedCards(_ cards: [Card], pattern: CardPattern) {
        playedAreaNode.removeAllChildren()

        // 在出牌区显示打出的牌型名
        let patternLabel = SKLabelNode(text: pattern.type.displayName)
        patternLabel.fontName = Theme.spriteKitSerifFontName
        patternLabel.fontSize = 20
        patternLabel.fontColor = SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 1.0)
        patternLabel.position = CGPoint(x: 0, y: 60)
        playedAreaNode.addChild(patternLabel)

        // 显示打出的牌（缩小版）
        let smallSize = CGSize(width: 34, height: 51)
        let overlap: CGFloat = 18
        let totalW = CGFloat(cards.count - 1) * overlap + smallSize.width
        let startX = -totalW / 2 + smallSize.width / 2

        for (i, card) in cards.enumerated() {
            let miniCard = CardNode(card: card, size: smallSize)
            miniCard.position = CGPoint(x: startX + CGFloat(i) * overlap, y: 0)
            miniCard.zPosition = CGFloat(i)
            miniCard.alpha = 0
            miniCard.setScale(0.5)

            let appear = SKAction.group([
                .fadeIn(withDuration: 0.2),
                .scale(to: 1.0, duration: 0.2)
            ])
            miniCard.run(SKAction.sequence([
                .wait(forDuration: 0.25),
                appear
            ]))

            playedAreaNode.addChild(miniCard)
        }

        // Gold sparkle particle burst
        let emitter = createPlayParticleEffect()
        let isPowerful = pattern.type == .bomb || pattern.type == .rocket
                      || pattern.type == .plane || pattern.type == .planeWithWings
        if isPowerful {
            emitter.particleBirthRate = 80
            emitter.numParticlesToEmit = 50
            emitter.particleSpeed = 90
            emitter.particleSpeedRange = 50
        }
        emitter.position = .zero
        emitter.zPosition = 100
        playedAreaNode.addChild(emitter)
        emitter.run(SKAction.sequence([
            .wait(forDuration: 1.0),
            .removeFromParent()
        ]))
    }

    // PERF-03: Static cached texture avoids bitmap allocation per card play
    private static let circleParticleTexture: SKTexture = {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillEllipse(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }()

    private func createPlayParticleEffect() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 40
        emitter.numParticlesToEmit = 25
        emitter.particleLifetime = 0.6
        emitter.particleLifetimeRange = 0.3
        emitter.particleSpeed = 60
        emitter.particleSpeedRange = 30
        emitter.emissionAngleRange = .pi * 2
        emitter.particleScale = 0.04
        emitter.particleScaleRange = 0.02
        emitter.particleScaleSpeed = -0.03
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -1.0
        emitter.particleColor = SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleTexture = Self.circleParticleTexture
        return emitter
    }

    private func showScorePopup(_ result: PlayResult) {
        let y = size.height * 0.52 + 100

        // chips × mult 微型标签（Balatro 风格核心展示）
        let chipsMultText = "\(result.pattern.baseChips) × \(L10n.formatDecimal(result.pattern.baseMult))"
        let chipsMultLabel = SKLabelNode(text: chipsMultText)
        chipsMultLabel.fontName = "Helvetica"
        chipsMultLabel.fontSize = 16
        chipsMultLabel.fontColor = SKColor.white.withAlphaComponent(0.7)
        chipsMultLabel.position = CGPoint(x: size.width / 2, y: y + 30)
        chipsMultLabel.zPosition = 99
        chipsMultLabel.alpha = 0
        addChild(chipsMultLabel)
        chipsMultLabel.run(SKAction.sequence([
            .fadeIn(withDuration: 0.15),
            .wait(forDuration: 0.8),
            SKAction.group([
                .moveBy(x: 0, y: 20, duration: 0.4),
                .fadeOut(withDuration: 0.4)
            ]),
            .removeFromParent()
        ]))

        // 分数 — 根据大小动态调整
        let scoreText = "+\(result.score)"
        let label = SKLabelNode(text: scoreText)
        label.fontName = "Helvetica-Bold"
        label.fontSize = result.score >= 300 ? 56 : (result.score >= 200 ? 48 : (result.score >= 100 ? 42 : 34))
        label.fontColor = result.score >= 300 ? SKColor.systemPink
            : (result.score >= 200 ? SKColor.orange
               : (result.score >= 100 ? SKColor.yellow : SKColor.white))
        label.position = CGPoint(x: size.width / 2, y: y)
        label.zPosition = 100
        label.setScale(0.3)
        addChild(label)

        let popIn = SKAction.scale(to: 1.3, duration: 0.12)
        let settle = SKAction.scale(to: 1.0, duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.5)
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        label.run(SKAction.sequence([
            popIn, settle, wait,
            SKAction.group([moveUp, fadeOut]),
            .removeFromParent()
        ]))

        // 连击提示
        if result.combo > 1 {
            let comboLabel = SKLabelNode(text: "\(result.combo)x COMBO!")
            comboLabel.fontName = "Helvetica-Bold"
            comboLabel.fontSize = result.combo >= 4 ? 24 : 18
            comboLabel.fontColor = result.combo >= 4 ? SKColor.systemPink : SKColor.orange
            comboLabel.position = CGPoint(x: size.width / 2, y: y - 35)
            comboLabel.zPosition = 100
            addChild(comboLabel)

            let comboAnim = SKAction.sequence([
                .wait(forDuration: 0.3),
                SKAction.group([
                    .moveBy(x: 0, y: 30, duration: 0.6),
                    .fadeOut(withDuration: 0.6)
                ]),
                .removeFromParent()
            ])
            comboLabel.run(comboAnim)
        }

        // 炸弹/火箭 — 屏幕震动 + 闪光 + 冲击波环 + 星爆粒子
        if result.pattern.type == .bomb || result.pattern.type == .rocket {
            let isRocket = result.pattern.type == .rocket
            screenShake(intensity: isRocket ? 1.5 : 1.0)
            screenFlash(color: isRocket
                        ? SKColor(red: 0.79, green: 0.30, blue: 0.30, alpha: 1.0)
                        : SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 1.0))

            let ringCenter = CGPoint(x: size.width / 2, y: y)
            let accentColor = isRocket
                ? SKColor(red: 0.79, green: 0.30, blue: 0.30, alpha: 0.8)
                : SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 0.8)

            // 冲击波环
            let ring = SKShapeNode(circleOfRadius: 10)
            ring.strokeColor = accentColor
            ring.fillColor = .clear
            ring.lineWidth = isRocket ? 4 : 3
            ring.glowWidth = isRocket ? 8 : 5
            ring.position = ringCenter
            ring.zPosition = 180
            ring.setScale(0.1)
            addChild(ring)

            ring.run(SKAction.sequence([
                SKAction.group([
                    .scale(to: isRocket ? 18 : 12, duration: 0.4),
                    .fadeOut(withDuration: 0.4)
                ]),
                .removeFromParent()
            ]))

            // 星爆粒子射线
            let trailCount = isRocket ? 16 : 10
            for i in 0..<trailCount {
                let angle = (CGFloat(i) / CGFloat(trailCount)) * 2 * .pi + CGFloat.random(in: -0.15...0.15)
                let dist: CGFloat = CGFloat.random(in: 70...160)

                let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
                spark.fillColor = accentColor.withAlphaComponent(1.0)
                spark.strokeColor = .clear
                spark.glowWidth = 3
                spark.position = ringCenter
                spark.zPosition = 179
                spark.alpha = 0
                addChild(spark)

                let dx = cos(angle) * dist
                let dy = sin(angle) * dist
                let dur = Double.random(in: 0.25...0.45)

                spark.run(SKAction.sequence([
                    .wait(forDuration: 0.03),
                    .fadeAlpha(to: 0.9, duration: 0.03),
                    SKAction.group([
                        .moveBy(x: dx, y: dy, duration: dur),
                        .fadeOut(withDuration: dur),
                        .scale(to: 0.2, duration: dur)
                    ]),
                    .removeFromParent()
                ]))
            }

            // 中心闪光球
            let core = SKShapeNode(circleOfRadius: isRocket ? 25 : 18)
            core.fillColor = accentColor.withAlphaComponent(0.6)
            core.strokeColor = .clear
            core.glowWidth = isRocket ? 20 : 12
            core.position = ringCenter
            core.zPosition = 181
            core.setScale(0.1)
            addChild(core)

            core.run(SKAction.sequence([
                .scale(to: 1.5, duration: 0.08),
                SKAction.group([
                    .scale(to: 3.0, duration: 0.25),
                    .fadeOut(withDuration: 0.25)
                ]),
                .removeFromParent()
            ]))
        }

        // 高连击也震一下
        if result.combo >= 3 {
            screenShake(intensity: min(1.5, 0.3 + Double(result.combo) * 0.2))

            // 连击 ≥ 4 屏幕边缘氛围光晕
            if result.combo >= 4 {
                let vignetteColor = result.combo >= 6
                    ? SKColor(red: 0.79, green: 0.30, blue: 0.30, alpha: 0.12)
                    : SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 0.10)
                let vignette = SKShapeNode(rectOf: size)
                vignette.fillColor = vignetteColor
                vignette.strokeColor = .clear
                vignette.position = CGPoint(x: size.width / 2, y: size.height / 2)
                vignette.zPosition = 95
                addChild(vignette)
                vignette.run(SKAction.sequence([
                    .fadeAlpha(to: 0.5, duration: 0.08),
                    .fadeOut(withDuration: 0.7),
                    .removeFromParent()
                ]))
            }
        }

        // 分数粒子爆发 — 分层级
        if result.score >= 80 {
            let count = result.score >= 300 ? 24 : (result.score >= 150 ? 16 : 8)
            emitScoreParticles(at: CGPoint(x: size.width / 2, y: y), count: count)
        }

        // 分数飞向顶部总分区域
        let flyLabel = SKLabelNode(text: "+\(result.score)")
        flyLabel.fontName = "Helvetica-Bold"
        flyLabel.fontSize = 18
        flyLabel.fontColor = SKColor(red: 0.85, green: 0.68, blue: 0.28, alpha: 1)
        flyLabel.position = CGPoint(x: size.width / 2, y: y)
        flyLabel.zPosition = 110
        flyLabel.alpha = 0
        addChild(flyLabel)

        flyLabel.run(SKAction.sequence([
            .wait(forDuration: 0.55),
            .fadeIn(withDuration: 0.1),
            SKAction.group([
                .move(to: CGPoint(x: size.width * 0.35, y: size.height - 50), duration: 0.45),
                .scale(to: 0.6, duration: 0.45),
                .sequence([
                    .wait(forDuration: 0.25),
                    .fadeOut(withDuration: 0.2)
                ])
            ]),
            .removeFromParent()
        ]))
    }

    // MARK: - 特效

    private func screenShake(intensity: CGFloat = 1.0) {
        let dx: CGFloat = 8 * intensity
        let dy: CGFloat = 4 * intensity
        let t: TimeInterval = 0.03
        let shake = SKAction.sequence([
            .moveBy(x: dx, y: dy, duration: t),
            .moveBy(x: -dx * 2, y: -dy, duration: t),
            .moveBy(x: dx * 2, y: dy, duration: t),
            .moveBy(x: -dx, y: -dy, duration: t),
            .moveBy(x: 0, y: 0, duration: t * 0.5),
        ])
        // R2-PERF-09: shake all direct children instead of broken "//" selector
        children.forEach { $0.run(shake) }
    }

    private func screenFlash(color: SKColor) {
        let flash = SKShapeNode(rectOf: size)
        flash.fillColor = color.withAlphaComponent(0.3)
        flash.strokeColor = .clear
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 200
        flash.alpha = 0
        addChild(flash)

        flash.run(SKAction.sequence([
            .fadeAlpha(to: 0.5, duration: 0.05),
            .fadeAlpha(to: 0, duration: 0.25),
            .removeFromParent()
        ]))
    }

    private func emitScoreParticles(at pos: CGPoint, count: Int = 12) {
        // 新中式粒子色系：赤金 / 翡翠 / 朱砂 / 紫气
        let colors: [SKColor] = [
            SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 1),
            SKColor(red: 0.0, green: 0.72, blue: 0.66, alpha: 1),
            SKColor(red: 0.79, green: 0.30, blue: 0.30, alpha: 1),
            SKColor(red: 0.48, green: 0.18, blue: 0.74, alpha: 1)
        ]
        for _ in 0..<count {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            particle.fillColor = colors.randomElement() ?? .white
            particle.strokeColor = .clear
            particle.position = pos
            particle.zPosition = 150
            addChild(particle)

            let angle = CGFloat.random(in: 0...(2 * .pi))
            let dist = CGFloat.random(in: 40...120)
            let dx = cos(angle) * dist
            let dy = sin(angle) * dist
            let dur = Double.random(in: 0.3...0.6)

            particle.run(SKAction.sequence([
                SKAction.group([
                    .moveBy(x: dx, y: dy, duration: dur),
                    .fadeOut(withDuration: dur),
                    .scale(to: 0.1, duration: dur)
                ]),
                .removeFromParent()
            ]))
        }
    }

    private func shakeSelected() {
        for node in cardNodes where selectedCards.contains(node.card.id) {
            let originalPos = node.position
            let shake = SKAction.sequence([
                .moveBy(x: -6, y: 0, duration: 0.04),
                .moveBy(x: 12, y: 0, duration: 0.04),
                .moveBy(x: -12, y: 0, duration: 0.04),
                .moveBy(x: 6, y: 0, duration: 0.04),
                .move(to: originalPos, duration: 0.03),
            ])
            node.run(shake)
        }
    }

    // MARK: - 过关庆祝动画

    /// 过关时的全屏庆祝粒子 — 从上方洒落金色粒子
    func playFloorClearCelebration() {
        let goldColors: [SKColor] = [
            SKColor(red: 0.85, green: 0.68, blue: 0.28, alpha: 1),
            SKColor(red: 0.96, green: 0.84, blue: 0.45, alpha: 1),
            SKColor(red: 0.62, green: 0.45, blue: 0.12, alpha: 1),
        ]

        // 金色光柱
        for i in 0..<3 {
            let beam = SKShapeNode(rectOf: CGSize(width: 2, height: size.height * 0.6))
            beam.fillColor = SKColor(red: 0.85, green: 0.68, blue: 0.28, alpha: 0.15)
            beam.strokeColor = .clear
            beam.position = CGPoint(
                x: size.width * (0.25 + CGFloat(i) * 0.25),
                y: size.height * 0.5
            )
            beam.zPosition = 160
            beam.alpha = 0
            addChild(beam)

            beam.run(SKAction.sequence([
                .wait(forDuration: Double(i) * 0.1),
                .fadeAlpha(to: 0.3, duration: 0.15),
                .fadeOut(withDuration: 0.8),
                .removeFromParent()
            ]))
        }

        // 洒落金色粒子
        for i in 0..<30 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            particle.fillColor = goldColors.randomElement() ?? .white
            particle.strokeColor = .clear
            particle.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: size.height + 20
            )
            particle.zPosition = 170
            addChild(particle)

            let endX = particle.position.x + CGFloat.random(in: -40...40)
            let endY = CGFloat.random(in: -20...size.height * 0.3)
            let dur = Double.random(in: 0.6...1.4)

            particle.run(SKAction.sequence([
                .wait(forDuration: Double(i) * 0.03),
                SKAction.group([
                    .move(to: CGPoint(x: endX, y: endY), duration: dur),
                    .fadeOut(withDuration: dur),
                    .scale(to: 0.2, duration: dur)
                ]),
                .removeFromParent()
            ]))
        }

        // 中央金色光环
        let ring = SKShapeNode(circleOfRadius: 20)
        ring.strokeColor = SKColor(red: 0.85, green: 0.68, blue: 0.28, alpha: 0.6)
        ring.fillColor = .clear
        ring.lineWidth = 3
        ring.glowWidth = 8
        ring.position = CGPoint(x: size.width / 2, y: size.height * 0.52)
        ring.zPosition = 175
        ring.setScale(0.1)
        addChild(ring)

        ring.run(SKAction.sequence([
            SKAction.group([
                .scale(to: 8, duration: 0.6),
                .fadeOut(withDuration: 0.6)
            ]),
            .removeFromParent()
        ]))

        // "过关！" 文字横幅动画
        let clearText = SKLabelNode(text: L10n.isEnglish ? "CLEARED!" : "过关！")
        clearText.fontName = Theme.spriteKitSerifFontName
        clearText.fontSize = 52
        clearText.fontColor = SKColor(red: 0.96, green: 0.84, blue: 0.45, alpha: 1)
        clearText.position = CGPoint(x: size.width / 2, y: size.height * 0.52)
        clearText.zPosition = 190
        clearText.setScale(0.1)
        clearText.alpha = 0
        addChild(clearText)

        clearText.run(SKAction.sequence([
            .wait(forDuration: 0.15),
            SKAction.group([
                .fadeIn(withDuration: 0.12),
                .scale(to: 1.3, duration: 0.18)
            ]),
            .scale(to: 1.0, duration: 0.1),
            .wait(forDuration: 0.7),
            SKAction.group([
                .moveBy(x: 0, y: 40, duration: 0.5),
                .fadeOut(withDuration: 0.5)
            ]),
            .removeFromParent()
        ]))

        // 文字下方光晕
        let textGlow = SKShapeNode(ellipseOf: CGSize(width: 200, height: 40))
        textGlow.fillColor = SKColor(red: 0.85, green: 0.68, blue: 0.28, alpha: 0.15)
        textGlow.strokeColor = .clear
        textGlow.position = CGPoint(x: size.width / 2, y: size.height * 0.50)
        textGlow.zPosition = 189
        textGlow.alpha = 0
        addChild(textGlow)

        textGlow.run(SKAction.sequence([
            .wait(forDuration: 0.15),
            .fadeAlpha(to: 0.5, duration: 0.2),
            .wait(forDuration: 0.5),
            .fadeOut(withDuration: 0.5),
            .removeFromParent()
        ]))
    }

    /// 通关时的全屏烟花效果
    func playVictoryCelebration() {
        let celebColors: [SKColor] = [
            SKColor(red: 0.85, green: 0.68, blue: 0.28, alpha: 1),
            SKColor(red: 0.0, green: 0.72, blue: 0.66, alpha: 1),
            SKColor(red: 0.79, green: 0.30, blue: 0.30, alpha: 1),
            SKColor(red: 0.48, green: 0.18, blue: 0.74, alpha: 1),
            SKColor(red: 0.96, green: 0.84, blue: 0.45, alpha: 1),
        ]

        // 多波次烟花
        for wave in 0..<3 {
            let center = CGPoint(
                x: CGFloat.random(in: size.width * 0.2...size.width * 0.8),
                y: CGFloat.random(in: size.height * 0.4...size.height * 0.7)
            )

            for _ in 0..<20 {
                let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
                spark.fillColor = celebColors.randomElement() ?? .white
                spark.strokeColor = .clear
                spark.position = center
                spark.zPosition = 200
                spark.alpha = 0
                addChild(spark)

                let angle = CGFloat.random(in: 0...(2 * .pi))
                let dist = CGFloat.random(in: 50...140)
                let dx = cos(angle) * dist
                let dy = sin(angle) * dist
                let dur = Double.random(in: 0.4...0.8)

                spark.run(SKAction.sequence([
                    .wait(forDuration: Double(wave) * 0.4 + Double.random(in: 0...0.1)),
                    .fadeIn(withDuration: 0.05),
                    SKAction.group([
                        .moveBy(x: dx, y: dy, duration: dur),
                        .fadeOut(withDuration: dur),
                        .scale(to: 0.1, duration: dur)
                    ]),
                    .removeFromParent()
                ]))
            }
        }

        screenShake(intensity: 0.5)

        // "通关！" 大字横幅 + 金色光晕
        let victoryText = SKLabelNode(text: L10n.isEnglish ? "VICTORY!" : "通关！")
        victoryText.fontName = Theme.spriteKitSerifFontName
        victoryText.fontSize = 68
        victoryText.fontColor = SKColor(red: 0.96, green: 0.84, blue: 0.45, alpha: 1)
        victoryText.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        victoryText.zPosition = 210
        victoryText.setScale(0.05)
        victoryText.alpha = 0
        addChild(victoryText)

        let glow = SKShapeNode(circleOfRadius: 80)
        glow.fillColor = SKColor(red: 0.85, green: 0.68, blue: 0.28, alpha: 0.2)
        glow.strokeColor = .clear
        glow.position = victoryText.position
        glow.zPosition = 209
        glow.setScale(0.1)
        glow.alpha = 0
        addChild(glow)

        victoryText.run(SKAction.sequence([
            .wait(forDuration: 0.3),
            SKAction.group([
                .fadeIn(withDuration: 0.15),
                .scale(to: 1.4, duration: 0.25)
            ]),
            .scale(to: 1.0, duration: 0.12),
            .wait(forDuration: 1.2),
            SKAction.group([
                .scale(to: 1.15, duration: 0.6),
                .fadeOut(withDuration: 0.6)
            ]),
            .removeFromParent()
        ]))

        glow.run(SKAction.sequence([
            .wait(forDuration: 0.3),
            SKAction.group([
                .fadeAlpha(to: 0.5, duration: 0.25),
                .scale(to: 3.0, duration: 0.4)
            ]),
            .fadeOut(withDuration: 1.0),
            .removeFromParent()
        ]))

        // 第二波大型烟花（延迟）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            for _ in 0..<25 {
                let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
                spark.fillColor = celebColors.randomElement() ?? .white
                spark.strokeColor = .clear
                let cx = CGFloat.random(in: self.size.width * 0.15...self.size.width * 0.85)
                let cy = CGFloat.random(in: self.size.height * 0.35...self.size.height * 0.75)
                spark.position = CGPoint(x: cx, y: cy)
                spark.zPosition = 200
                spark.alpha = 0
                self.addChild(spark)

                let angle = CGFloat.random(in: 0...(2 * .pi))
                let dist = CGFloat.random(in: 40...100)
                let dur = Double.random(in: 0.4...0.7)

                spark.run(SKAction.sequence([
                    .fadeIn(withDuration: 0.05),
                    SKAction.group([
                        .moveBy(x: cos(angle) * dist, y: sin(angle) * dist, duration: dur),
                        .fadeOut(withDuration: dur),
                        .scale(to: 0.1, duration: dur)
                    ]),
                    .removeFromParent()
                ]))
            }
        }
    }
}
