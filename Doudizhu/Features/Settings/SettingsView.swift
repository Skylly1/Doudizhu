import SwiftUI

struct SettingsView: View {
    let onBack: () -> Void

    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("soundVolume") private var soundVolume: Double = 0.5
    @AppStorage("tutorialPhase") private var tutorialPhase: Int = 0

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                GameNavBar(title: L10n.settings, onBack: onBack)

                ScrollView {
                    VStack(spacing: Theme.spacingMD) {
                        // 音效组
                        settingSection(L10n.settingsSound) {
                            settingToggle(L10n.settingsSoundEffect, isOn: $soundEnabled)
                            Divider().background(Theme.border)
                            HStack {
                                Text(L10n.settingsVolume)
                                    .font(Theme.fontBody)
                                    .foregroundColor(Theme.textPrimary)
                                Slider(value: $soundVolume, in: 0...1, step: 0.05)
                                    .tint(Theme.gold)
                                    .disabled(!soundEnabled)
                            }
                            .padding(.vertical, 2)
                            Divider().background(Theme.border)
                            settingToggle(L10n.settingsMusic, isOn: $musicEnabled)
                            Divider().background(Theme.border)
                            settingToggle(L10n.settingsHaptic, isOn: $hapticEnabled)
                        }

                        // 游戏组
                        settingSection(L10n.settingsGame) {
                            Button {
                                tutorialPhase = 0
                            } label: {
                                HStack {
                                    Text(L10n.resetTutorial)
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(Theme.textTertiary)
                                }
                                .padding(.vertical, 6)
                            }
                        }

                        // 关于
                        settingSection(L10n.settingsAbout) {
                            infoRow(L10n.settingsVersion, value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0")
                            Divider().background(Theme.border)
                            infoRow(L10n.settingsEngine, value: "SwiftUI + SpriteKit")
                            Divider().background(Theme.border)
                            infoRow(L10n.settingsInspiration, value: "Balatro × Doudizhu")
                        }

                        // 语言
                        settingSection(L10n.settingsLanguage) {
                            HStack {
                                Text(L10n.settingsCurrentLang)
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                            }
                            .font(Theme.fontBody)
                            .padding(.vertical, 2)
                            Text(L10n.settingsLanguageHint)
                                .font(Theme.fontCaption)
                                .foregroundColor(Theme.textTertiary)
                        }
                    }
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.top, Theme.spacingMD)
                    .padding(.bottom, Theme.spacingMD)

                    // Version info
                    Text(L10n.versionString)
                        .font(Theme.fontCaption)
                        .foregroundColor(Theme.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, Theme.spacingXXL)
                }
            }
        }
        .gameBackground()
        .onChange(of: soundEnabled) { _, newValue in
            SoundManager.shared.isEnabled = newValue
        }
        .onChange(of: soundVolume) { _, newValue in
            SoundManager.shared.volume = Float(newValue)
        }
        .onChange(of: musicEnabled) { _, newValue in
            if newValue {
                SoundManager.shared.startBGM()
            } else {
                SoundManager.shared.stopBGM()
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
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusMD)
                            .stroke(Theme.gold.opacity(0.1), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
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
