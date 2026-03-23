//
//  TabContainerView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct TabContainerView: View {
    @Environment(AppRouter.self) var router

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
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .scrollClipDisabled()
            .onChange(of: router.selectedTab) { _, tab in
                withAnimation(.snappy) {
                    proxy.scrollTo(tab, anchor: .leading)
                }
            }
        }
    }
}
