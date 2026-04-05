//
//  ModeDetailView.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

struct ModeDetailView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var vm: ModeDetailViewModel
    @State private var isPresented = false

    init(mode: Mode) {
        _vm = State(initialValue: ModeDetailViewModel(mode: mode))
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: BaseTheme.Spacing.lg) {

                // MARK: Hero — icon + name + dismiss
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
            .padding(.top, BaseTheme.Spacing.md)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .background(Color.pageBackground.ignoresSafeArea())
        .onAppear { withAnimation(.spring(duration: 0.35)) { isPresented = true } }
    }

    // MARK: - Hero

    private var hero: some View {
        ZStack(alignment: .topLeading) {
            // Dismiss button — top left
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .font(Typography.body(weight: .semibold))
                    .foregroundStyle(Color(.secondaryLabel))
                    .frame(width: BaseTheme.Spacing.xxl * 1.5, height: BaseTheme.Spacing.xxl * 1.5)
                    .background(Color.cardBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(NoFlashButtonStyle())

            // Centered icon + name
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
        colorHex: "#E8F5E9", state: .inactive, createdAt: .now
    ))
    .environment(AppRouter())
}
