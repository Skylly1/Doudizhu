import SwiftUI

struct ContentView: View {
    @State private var currentScreen: AppScreen = .home
    @StateObject private var rogueRun = RogueRun()
    @StateObject private var tutorialManager = TutorialManager()

    var body: some View {
        ZStack {
            Group {
                switch currentScreen {
                case .home:
                    HomeView(onNavigate: { currentScreen = $0 })
                case .buildSelect:
                    BuildSelectView(onSelect: { build in
                        rogueRun.startWithBuild(build)
                        currentScreen = .battle
                        tutorialManager.startIfNeeded()
                    }, onBack: {
                        currentScreen = .map
                    })
                case .battle:
                    BattleView(
                        rogueRun: rogueRun,
                        onBack: { currentScreen = .home },
                        onShop: { currentScreen = .shop }
                    )
                    .onChange(of: rogueRun.phase) { _, newPhase in
                        if newPhase == .shopping {
                            currentScreen = .shop
                        }
                    }
                case .shop:
                    ShopView(rogueRun: rogueRun) {
                        rogueRun.leaveShop()
                        currentScreen = .battle
                    }
                case .map:
                    MapView(onStart: {
                        currentScreen = .buildSelect
                    }, onBack: { currentScreen = .home })
                case .collection:
                    CollectionView(onBack: { currentScreen = .home })
                case .settings:
                    SettingsView(onBack: { currentScreen = .home })
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentScreen)

            // 教程覆盖层
            TutorialOverlay(manager: tutorialManager)
                .animation(.easeInOut, value: tutorialManager.currentStep != nil)
        }
    }
}

enum AppScreen: Hashable {
    case home
    case buildSelect
    case battle
    case shop
    case map
    case collection
    case settings
}

#Preview {
    ContentView()
}
