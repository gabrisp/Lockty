//
//  RootView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) var router
    @Namespace private var modeZoom

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.navigation.path) {
            ZStack {
                TabContainerView()
                    .navigationBarTitleDisplayMode(.inline)
                 
                 

            }
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
                }
            }
            .environment(\.modeZoomNamespace, modeZoom)
        }
        .safeAreaInset(edge: .top, content: {
            if router.navigation.path.isEmpty {
                LocktyToolbar(selectedTab: $router.selectedTab, user: .preview) {
                    router.openSettings()
                }
                .transition(.blurReplace)
            }
        })
        .sheet(item: Binding(
            get: { router.sheet.stack.first },
            set: { if $0 == nil { router.sheet.popToRoot() } }
        )) { sheet in
            SheetWrapper(sheet: sheet) {
                SheetFactory.view(for: sheet)
            }
            .environment(router)
        }
    }
}

#Preview {
    RootView()
        .environment(AppRouter())
}
