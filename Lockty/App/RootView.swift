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

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.navigation.path) {
            ZStack(alignment: .top) {
                TabContainerView()
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
                LocktyToolbar(selectedTab: $router.selectedTab, user: router.currentUser ?? .preview) {
                    router.openSettings()
                }
                .padding(.top, 8)
            }
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
}

#Preview {
    RootView()
        .environment(AppRouter())
}
