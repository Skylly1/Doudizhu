import SwiftUI
import SpriteKit

/// SwiftUI 包装：牌局界面
struct BattleView: View {
    let onBack: () -> Void
    @StateObject private var rogueRun = RogueRun()

    var body: some View {
        ZStack {
            // SpriteKit 牌桌场景
            SpriteView(scene: makeBattleScene())
                .ignoresSafeArea()

            // SwiftUI 覆盖层：分数、Buff、返回按钮
            VStack {
                // 顶部信息栏
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    // 层数
                    Text("第 \(rogueRun.currentFloor) 层")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    // 分数
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(rogueRun.score)")
                            .font(.headline.monospacedDigit())
                            .foregroundColor(.yellow)
                    }
                }
                .padding()

                Spacer()

                // 底部 Buff 展示
                if !rogueRun.activeBuffs.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(rogueRun.activeBuffs) { buff in
                                Text(buff.name)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(.orange.opacity(0.3))
                                    )
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .onAppear {
            rogueRun.startFloor()
        }
    }

    private func makeBattleScene() -> BattleScene {
        let scene = BattleScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        scene.rogueRun = rogueRun
        return scene
    }
}

#Preview {
    BattleView(onBack: {})
}
