import SwiftUI

/// Roguelike 地图：冒险入口
struct MapView: View {
    let onStart: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                // 顶部
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()

                Spacer()

                // 关卡预览
                VStack(spacing: 16) {
                    Text("📜 冒险之路")
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Text("穿越8层牌局，击败恶霸地主")
                        .foregroundColor(.white.opacity(0.6))

                    // 关卡列表
                    VStack(spacing: 8) {
                        ForEach(FloorConfig.allFloors, id: \.floor) { floor in
                            HStack {
                                Text(floor.isShop ? "🏪" : "⚔️")
                                Text("第\(floor.floor)层")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                Text(floor.name)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                Spacer()
                                if !floor.isShop {
                                    Text("目标 \(floor.targetScore)")
                                        .font(.caption.monospacedDigit())
                                        .foregroundColor(.yellow.opacity(0.7))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white.opacity(0.04))
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                // 开始按钮
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("开始冒险")
                    }
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.black)
                    .frame(width: 220, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.yellow)
                    )
                }
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    MapView(onStart: {}, onBack: {})
}
