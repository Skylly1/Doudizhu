import SwiftUI

struct ContentView: View {
    @State private var currentScreen: AppScreen = .home

    var body: some View {
        Group {
            switch currentScreen {
            case .home:
                HomeView(onNavigate: { currentScreen = $0 })
            case .battle:
                BattleView(onBack: { currentScreen = .home })
            case .map:
                MapView(onNavigate: { currentScreen = $0 },
                        onBack: { currentScreen = .home })
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
    case map
    case collection
    case settings
}

#Preview {
    ContentView()
}
