import SwiftUI

/// App Icon 设计参考 — 用于预览和截图
struct AppIconPreview: View {
    var body: some View {
        ZStack {
            // Background: dark blue-black gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.15),
                    Color(red: 0.02, green: 0.04, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Diagonal gold accent stripe
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )

            VStack(spacing: 4) {
                // Playing card emoji as center icon
                Text("🎴")
                    .font(.system(size: 80))
                    .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

                // Chinese title
                Text("斗破")
                    .font(.system(size: 32, weight: .black, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.93, blue: 0.55),
                                Color(red: 1.0, green: 0.84, blue: 0.0),
                                Color(red: 0.85, green: 0.65, blue: 0.0)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.4), radius: 8)

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
