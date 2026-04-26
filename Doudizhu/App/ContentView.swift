import SwiftUI

struct ContentView: View {
    @State private var currentScreen: AppScreen = .home
    /// 导航历史栈：支持多层返回
    @State private var navigationStack: [AppScreen] = []
    @StateObject private var rogueRun = RogueRun()
    @StateObject private var tutorialManager = TutorialManager()
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - 导航方法

    /// 压栈导航：将当前页面入栈，跳转到目标页面
    private func navigate(to screen: AppScreen) {
        navigationStack.append(currentScreen)
        currentScreen = screen
    }

    /// 弹栈返回：回到上一个页面（栈空则回首页）
    private func goBack() {
        if let previous = navigationStack.popLast() {
            currentScreen = previous
        } else {
            currentScreen = .home
        }
    }

    /// 清栈回首页：退出战斗等场景时直接回到首页
    private func goHome() {
        navigationStack.removeAll()
        currentScreen = .home
    }

    var body: some View {
        ZStack {
            Group {
                switch currentScreen {
                case .home:
                    HomeView(
                        hasSavedGame: rogueRun.hasSavedRun,
                        onNavigate: { screen in
                            if screen == .map && PlayerStats.shared.totalRuns == 0 {
                                rogueRun.startWithBuild(StarterBuild.allBuilds.first!)
                                navigate(to: .battle)
                                tutorialManager.startIfNeeded()
                            } else {
                                navigate(to: screen)
                            }
                        },
                        onContinue: {
                            if rogueRun.restoreFromSave() {
                                navigate(to: .battle)
                            }
                        }
                    )
                case .buildSelect:
                    BuildSelectView(onSelect: { build in
                        rogueRun.startWithBuild(build)
                        navigate(to: .battle)
                        tutorialManager.startIfNeeded()
                    }, onBack: {
                        goBack()
                    })
                    .swipeBack { goBack() }
                case .dailyChallenge:
                    DailyChallengeView(
                        onStart: { challenge in
                            rogueRun.startDailyChallenge(challenge)
                            navigate(to: .battle)
                        },
                        onBack: { goBack() }
                    )
                    .swipeBack { goBack() }
                case .battle:
                    BattleView(
                        rogueRun: rogueRun,
                        onBack: {
                            SoundManager.shared.stopBGM()
                            goHome()
                        },
                        onShop: { navigate(to: .shop) }
                    )
                    .onChange(of: rogueRun.phase) { _, newPhase in
                        if newPhase == .shopping {
                            navigate(to: .shop)
                        }
                        if newPhase == .floorWin,
                           !purchaseManager.canAccessFloor(rogueRun.currentFloorIndex + 1) {
                            navigate(to: .demoGate)
                        }
                    }
                case .shop:
                    ShopView(rogueRun: rogueRun, onLeave: {
                        rogueRun.leaveShop()
                        goBack()
                    }, onQuit: {
                        SoundManager.shared.stopBGM()
                        goHome()
                    })
                    .onAppear {
                        SoundManager.shared.startBGM(mode: .shop)
                    }
                    .swipeBack {
                        rogueRun.leaveShop()
                        goBack()
                    }
                case .demoGate:
                    DemoGateView(
                        purchaseManager: purchaseManager,
                        onContinue: {
                            rogueRun.advanceToNextFloor()
                            goBack()
                        },
                        onBack: {
                            SoundManager.shared.stopBGM()
                            goHome()
                        }
                    )
                    .swipeBack {
                        SoundManager.shared.stopBGM()
                        goHome()
                    }
                case .map:
                    MapView(onStart: {
                        navigate(to: .buildSelect)
                    }, onBack: { goBack() })
                    .swipeBack { goBack() }
                case .collection:
                    CollectionView(onBack: { goBack() })
                        .swipeBack { goBack() }
                case .settings:
                    SettingsView(onBack: { goBack() })
                        .swipeBack { goBack() }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: currentScreen)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.95)).combined(with: .offset(y: 8)),
                removal: .opacity.combined(with: .scale(scale: 1.02))
            ))

            // 教程覆盖层
            TutorialOverlay(manager: tutorialManager)
                .animation(.easeInOut, value: tutorialManager.currentStep != nil)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                if currentScreen == .battle {
                    SaveManager.shared.save(run: rogueRun, buildId: "")
                }
            }
        }
    }
}

// MARK: - 右滑返回手势

private struct SwipeBackModifier: ViewModifier {
    let action: () -> Void
    @State private var dragOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: dragOffset)
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .global)
                    .onChanged { value in
                        // 仅在从左边缘开始的右滑才生效
                        if value.startLocation.x < 40 && value.translation.width > 0 {
                            dragOffset = value.translation.width * 0.4
                        }
                    }
                    .onEnded { value in
                        if value.startLocation.x < 40 && value.translation.width > 80 {
                            FeedbackManager.shared.buttonTap()
                            action()
                        }
                        withAnimation(.spring(response: 0.25)) {
                            dragOffset = 0
                        }
                    }
            )
    }
}

extension View {
    func swipeBack(_ action: @escaping () -> Void) -> some View {
        modifier(SwipeBackModifier(action: action))
    }
}

enum AppScreen: Hashable {
    case home
    case buildSelect
    case dailyChallenge
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
