import SwiftUI

struct SettingsView: View {
    let onBack: () -> Void

    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = false

    var body: some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                GameNavBar(title: "设置", onBack: onBack)

                ScrollView {
                    VStack(spacing: Theme.spacingMD) {
                        // 音效组
                        settingSection("🔊 音效") {
                            settingToggle("音效", isOn: $soundEnabled)
                            Divider().background(Theme.border)
                            settingToggle("背景音乐", isOn: $musicEnabled)
                            Divider().background(Theme.border)
                            settingToggle("震动反馈", isOn: $hapticEnabled)
                        }

                        // 游戏组
                        settingSection("🎮 游戏") {
                            Button {
                                hasCompletedTutorial = false
                            } label: {
                                HStack {
                                    Text("重置教程")
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(Theme.textTertiary)
                                }
                                .padding(.vertical, 6)
                            }
                        }

                        // 关于
                        settingSection("ℹ️ 关于") {
                            infoRow("版本", value: "0.9.0 MVP")
                            Divider().background(Theme.border)
                            infoRow("引擎", value: "SwiftUI + SpriteKit")
                            Divider().background(Theme.border)
                            infoRow("灵感", value: "Balatro × 斗地主")
                        }
                    }
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.top, Theme.spacingMD)
                    .padding(.bottom, Theme.spacingXXL)
                }
            }
        }
    }

    private func settingSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text(title)
                .font(Theme.fontCaption)
                .foregroundColor(Theme.textTertiary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .padding(Theme.spacingMD)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .fill(Theme.bgCard)
            )
        }
    }

    private func settingToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .font(Theme.fontBody)
            .foregroundColor(Theme.textPrimary)
            .tint(Theme.gold)
            .padding(.vertical, 2)
    }

    private func infoRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(Theme.textPrimary)
            Spacer()
            Text(value)
                .foregroundColor(Theme.textTertiary)
        }
        .font(Theme.fontBody)
        .padding(.vertical, 2)
    }
}

#Preview {
    SettingsView(onBack: {})
}
