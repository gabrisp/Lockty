//
//  ModeDetailView.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI
import VariableBlur

struct ModeDetailView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var vm: ModeDetailViewModel
    @State private var isPresented = false
    @State private var dragOffset: CGFloat = 0

    init(mode: Mode) {
        _vm = State(initialValue: ModeDetailViewModel(mode: mode))
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical) {
                VStack(spacing: BaseTheme.Spacing.lg) {

                    // MARK: Hero — icon + name
                    hero
                        .padding(.horizontal, BaseTheme.Spacing.lg)

                    // MARK: Segmented control (native)
                    Picker("", selection: $vm.selectedTab) {
                        ForEach(ModeDetailViewModel.ModeDetailTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, BaseTheme.Spacing.lg)

                    // MARK: Tab content
                    switch vm.selectedTab {
                    case .overview:
                        overviewContent
                    case .stats:
                        Text("Stats coming soon")
                            .font(Typography.caption())
                            .foregroundStyle(Color(.secondaryLabel))
                            .frame(maxWidth: .infinity)
                            .padding(.top, BaseTheme.Spacing.xxl)
                            .padding(.horizontal, BaseTheme.Spacing.lg)
                    }
                }
                .padding(.top, 54 + BaseTheme.Spacing.md)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
            .background(Color.pageBackground.ignoresSafeArea())

            // Blur overlay
            GeometryReader { geo in
                VariableBlurView(maxBlurRadius: 16, direction: .blurredTopClearBottom)
                    .frame(height: 54 + geo.safeAreaInsets.top + 8)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            .frame(height: 0)

            // Back button flotante
            HStack{
                Button {
                    router.navigation.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(.label))
                        .frame(width: 46, height: 46)
                }
                .buttonStyle(.glass)
                
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(BaseTheme.Spacing.md)
        }
        .offset(y: max(dragOffset, 0))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    if value.translation.height > 100 || value.predictedEndTranslation.height > 220 {
                        router.navigation.pop()
                    } else {
                        withAnimation(.spring(duration: 0.3)) { dragOffset = 0 }
                    }
                }
        )
        .onAppear { withAnimation(.spring(duration: 0.35)) { isPresented = true } }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: BaseTheme.Spacing.sm) {
            RoundedRectangle(cornerRadius: BaseTheme.Radius.card)
                .fill(Color(hex: vm.mode.colorHex))
                .frame(width: 80, height: 80)
                .overlay {
                    Image(systemName: vm.mode.iconName)
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(Color(.label))
                }
                .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: 4)

            Text(vm.mode.name)
                .font(Typography.title())
                .foregroundStyle(Color(.label))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, BaseTheme.Spacing.sm)
    }

    // MARK: - Overview content

    @ViewBuilder
    private var overviewContent: some View {
        BlockedAppGrid(
            apps: vm.blockedApps,
            insight: vm.blockedAppsInsight
        )
        .padding(.horizontal, BaseTheme.Spacing.lg)

        RulesCard(
            groups: vm.ruleGroups,
            insight: vm.rulesInsight
        )
        .padding(.horizontal, BaseTheme.Spacing.lg)
    }
}

// MARK: - Preview

#Preview {
    ModeDetailView(mode: Mode(
        id: UUID(), name: "Gym", iconName: "figure.run",
        colorHex: "#E8F5E9", state: ModeState.inactive.rawValue, createdAt: .now
    ))
    .environment(AppRouter())
}
