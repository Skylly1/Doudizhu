import SwiftUI

struct ContentView: View {
    @State private var currentScreen: AppScreen = .home
    @StateObject private var rogueRun = RogueRun()
    @StateObject private var tutorialManager = TutorialManager()
    @StateObject private var purchaseManager = PurchaseManager.shared

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
                        // Demo 门禁：过关后检查是否超出试玩范围
                        if newPhase == .floorWin,
                           !purchaseManager.canAccessFloor(rogueRun.currentFloorIndex + 1) {
                            currentScreen = .demoGate
                        }
                    }
                case .shop:
                    ShopView(rogueRun: rogueRun) {
                        rogueRun.leaveShop()
                        currentScreen = .battle
                    }
                case .demoGate:
                    DemoGateView(
                        purchaseManager: purchaseManager,
                        onContinue: {
                            // 购买成功后继续
                            rogueRun.advanceToNextFloor()
                            currentScreen = .battle
                        },
                        onBack: { currentScreen = .home }
                    )
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
            .animation(.easeInOut(duration: 0.35), value: currentScreen)
            .transition(.opacity.combined(with: .scale(scale: 0.97)))

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
    case demoGate
    case map
    case collection
    case settings
}

#Preview {
    ContentView()
}
