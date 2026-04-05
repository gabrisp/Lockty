//
//  TabContainerView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct TabContainerView: View {
    @Environment(AppRouter.self) var router
    @State private var tabProgress: CGFloat = 0
    
    var body: some View {
        
        @Bindable var router = router
    
     

        GeometryReader {
            let size = $0.size

            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ModesView()
                        .id(AppRouter.Tab.modes)
                        .containerRelativeFrame(.horizontal)
                        .environment(router)

                    StatsView()
                        .id(AppRouter.Tab.stats)
                        .containerRelativeFrame(.horizontal)
                        .environment(router)

                    SocialView()
                        .id(AppRouter.Tab.social)
                        .containerRelativeFrame(.horizontal)
                        .environment(router)
                }
                .scrollTargetLayout()
                .offsetX { value in
                    /// Converting Offset into Progress
                    let progress = -value / (size.width * CGFloat(AppRouter.Tab.allCases.count - 1))
                    /// Capping Progress BTW 0-1
                    tabProgress = max(min(progress, 1), 0)
                }
            }
        }
        .scrollPosition(id: Binding(
        get: {
            router.selectedTab
        },
        set: { if let tab = $0 {
                router.selectedTab = tab
            }
        }))
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollClipDisabled()
        }
    
}
