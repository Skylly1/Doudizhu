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
    private let baseCardWidth: CGFloat = 66
    private let baseCardHeight: CGFloat = 99
    private let cardOverlap: CGFloat = 32

    override func didMove(to view: SKView) {
        // 暖棕底色 — 大幅提亮，OLED 可见
        backgroundColor = SKColor(red: 0.22, green: 0.16, blue: 0.11, alpha: 1.0)

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
    }

    /// 排列手牌 — 扇形布局，动态缩放卡牌尺寸
    func layoutHand() {
        cardNodes.forEach { $0.removeFromParent() }
        cardNodes.removeAll()
        selectedCards.removeAll()

        guard let cards = rogueRun?.handCards, !cards.isEmpty else { return }

        let count = cards.count

        // Dynamic card sizing: shrink cards when hand is large
        let scaleFactor: CGFloat = count <= 7 ? 1.0 : max(0.65, 1.0 - CGFloat(count - 7) * 0.05)
        let cardWidth = baseCardWidth * scaleFactor
        let cardHeight = baseCardHeight * scaleFactor

        // 动态计算 overlap 确保不超出屏幕
        let maxWidth = size.width - 24
        let idealOverlap = cardOverlap * scaleFactor
        let overlap = min(idealOverlap, (maxWidth - cardWidth) / CGFloat(max(count - 1, 1)))
        let totalWidth = CGFloat(count - 1) * overlap + cardWidth
        let startX = (size.width - totalWidth) / 2 + cardWidth / 2
        // Leave room for SwiftUI bottom panel
        let baseY = cardHeight / 2 + 190

        // 扇形弧度参数 — 温和弧度
        let maxAngle: CGFloat = count > 5 ? 0.022 : 0.012
        let arcHeight: CGFloat = count > 5 ? 6 : 3

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

            // phantomCards: 幻影牌半透明 + 问号标记
            if let boss = rogueRun?.bossState, boss.phantomCardIds.contains(card.id) {
                node.alpha = 0.5
                let phantom = SKLabelNode(text: "?")
                phantom.fontName = Theme.spriteKitSerifFontName
                phantom.fontSize = cardWidth * 0.4
                phantom.fontColor = SKColor(red: 0.82, green: 0.22, blue: 0.18, alpha: 0.8)
                phantom.verticalAlignmentMode = .center
                phantom.zPosition = 10
                phantom.name = "phantomMark"
                node.addChild(phantom)
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

        // phantomCards: 被标记为幻影的牌无法选中
        if let boss = rogueRun?.bossState, boss.phantomCardIds.contains(cardId) {
            // 抖动反馈
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
    }

    private func showScorePopup(_ result: PlayResult) {
        let y = size.height * 0.52 + 100

        // chips × mult 微型标签（Balatro 风格核心展示）
        let chipsMultText = "\(result.pattern.baseChips) × \(String(format: "%.1f", result.pattern.baseMult))"
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

        // 炸弹/火箭 — 屏幕震动 + 闪光 + 冲击波环
        if result.pattern.type == .bomb || result.pattern.type == .rocket {
            let isRocket = result.pattern.type == .rocket
            screenShake(intensity: isRocket ? 1.5 : 1.0)
            screenFlash(color: isRocket
                        ? SKColor(red: 0.79, green: 0.30, blue: 0.30, alpha: 1.0)
                        : SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 1.0))

            // 冲击波环
            let ringCenter = CGPoint(x: size.width / 2, y: y)
            let ring = SKShapeNode(circleOfRadius: 10)
            ring.strokeColor = isRocket
                ? SKColor(red: 0.79, green: 0.30, blue: 0.30, alpha: 0.8)
                : SKColor(red: 0.83, green: 0.64, blue: 0.22, alpha: 0.8)
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
        }

        // 高连击也震一下
        if result.combo >= 3 {
            screenShake(intensity: min(1.5, 0.3 + Double(result.combo) * 0.2))
        }

        // 分数粒子爆发 — 分层级
        if result.score >= 80 {
            let count = result.score >= 300 ? 24 : (result.score >= 150 ? 16 : 8)
            emitScoreParticles(at: CGPoint(x: size.width / 2, y: y), count: count)
        }
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
            particle.fillColor = goldColors.randomElement()!
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
                spark.fillColor = celebColors.randomElement()!
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
    }
}
