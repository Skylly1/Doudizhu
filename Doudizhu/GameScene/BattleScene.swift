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

    // 布局常量
    private let cardWidth: CGFloat = 56
    private let cardHeight: CGFloat = 80
    private let cardOverlap: CGFloat = 26

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.02, green: 0.06, blue: 0.10, alpha: 1.0)

        // 出牌区域
        playedAreaNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(playedAreaNode)

        // 桌面装饰
        drawTableDecor()

        layoutHand()
    }

    private func drawTableDecor() {
        // 毡布底纹 — 微妙的椭圆渐变
        let table = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.85, height: size.height * 0.45))
        table.fillColor = SKColor(red: 0.06, green: 0.12, blue: 0.18, alpha: 0.6)
        table.strokeColor = SKColor.cyan.withAlphaComponent(0.06)
        table.lineWidth = 1
        table.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        table.zPosition = -10
        addChild(table)

        // 中央出牌区域
        let circle = SKShapeNode(circleOfRadius: 70)
        circle.fillColor = SKColor.white.withAlphaComponent(0.02)
        circle.strokeColor = SKColor.white.withAlphaComponent(0.06)
        circle.lineWidth = 1.5
        circle.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        circle.zPosition = -5
        addChild(circle)

        // 虚线圈装饰
        let dashCircle = SKShapeNode(circleOfRadius: 90)
        dashCircle.fillColor = .clear
        dashCircle.strokeColor = SKColor.white.withAlphaComponent(0.04)
        dashCircle.lineWidth = 1
        dashCircle.position = circle.position
        dashCircle.zPosition = -5
        addChild(dashCircle)

        let hint = SKLabelNode(text: "出牌区")
        hint.fontName = "PingFangSC-Light"
        hint.fontSize = 13
        hint.fontColor = SKColor.white.withAlphaComponent(0.10)
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.5 - 5)
        hint.name = "hint"
        hint.zPosition = -4
        addChild(hint)

        // 四角装饰
        for (dx, dy) in [(-1.0, 1.0), (1.0, 1.0), (-1.0, -1.0), (1.0, -1.0)] {
            let dot = SKShapeNode(circleOfRadius: 3)
            dot.fillColor = SKColor.cyan.withAlphaComponent(0.08)
            dot.strokeColor = .clear
            dot.position = CGPoint(
                x: size.width / 2 + dx * size.width * 0.42,
                y: size.height / 2 + dy * size.height * 0.22
            )
            dot.zPosition = -10
            addChild(dot)
        }
    }

    /// 排列手牌 — 扇形布局
    func layoutHand() {
        cardNodes.forEach { $0.removeFromParent() }
        cardNodes.removeAll()
        selectedCards.removeAll()

        guard let cards = rogueRun?.handCards, !cards.isEmpty else { return }

        let count = cards.count
        // 动态计算 overlap 确保不超出屏幕
        let maxWidth = size.width - 32
        let overlap = min(cardOverlap, (maxWidth - cardWidth) / CGFloat(max(count - 1, 1)))
        let totalWidth = CGFloat(count - 1) * overlap + cardWidth
        let startX = (size.width - totalWidth) / 2 + cardWidth / 2
        let baseY = cardHeight / 2 + 100

        // 扇形弧度参数
        let maxAngle: CGFloat = count > 5 ? 0.035 : 0.02  // 每张牌的最大旋转角
        let arcHeight: CGFloat = count > 5 ? 12 : 6        // 弧线高度

        for (index, card) in cards.enumerated() {
            let node = CardNode(card: card, size: CGSize(width: cardWidth, height: cardHeight))

            let progress = count > 1 ? CGFloat(index) / CGFloat(count - 1) : 0.5
            let centered = progress - 0.5  // -0.5 到 0.5

            // 扇形弧线 Y 偏移
            let arcY = -arcHeight * (centered * centered * 4)  // 抛物线
            let rotation = -centered * maxAngle * CGFloat(count)

            node.position = CGPoint(
                x: startX + CGFloat(index) * overlap,
                y: baseY + arcY
            )
            node.zRotation = rotation
            node.zPosition = CGFloat(index)

            // 入场动画
            let finalPos = node.position
            let finalRot = node.zRotation
            node.position.y = -cardHeight
            node.alpha = 0
            node.zRotation = 0

            let delay = SKAction.wait(forDuration: Double(index) * 0.04)
            let moveUp = SKAction.move(to: finalPos, duration: 0.35)
            moveUp.timingMode = .easeOut
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let rotate = SKAction.rotate(toAngle: finalRot, duration: 0.35)
            rotate.timingMode = .easeOut

            node.run(SKAction.sequence([
                delay,
                SKAction.group([moveUp, fadeIn, rotate])
            ]))

            addChild(node)
            cardNodes.append(node)
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

        // 触觉 + 音效反馈
        Task { @MainActor in
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
        }

        // 出牌动画：选中的牌飞到中央
        showPlayedCards(selectedCardList, pattern: result.pattern)

        // 显示得分
        showScorePopup(result)

        // 移除已出的牌节点
        let playedIds = selectedCards
        cardNodes.filter { playedIds.contains($0.card.id) }.forEach { node in
            let flyTo = CGPoint(x: size.width / 2, y: size.height * 0.5)
            let move = SKAction.move(to: flyTo, duration: 0.25)
            move.timingMode = .easeIn
            let scale = SKAction.scale(to: 0.7, duration: 0.25)
            node.run(SKAction.group([move, scale]))
        }
        cardNodes.removeAll { playedIds.contains($0.card.id) }
        selectedCards.removeAll()
    }

    // MARK: - 触摸交互

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard rogueRun?.phase == .selecting else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for node in cardNodes.reversed() {
            if node.frame.contains(location) {
                toggleSelection(node)
                break
            }
        }
    }

    private func toggleSelection(_ node: CardNode) {
        let cardId = node.card.id

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
        patternLabel.fontName = "PingFangSC-Semibold"
        patternLabel.fontSize = 20
        patternLabel.fontColor = .cyan
        patternLabel.position = CGPoint(x: 0, y: 60)
        playedAreaNode.addChild(patternLabel)

        // 显示打出的牌（缩小版）
        let smallSize = CGSize(width: 40, height: 60)
        let overlap: CGFloat = 22
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
    }

    private func showScorePopup(_ result: PlayResult) {
        let y = size.height * 0.5 + 110

        // 分数 — 根据大小动态调整
        let scoreText = "+\(result.score)"
        let label = SKLabelNode(text: scoreText)
        label.fontName = "Helvetica-Bold"
        label.fontSize = result.score >= 200 ? 52 : (result.score >= 100 ? 44 : 36)
        label.fontColor = result.score >= 200 ? SKColor.systemPink
            : (result.score >= 100 ? SKColor.orange : SKColor.yellow)
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
            let comboLabel = SKLabelNode(text: "🔥 \(result.combo)x COMBO!")
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

        // 炸弹/火箭 — 屏幕震动 + 闪白
        if result.pattern.type == .bomb || result.pattern.type == .rocket {
            screenShake()
            screenFlash(color: result.pattern.type == .rocket ? .red : .orange)
        }

        // 高分粒子爆发
        if result.score >= 150 {
            emitScoreParticles(at: CGPoint(x: size.width / 2, y: y))
        }
    }

    // MARK: - 特效

    private func screenShake() {
        let dx: CGFloat = 8
        let shake = SKAction.sequence([
            .moveBy(x: dx, y: 0, duration: 0.03),
            .moveBy(x: -dx * 2, y: 0, duration: 0.03),
            .moveBy(x: dx * 2, y: dx, duration: 0.03),
            .moveBy(x: -dx, y: -dx, duration: 0.03),
            .moveBy(x: 0, y: 0, duration: 0.02),
        ])
        let cam = childNode(withName: "//") ?? self
        cam.run(shake)
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

    private func emitScoreParticles(at pos: CGPoint) {
        let colors: [SKColor] = [.yellow, .orange, .cyan, .systemPink]
        for _ in 0..<12 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            particle.fillColor = colors.randomElement()!
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
}
