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
    @State private var showTutorialResetBanner = false

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
                            .accessibilityLabel("帮助与常见问题")
                            .accessibilityHint("查看游戏帮助和FAQ")
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
                                    .accessibilityLabel("音量")
                                    .accessibilityValue("\(Int(soundVolume * 100))%")
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
                                // 同步清除旧版迁移标记，否则 TutorialManager.init 会把 tutorialPhase 覆盖回 3
                                UserDefaults.standard.removeObject(forKey: "hasCompletedTutorial")
                                withAnimation { showTutorialResetBanner = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation { showTutorialResetBanner = false }
                                }
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
                            .accessibilityLabel("重置新手引导")
                            .accessibilityHint("双击重新开始新手教程")
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

                        // 开发者工具（仅 Debug 构建可见）
                        #if DEBUG
                        settingSection("🛠 开发者工具") {
                            NavigationLink {
                                IconExporterView()
                            } label: {
                                HStack {
                                    Image(systemName: "app.badge.fill")
                                        .foregroundColor(Theme.gold)
                                    Text("导出 App Icon (1024×1024)")
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Theme.textTertiary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        #endif

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

                        // Share
                        settingSection(L10n.isEnglish ? "Spread the Word" : "分享给好友") {
                            Button {
                                shareApp()
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up.fill")
                                        .foregroundColor(Theme.cyan)
                                    Text(L10n.isEnglish ? "Share with Friends" : "推荐给朋友")
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Theme.textTertiary)
                                }
                                .padding(.vertical, 6)
                            }
                        }

                        // Rate & Privacy
                        settingSection(L10n.isEnglish ? "Support Us" : "支持我们") {
                            Button {
                                ReviewManager.shared.requestReviewNow()
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Theme.gold)
                                    Text(L10n.isEnglish ? "Rate on App Store" : "App Store 评分")
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Theme.textTertiary)
                                }
                                .padding(.vertical, 6)
                            }
                            Divider().background(Theme.border)
                            Link(destination: URL(string: "https://skylly1.github.io/doudizhu-privacy")!) {
                                HStack {
                                    Image(systemName: "hand.raised.fill")
                                        .foregroundColor(Theme.textSecondary)
                                    Text(L10n.isEnglish ? "Privacy Policy" : "隐私政策")
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(Theme.textTertiary)
                                }
                                .padding(.vertical, 6)
                            }
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

            // 重置成功横幅（引导提示）
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

            // 重置成功横幅（教程）
            if showTutorialResetBanner {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.success)
                        Text(L10n.isEnglish ? "Tutorial reset!" : "教程已重置！")
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

    // MARK: - Share

    private func shareApp() {
        let text = L10n.isEnglish
            ? "I'm playing this awesome Doudizhu Roguelike card game! 🃏"
            : "我在玩一款超好玩的斗地主Roguelike卡牌游戏！🃏"
        // Replace with actual App Store URL after launch
        let url = URL(string: "https://apps.apple.com/app/id000000000")!
        let items: [Any] = [text, url]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            // iPad support
            ac.popoverPresentationController?.sourceView = root.view
            ac.popoverPresentationController?.sourceRect = CGRect(x: root.view.bounds.midX, y: root.view.bounds.midY, width: 0, height: 0)
            root.present(ac, animated: true)
        }
        Analytics.shared.track(.shareApp, params: ["source": "settings"])
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
            UserDefaults.standard.removeObject(forKey: "hasCompletedTutorial")
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
                .accessibilityAddTraits(.isHeader)

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
            .accessibilityHint("双击切换开关")
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
                        .foregroundColor(Theme.danger)
                    Text(subtitle)
                        .font(Theme.fontCaption)
                        .foregroundColor(Theme.textTertiary)
                }
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(Theme.danger.opacity(0.6))
            }
            .padding(.vertical, 4)
        }
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }
}

#Preview {
    SettingsView(onBack: {})
}
