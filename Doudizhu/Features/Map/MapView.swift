import SwiftUI

/// Roguelike 地图：层层递进的关卡选择
struct MapView: View {
    let onNavigate: (AppScreen) -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                // 顶部导航
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("第一章 · 乡野牌局")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()

                // TODO: Roguelike 路径地图（类杀戮尖塔的分支路径）
                Spacer()

                Text("🗺️ 地图开发中...")
                    .foregroundColor(.white.opacity(0.5))

                Spacer()

                // 进入战斗（临时按钮）
                Button("进入牌局") {
                    onNavigate(.battle)
                }
                .font(.title3.weight(.medium))
                .foregroundColor(.black)
                .frame(width: 200, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.yellow)
                )
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    MapView(onNavigate: { _ in }, onBack: {})
}
