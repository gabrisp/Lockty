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
            RootTabView()
                .withNavigationDestinations()
                .navigationBarBackButtonHidden(true)
               
                //.toolbar(.hidden, for: .navigationBar)
                //.navigationTitle("heyyy")
               // .navigationBarTitleDisplayMode(.inline)
              .safeAreaInset(edge: VerticalEdge.top) {
                    RootToolbar(user: router.currentUser)
                }
               // .scrollEdgeEffectStyle(.soft, for: .all)
        }
        .enableInteractivePopGesture()
        .withSheet()
    }
}

// MARK: - Sheet

fileprivate struct SheetModifier: ViewModifier {
    @Environment(AppRouter.self) var router

    func body(content: Content) -> some View {
        content.sheet(item: Binding(
            get: { router.sheet.stack.first },
            set: { if $0 == nil { router.sheet.popToRoot() } }
        )) { sheet in
            SheetWrapperView(sheet: sheet) {
                SheetFactory.view(for: sheet, user: router.currentUser)
            }
        }
    }
}

// MARK: - Navigation Destinations

fileprivate struct NavigationDestinationsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.navigationDestination(for: NavigationDestination.self) { dest in
            switch dest {
            case .sessionDetail(let id):
                Text("Session Detail \(id)")
                    .navigationBarBackButtonHidden(true)
            case .allSessions(let id):
                Text("All Sessions \(String(describing: id))")
                    .navigationBarBackButtonHidden(true)
            case .modeDetail(let mode):
                ModeDetailView(mode: mode)
                    .navigationBarBackButtonHidden(true)
            case .createMode:
                ModeDetailView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

// MARK: - View Extensions

fileprivate extension View {
    func withNavigationDestinations() -> some View { modifier(NavigationDestinationsModifier()) }
    func withSheet() -> some View { modifier(SheetModifier()) }
}

// MARK: - Preview

#Preview {
    RootView()
        .environment(AppRouter.shared)
}
