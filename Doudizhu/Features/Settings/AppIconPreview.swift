import SwiftUI

/// App Icon 设计参考 — 用于预览和截图
struct AppIconPreview: View {
    var body: some View {
        ZStack {
            // Background: 墨色宣纸渐变
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.06, blue: 0.12),
                    Color(red: 0.03, green: 0.03, blue: 0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 赤金光晕
            RadialGradient(
                colors: [
                    Color(red: 0.83, green: 0.64, blue: 0.22).opacity(0.15),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            )

            VStack(spacing: 4) {
                // 牌面图标（替代 emoji）
                Image(systemName: "suit.spade.fill")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.95, green: 0.82, blue: 0.42),
                                Color(red: 0.83, green: 0.64, blue: 0.22),
                                Color(red: 0.65, green: 0.48, blue: 0.12)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

                // Chinese title
                Text("斗破")
                    .font(.system(size: 32, weight: .black, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.95, green: 0.82, blue: 0.42),
                                Color(red: 0.83, green: 0.64, blue: 0.22),
                                Color(red: 0.65, green: 0.48, blue: 0.12)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(red: 0.83, green: 0.64, blue: 0.22).opacity(0.4), radius: 8)

                Text("乾坤")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: 200, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 44))
    }
}

#Preview {
    AppIconPreview()
        .padding(40)
        .background(Color.gray.opacity(0.2))
}
