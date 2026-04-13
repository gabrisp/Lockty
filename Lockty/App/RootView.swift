//
//  RootView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI
import VariableBlur

struct RootView: View {
    @Environment(AppRouter.self) var router
    @Namespace private var modeZoom
    @State private var mainToolbarStore = MainToolbarStore()

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.navigation.path) {
            ZStack(alignment: .top) {
                TabContainerView()
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        bottomTabBar
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    .navigationDestination(for: NavigationDestination.self) { dest in
                        switch dest {
                        case .sessionDetail(let id):
                            Text("Session Detail \(id)")
                        case .allSessions(let id):
                            Text("All Sessions \(String(describing: id))")
                        case .modeDetail(let mode):
                            ModeDetailView(mode: mode)
                                .environment(router)
                                .navigationTransition(.zoom(sourceID: mode.id, in: modeZoom))
                                .navigationBarBackButtonHidden(true)

                        case .createMode:
                            ModeDetailView()
                                .environment(router)
                                .navigationBarBackButtonHidden(true)
                        }
                    }
                    .environment(\.modeZoomNamespace, modeZoom)

                // Blur overlay
                GeometryReader { geo in
                    VariableBlurView(maxBlurRadius: 16, direction: .blurredTopClearBottom)
                        .frame(height: 54 + geo.safeAreaInsets.top + 8)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
                .frame(height: 0)

                // Header flotante
                // LocktyToolbar(selectedTab: $router.selectedTab, user: router.currentUser ?? .preview) {
                //     router.openSettings()
                // }
                // .padding(.top, 8)
                LocktyToolbar(
                    selectedTab: $router.selectedTab,
                    user: router.currentUser ?? .preview,
                    leadingContent: mainToolbarStore.leadingContent
                ) {
                    router.openSettings()
                }
                .padding(.top, 8)
            }
            .environment(mainToolbarStore)
        }
        .sheet(item: Binding(
            get: { router.sheet.stack.first },
            set: { if $0 == nil { router.sheet.popToRoot() } }
        )) { sheet in
            SheetWrapper(sheet: sheet) {
                SheetFactory.view(for: sheet, user: router.currentUser)
            }
            .environment(router)
        }
    }

    @ViewBuilder
    private var bottomTabBar: some View {
        @Bindable var router = router

        GeometryReader { proxy in
            let tabBarWidth = proxy.size.width * 0.5

            HStack(alignment: .bottom, spacing: 10) {
                GlassEffectContainer(spacing: 10) {
                    HStack(spacing: 10) {
                        GeometryReader { segmentProxy in
                            CustomGlassTabBar(
                                size: segmentProxy.size,
                                activeTint: .primary,
                                inActiveTint: .primary.opacity(0.45),
                                barTint: .gray.opacity(0.3),
                                activeTab: $router.selectedTab
                            ) { tab in
                                Image(systemName: tab.symbol)
                                    .font(.system(size: 18, weight: .semibold))
                                    .symbolVariant(.fill)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .glassEffect(.regular.interactive(), in: .capsule)
                        }
                        .frame(width: tabBarWidth, height: 55)
                    }
                }
                .frame(height: 55)

                Button {
                    switch router.selectedTab {
                    case .modes:
                        router.openCreateMode()
                    case .stats:
                        break
                    }
                } label: {
                    Image(systemName: router.selectedTab.actionSymbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color(.label))
                        .frame(width: 55, height: 55)
                        .glassEffect(.regular.interactive(), in: .capsule)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, BaseTheme.Spacing.lg)
            .padding(.bottom, BaseTheme.Spacing.md)
            .background(.clear)
        }
        .frame(height: 80)
    }
}

#Preview {
    RootView()
        .environment(AppRouter())
}
