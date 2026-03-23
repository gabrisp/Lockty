//
//  TabContainerView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct TabContainerView: View {
    @Environment(AppRouter.self) var router

    @State private var scrolledTab: AppRouter.Tab? = .modes

    var body: some View {
        @Bindable var router = router

        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ModesView()
                        .id(AppRouter.Tab.modes)
                        .containerRelativeFrame(.horizontal)

                    StatsView()
                        .id(AppRouter.Tab.stats)
                        .containerRelativeFrame(.horizontal)

                    SocialView()
                        .id(AppRouter.Tab.social)
                        .containerRelativeFrame(.horizontal)
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $scrolledTab)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .scrollClipDisabled()
            .onChange(of: scrolledTab) { _, tab in
                if let tab { router.selectedTab = tab }
            }
            .onChange(of: router.selectedTab) { _, tab in
                guard tab != scrolledTab else { return }
                withAnimation(.snappy) { proxy.scrollTo(tab, anchor: .leading) }
            }
        }
    }
}
