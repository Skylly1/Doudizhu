import SwiftUI

struct HomeView: View {
    let onNavigate: (AppScreen) -> Void

    var body: some View {
        ZStack {
            // 水墨背景
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                // 标题
                Text("斗破乾坤")
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text("Roguelike 斗地主")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.6))

                Spacer().frame(height: 20)

                // 菜单按钮
                VStack(spacing: 16) {
                    MenuButton(title: "开始冒险", icon: "play.fill") {
                        onNavigate(.map)
                    }
                    MenuButton(title: "卡牌收藏", icon: "rectangle.stack.fill") {
                        onNavigate(.collection)
                    }
                    MenuButton(title: "设置", icon: "gearshape.fill") {
                        onNavigate(.settings)
                    }
                }
            }
            .padding()
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.title3.weight(.medium))
            }
            .foregroundColor(.white)
            .frame(width: 240, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.1))
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    HomeView(onNavigate: { _ in })
}
