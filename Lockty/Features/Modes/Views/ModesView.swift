//
//  ModesView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct ModesView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modeZoomNamespace) private var zoomNamespace
    let activeMode: Mode? = .previewActive
    let inactiveModes: [Mode] = Mode.previewList.filter { $0.state == .inactive }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {

                // MARK: - Active Mode Banner
                if let mode = activeMode {
                    ActiveModeCard(
                        mode: mode,
                        elapsedTime: "02h 44m 02s",
                        trigger: "Manual",
                        onBreak: {},
                        onFinish: {}
                    )
                }

                // MARK: - Inactive Modes Grid
                VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
                    Text("Inactive")
                        .font(Typography.body(weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                        .padding(.horizontal, BaseTheme.Spacing.lg)

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: BaseTheme.Spacing.lg
                    ) {
                        ForEach(inactiveModes) { mode in
                            ModeCard(
                                name: mode.name,
                                icon: mode.iconName,
                                colorHex: mode.colorHex,
                                subtitle: "2 apps"
                            ) {
                                router.navigation.push(.modeDetail(mode: mode))
                            }
                            .ifLet(zoomNamespace) { view, ns in
                                view.matchedTransitionSource(id: mode.id, in: ns) {
                                    $0.background(.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
                                }
                            }
                        }

                        ModeCard(
                            name: "New Mode",
                            icon: "plus",
                            colorHex: "#F2F2F7",
                            subtitle: ""
                        )
                    }
                    .padding(.horizontal, BaseTheme.Spacing.lg)
                }
            }
            .padding(.top, BaseTheme.Spacing.md)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    ModesView()
        .environment(AppRouter())
        .background(Color.pageBackground)
}
