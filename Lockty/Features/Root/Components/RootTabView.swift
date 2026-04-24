//
//  RootTabView.swift
//  Lockty
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        @Bindable var router = AppRouter.shared
        TabView(selection: $router.selectedTab) {
            Tab(value: AppRouter.Tab.modes) {
                ModesView()
                    .environment(AppRouter.shared)
                    .toolbarVisibility(.hidden, for: .tabBar)
            }
            Tab(value: AppRouter.Tab.stats) {
                StatsView()
                    .environment(AppRouter.shared)
                    .toolbarVisibility(.hidden, for: .tabBar)
            }
        }
    }
}
