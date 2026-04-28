import SwiftUI

// MARK: - 金色渐变常量
// UX-TODO: These local constants duplicate Theme.gold* values for Icon rendering isolation.
// Consider refactoring if Theme tokens change.
private let goldGradient = LinearGradient(
    colors: [
        Color(red: 0.95, green: 0.82, blue: 0.42),
        Color(red: 0.83, green: 0.64, blue: 0.22),
        Color(red: 0.65, green: 0.48, blue: 0.12)
    ],
    startPoint: .top, endPoint: .bottom
)

private let goldColor = Color(red: 0.83, green: 0.64, blue: 0.22)

/// App Icon 设计 — 与首页暖棕国潮风格统一
/// 在 Xcode Preview 中渲染后导出为 1024×1024 PNG 即可作为 AppIcon
struct AppIconPreview: View {
    let size: CGFloat

    init(size: CGFloat = 200) {
        self.size = size
    }

    var body: some View {
        ZStack {
            // 1. 暖棕渐变背景 — 加深对比，小尺寸也能看出层次
            LinearGradient(
                colors: [
                    Color(red: 0.42, green: 0.28, blue: 0.16),
                    Color(red: 0.22, green: 0.14, blue: 0.08),
                    Color(red: 0.10, green: 0.07, blue: 0.04)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // 2. 大面积金色光晕 — 高不透明度，小图标也醒目
            RadialGradient(
                colors: [
                    Color(red: 0.92, green: 0.75, blue: 0.32).opacity(0.55),
                    Color(red: 0.88, green: 0.70, blue: 0.28).opacity(0.30),
                    Color(red: 0.85, green: 0.65, blue: 0.25).opacity(0.10),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.35),
                startRadius: 0,
                endRadius: size * 0.60
            )

            // 3. 底部暗角 — 增强纵深感
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(red: 0.08, green: 0.05, blue: 0.03).opacity(0.5),
                    Color(red: 0.06, green: 0.04, blue: 0.02).opacity(0.75)
                ],
                startPoint: .init(x: 0.5, y: 0.55),
                endPoint: .bottom
            )

            // 4. 印章辉光 — 更亮更大
            Circle()
                .fill(goldColor.opacity(0.35))
                .frame(width: size * 0.60, height: size * 0.60)
                .blur(radius: size * 0.10)
                .offset(y: -size * 0.02)

            // 4. 金色微粒装饰
            particlesLayer

            // 5. 菱形印章主体
            sealStamp
        }
        .frame(width: size, height: size)
        .clipped()
    }

    // MARK: - 菱形印章「斗」
    private var sealStamp: some View {
        ZStack {
            // 外菱形框 — 加粗线条
            RoundedRectangle(cornerRadius: size * 0.02)
                .stroke(goldColor.opacity(0.70), lineWidth: size * 0.018)
                .frame(width: size * 0.38, height: size * 0.38)
                .rotationEffect(.degrees(45))

            // 内菱形框
            RoundedRectangle(cornerRadius: size * 0.015)
                .stroke(goldColor.opacity(0.35), lineWidth: size * 0.008)
                .frame(width: size * 0.30, height: size * 0.30)
                .rotationEffect(.degrees(45))

            // 「斗」字 — 更强阴影
            Text("斗")
                .font(.system(size: size * 0.28, weight: .black, design: .serif))
                .foregroundStyle(goldGradient)
                .shadow(color: .black.opacity(0.6), radius: size * 0.025, y: size * 0.012)
        }
        .shadow(color: goldColor.opacity(0.55), radius: size * 0.10)
    }

    // MARK: - 金色微粒
    private var particlesLayer: some View {
        ZStack {
            // 大颗粒
            Circle()
                .fill(Color(red: 0.85, green: 0.68, blue: 0.28))
                .frame(width: size * 0.018, height: size * 0.018)
                .shadow(color: goldColor.opacity(0.6), radius: size * 0.015)
                .offset(x: -size * 0.22, y: size * 0.28)

            Circle()
                .fill(Color(red: 0.85, green: 0.68, blue: 0.28))
                .frame(width: size * 0.015, height: size * 0.015)
                .shadow(color: goldColor.opacity(0.5), radius: size * 0.012)
                .offset(x: size * 0.25, y: size * 0.22)

            Circle()
                .fill(Color(red: 0.85, green: 0.68, blue: 0.28))
                .frame(width: size * 0.012, height: size * 0.012)
                .shadow(color: goldColor.opacity(0.4), radius: size * 0.01)
                .offset(x: size * 0.15, y: size * 0.32)

            // 小颗粒
            Circle()
                .fill(Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.7))
                .frame(width: size * 0.008, height: size * 0.008)
                .offset(x: -size * 0.30, y: size * 0.15)

            Circle()
                .fill(Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.6))
                .frame(width: size * 0.007, height: size * 0.007)
                .offset(x: size * 0.08, y: size * 0.35)
        }
    }
}

// MARK: - Icon 导出工具（DEBUG 模式）

#if DEBUG
/// 在 App 内渲染 1024×1024 Icon 并保存到相册
struct IconExporterView: View {
    @State private var exportState: ExportState = .idle

    enum ExportState {
        case idle, exporting, success, failed(String)
    }

    private var isSuccess: Bool {
        if case .success = exportState { return true }
        return false
    }

    private var isExporting: Bool {
        if case .exporting = exportState { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("App Icon 导出工具")
                .font(.title2.bold())
                .foregroundColor(.white)

            AppIconPreview(size: 300)
                .clipShape(RoundedRectangle(cornerRadius: 66))

            Text("点击下方按钮，将 1024×1024 Icon 保存到相册")
                .font(.caption)
                .foregroundColor(.gray)

            Button {
                exportIcon()
            } label: {
                HStack {
                    switch exportState {
                    case .idle:
                        Image(systemName: "square.and.arrow.down")
                        Text("导出到相册")
                    case .exporting:
                        ProgressView()
                            .tint(.white)
                        Text("导出中…")
                    case .success:
                        Image(systemName: "checkmark.circle.fill")
                        Text("已保存到相册 ✓")
                    case .failed(let msg):
                        Image(systemName: "xmark.circle.fill")
                        Text(msg)
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSuccess ? Color.green : Color(red: 0.83, green: 0.64, blue: 0.22))
                )
            }
            .disabled(isExporting)
            .padding(.horizontal, 40)

            Text("保存后从相册获取图片，放入:\nAssets.xcassets/AppIcon.appiconset/AppIcon.png")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }

    @MainActor
    private func exportIcon() {
        exportState = .exporting
        let renderer = ImageRenderer(content: AppIconPreview(size: 1024))
        renderer.scale = 1.0
        guard let uiImage = renderer.uiImage else {
            exportState = .failed("渲染失败")
            return
        }
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        exportState = .success
    }
}
#endif

// MARK: - 预览

#Preview("App Icon 200pt") {
    AppIconPreview(size: 200)
        .padding(40)
        .background(Color.gray.opacity(0.2))
}

#Preview("App Icon 1024pt — 导出用") {
    AppIconPreview(size: 1024)
}

#if DEBUG
#Preview("Icon 导出工具") {
    IconExporterView()
}
#endif
