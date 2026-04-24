import SwiftUI

struct ContentView: View {
    @State private var currentScreen: AppScreen = .home
    @StateObject private var rogueRun = RogueRun()

    var body: some View {
        Group {
            switch currentScreen {
            case .home:
                HomeView(onNavigate: { currentScreen = $0 })
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
                    rogueRun.restart()
                    currentScreen = .battle
                }, onBack: { currentScreen = .home })
            case .collection:
                CollectionView(onBack: { currentScreen = .home })
            case .settings:
                SettingsView(onBack: { currentScreen = .home })
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentScreen)
    }
}

enum AppScreen: Hashable {
    case home
    case battle
    case shop
    case map
    case collection
    case settings
}

#Preview {
    ContentView()
}
