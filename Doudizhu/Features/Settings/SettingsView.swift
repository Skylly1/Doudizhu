import SwiftUI

struct SettingsView: View {
    let onBack: () -> Void
    var onNavigateHelp: (() -> Void)? = nil

    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("soundVolume") private var soundVolume: Double = 0.5
    @AppStorage("tutorialPhase") private var tutorialPhase: Int = 0
    @State private var showResetConfirm = false
    @State private var resetTarget: ResetTarget? = nil
    @State private var showHelpSheet = false
    @State private var showHintResetBanner = false

    private enum ResetTarget: Identifiable {
        case saves, stats, all
        var id: String {
            switch self {
            case .saves: return "saves"
            case .stats: return "stats"
            case .all: return "all"
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                GameNavBar(title: L10n.settings, onBack: onBack)

                ScrollView {
                    VStack(spacing: Theme.spacingMD) {
                        // 帮助与FAQ — 最顶部，方便找到
                        settingSection(L10n.helpAndFaq) {
                            Button {
                                showHelpSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "questionmark.circle.fill")
                                        .foregroundColor(Theme.gold)
                                    Text(L10n.helpAndFaq)
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Theme.textTertiary)
                                }
                                .padding(.vertical, 6)
                            }
                        }

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
                            Divider().background(Theme.border)
                            Button {
                                ContextualHintManager.shared.resetAll()
                                // 重置商店/Joker引导
                                UserDefaults.standard.removeObject(forKey: "hasSeenShopIntro")
                                UserDefaults.standard.removeObject(forKey: "hasSeenFirstJokerGuide")
                                withAnimation { showHintResetBanner = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation { showHintResetBanner = false }
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(L10n.resetContextHints)
                                            .foregroundColor(Theme.textPrimary)
                                        Text(L10n.resetContextHintsDesc)
                                            .font(Theme.fontCaption)
                                            .foregroundColor(Theme.textTertiary)
                                    }
                                    Spacer()
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(Theme.textTertiary)
                                }
                                .padding(.vertical, 4)
                            }
                        }

                        // 数据管理
                        settingSection(L10n.dataManagement) {
                            dangerButton(
                                title: L10n.clearSaveData,
                                subtitle: L10n.clearSaveDataDesc,
                                icon: "trash"
                            ) {
                                resetTarget = .saves
                            }
                            Divider().background(Theme.border)
                            dangerButton(
                                title: L10n.resetStats,
                                subtitle: L10n.resetStatsDesc,
                                icon: "chart.bar.xaxis"
                            ) {
                                resetTarget = .stats
                            }
                            Divider().background(Theme.border)
                            dangerButton(
                                title: L10n.resetAllData,
                                subtitle: L10n.resetAllDataDesc,
                                icon: "exclamationmark.triangle.fill"
                            ) {
                                resetTarget = .all
                            }
                        }

                        // 关于
                        settingSection(L10n.settingsAbout) {
                            infoRow(L10n.settingsVersion, value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0")
                            Divider().background(Theme.border)
                            infoRow(L10n.settingsEngine, value: "SwiftUI + SpriteKit")
                            Divider().background(Theme.border)
                            infoRow(L10n.settingsInspiration, value: L10n.isEnglish ? "Balatro × Doudizhu" : "Balatro × 斗地主")
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

            // 重置成功横幅
            if showHintResetBanner {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.success)
                        Text(L10n.hintResetDone)
                            .font(.subheadline.bold())
                            .foregroundColor(Theme.textPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Theme.bgPrimary.opacity(0.95)))
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                    .padding(.top, 80)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
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
        .sheet(isPresented: $showHelpSheet) {
            HelpView(onBack: { showHelpSheet = false })
        }
        .alert(
            L10n.confirmReset,
            isPresented: Binding(
                get: { resetTarget != nil },
                set: { if !$0 { resetTarget = nil } }
            )
        ) {
            Button(L10n.cancel, role: .cancel) { resetTarget = nil }
            Button(L10n.confirmReset, role: .destructive) {
                performReset()
            }
        } message: {
            switch resetTarget {
            case .saves:
                Text(L10n.clearSaveDataDesc)
            case .stats:
                Text(L10n.resetStatsDesc)
            case .all:
                Text(L10n.resetAllDataDesc)
            case .none:
                Text("")
            }
        }
    }

    // MARK: - 重置操作

    private func performReset() {
        guard let target = resetTarget else { return }
        switch target {
        case .saves:
            SaveManager.shared.clearAllSaves()
        case .stats:
            PlayerStats.shared.resetAll()
        case .all:
            SaveManager.shared.clearAllSaves()
            PlayerStats.shared.resetAll()
            AchievementTracker.shared.resetAll()
            PatternUpgradeManager.shared.resetAll()
            ContextualHintManager.shared.resetAll()
            tutorialPhase = 0
            UserDefaults.standard.removeObject(forKey: "hasSeenShopIntro")
            UserDefaults.standard.removeObject(forKey: "hasSeenFirstJokerGuide")
        }
        resetTarget = nil
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

    private func dangerButton(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(.red.opacity(0.9))
                    Text(subtitle)
                        .font(Theme.fontCaption)
                        .foregroundColor(Theme.textTertiary)
                }
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(.red.opacity(0.6))
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    SettingsView(onBack: {})
}
