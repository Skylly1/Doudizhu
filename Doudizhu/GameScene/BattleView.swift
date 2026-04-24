import SwiftUI
import SpriteKit

struct BattleView: View {
    let onBack: () -> Void
    @ObservedObject var rogueRun: RogueRun
    let onShop: () -> Void
    @State private var battleScene: BattleScene?

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
            } else if rogueRun.phase == .floorFail {
                floorFailOverlay
            } else if rogueRun.phase == .victory {
                victoryOverlay
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
            if case .scoring = newPhase {
                // 得分动画：延迟后切回选牌
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    rogueRun.onScoringComplete()
                    battleScene?.refreshHand()
                }
            }
        }
    }

    // MARK: - 顶部信息栏

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            // 关卡信息
            VStack(spacing: 2) {
                Text("第 \(rogueRun.currentFloorIndex + 1) 层")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                Text(rogueRun.currentFloor.name)
                    .font(.headline)
                    .foregroundColor(.white)
            }

            Spacer()

            // 金币
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
                Text("\(rogueRun.gold)")
                    .font(.headline.monospacedDigit())
                    .foregroundColor(.yellow)
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
                                Text(joker.icon)
                                    .font(.caption2)
                                Text(joker.name)
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(.cyan.opacity(0.2))
                            )
                            .foregroundColor(.cyan)
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
                                Text(buff.icon)
                                    .font(.caption2)
                                Text(buff.name)
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(.orange.opacity(0.2))
                            )
                            .foregroundColor(.orange)
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
                    .foregroundColor(rogueRun.playsRemaining <= 1 ? .red : .cyan)

                // 换牌次数
                Label("\(rogueRun.discardsRemaining)", systemImage: "arrow.triangle.2.circlepath")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(rogueRun.discardsRemaining == 0 ? .gray : .green)

                Spacer()

                // 分数
                Text("\(rogueRun.floorScore)")
                    .font(.title2.bold().monospacedDigit())
                    .foregroundColor(.white)
                Text("/ \(rogueRun.currentFloor.targetScore)")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal)

            // 进度条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.1))
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
                Text("🔥 \(rogueRun.combo) 连击！加成 +\(Int(Double(rogueRun.combo - 1) * 15))%")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
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

    private var actionButtons: some View {
        HStack(spacing: 16) {
            // 弃牌按钮
            Button {
                guard let scene = battleScene else { return }
                let selected = scene.getSelectedCards()
                if rogueRun.discardCards(selected) {
                    scene.clearSelection()
                    scene.refreshHand()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("换牌")
                    Text("(\(rogueRun.discardsRemaining))")
                        .font(.caption)
                }
                .font(.body.weight(.medium))
                .foregroundColor(rogueRun.discardsRemaining > 0 ? .white : .gray)
                .frame(width: 120, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(rogueRun.discardsRemaining > 0 ? .red.opacity(0.3) : .gray.opacity(0.1))
                        .stroke(rogueRun.discardsRemaining > 0 ? .red.opacity(0.5) : .gray.opacity(0.2))
                )
            }
            .disabled(rogueRun.discardsRemaining <= 0 || rogueRun.phase != .selecting)

            // 出牌按钮
            Button {
                battleScene?.playSelectedCards()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                    Text("出牌")
                    Text("(\(rogueRun.playsRemaining))")
                        .font(.caption)
                }
                .font(.body.weight(.semibold))
                .foregroundColor(rogueRun.playsRemaining > 0 ? .black : .gray)
                .frame(width: 140, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(rogueRun.playsRemaining > 0 ? .yellow : .gray.opacity(0.2))
                )
            }
            .disabled(rogueRun.playsRemaining <= 0 || rogueRun.phase != .selecting)
        }
    }

    // MARK: - 过关弹窗

    private var floorWinOverlay: some View {
        overlayBase {
            VStack(spacing: 20) {
                Text("✨ 过关！")
                    .font(.largeTitle.bold())
                    .foregroundColor(.yellow)

                Text(rogueRun.currentFloor.name)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))

                VStack(spacing: 8) {
                    statRow("本层得分", value: "\(rogueRun.floorScore)")
                    statRow("总得分", value: "\(rogueRun.totalScore)")
                    statRow("获得金币", value: "+\(rogueRun.currentFloor.targetScore / 10)")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.05)))

                Button("继续前进 →") {
                    rogueRun.advanceToNextFloor()
                    battleScene?.refreshHand()
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(width: 200, height: 50)
                .background(RoundedRectangle(cornerRadius: 12).fill(.yellow))
            }
        }
    }

    private var floorFailOverlay: some View {
        overlayBase {
            VStack(spacing: 20) {
                Text("💀 失败")
                    .font(.largeTitle.bold())
                    .foregroundColor(.red)

                Text("未达到目标分数")
                    .foregroundColor(.white.opacity(0.7))

                VStack(spacing: 8) {
                    statRow("本层得分", value: "\(rogueRun.floorScore)")
                    statRow("目标分数", value: "\(rogueRun.currentFloor.targetScore)")
                    statRow("总得分", value: "\(rogueRun.totalScore)")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.05)))

                Button("重新开始") {
                    rogueRun.restart()
                    battleScene?.refreshHand()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(RoundedRectangle(cornerRadius: 12).fill(.red))
            }
        }
    }

    private var victoryOverlay: some View {
        overlayBase {
            VStack(spacing: 20) {
                Text("🏆 通关！")
                    .font(.largeTitle.bold())
                    .foregroundColor(.yellow)

                Text("你击败了恶霸地主！")
                    .font(.title3)
                    .foregroundColor(.white)

                Text("总分：\(rogueRun.totalScore)")
                    .font(.title.bold().monospacedDigit())
                    .foregroundColor(.yellow)

                Button("再来一局") {
                    rogueRun.restart()
                    battleScene?.refreshHand()
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(width: 200, height: 50)
                .background(RoundedRectangle(cornerRadius: 12).fill(.yellow))

                Button("返回主菜单", action: onBack)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    // MARK: - Helpers

    private func overlayBase<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack {
                content()
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.9))
                    .stroke(.white.opacity(0.1))
            )
            .padding(40)
        }
    }

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.body.bold().monospacedDigit())
                .foregroundColor(.white)
        }
    }
}

#Preview {
    BattleView(rogueRun: RogueRun(), onBack: {}, onShop: {})
}
