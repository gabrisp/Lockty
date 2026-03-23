//
//  RootView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.navigation.path) {
            TabContainerView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .title) {
                        Text("hyt9johehje09hjeh9jh09ejhe9j0e")
                            .font(.system(size: 40, weight: .semibold))
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .opacity(0)
                    }
                })
                .navigationDestination(for: NavigationDestination.self) { dest in
                    switch dest {
                    case .modeDetail(let id):
                        Text("Mode Detail \(id)")
                    case .sessionDetail(let id):
                        Text("Session Detail \(id)")
                    case .allSessions(let id):
                        Text("All Sessions \(String(describing: id))")
                    }
                }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            LocktyToolbar(selectedTab: $router.selectedTab, user: .preview) {
                router.openSettings()
            }
            .frame(height: 46)
        }

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
