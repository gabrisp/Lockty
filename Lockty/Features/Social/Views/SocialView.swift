//
//  SocialView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct SocialView: View {
    @State private var vm = SocialViewModel()

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {

                // MARK: Inbox row (Requests + Actions)
                HStack(spacing: BaseTheme.Spacing.lg) {
                    SocialInboxCard(
                        title: "Requests",
                        subtitle: "People who want to connect with you",
                        count: vm.requestCount,
                        badgeColor: .red
                    )
                    SocialInboxCard(
                        title: "Actions",
                        subtitle: "Accept or decline requests from your friends",
                        count: vm.actionCount,
                        badgeColor: .orange
                    )
                }
                .padding(.horizontal, BaseTheme.Spacing.lg)

                // MARK: Friends section — header con padding, scroll sin padding lateral
                friendsSection

                // MARK: Recent Activity
                Text("Recent Activity")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
                    .padding(.horizontal, BaseTheme.Spacing.lg)

                activitySection
                    .padding(.horizontal, BaseTheme.Spacing.lg)
            }
            .padding(.top, BaseTheme.Spacing.md)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Friends Section

    private var friendsSection: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
            // Header — con padding lateral
            HStack {
                HStack(alignment: .bottom, spacing: BaseTheme.Spacing.sm) {
                    Text("Friends")
                        .font(Typography.title())
                        .foregroundStyle(Color(.label))

                    Text("\(vm.friends.count)")
                        .font(Typography.caption())
                        .foregroundStyle(Color(.secondaryLabel))
                        .frame(width: BaseTheme.Spacing.xxl, height: BaseTheme.Spacing.xxl)
                        .background(Color(.systemFill))
                        .clipShape(Circle())
                }

                Spacer()

                Button {
                    // TODO: open add friend sheet
                } label: {
                    Image(systemName: "plus")
                        .font(Typography.caption(weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                        .frame(width: BaseTheme.Spacing.xxl, height: BaseTheme.Spacing.xxl)
                        .background(Color(.systemFill))
                        .clipShape(Circle())
                }
                .buttonStyle(NoFlashButtonStyle())
            }
            .padding(.horizontal, BaseTheme.Spacing.lg)

            // Scroll horizontal sin padding lateral — llega a los bordes
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BaseTheme.Spacing.lg) {
                    ForEach(vm.friends) { friend in
                        FriendCard(friend: friend)
                    }
                }
                .padding(.horizontal, BaseTheme.Spacing.lg)
                .padding(.bottom, BaseTheme.Spacing.xs)
            }
        }
    }

    // MARK: - Activity Section

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {
            if let insight = vm.aiInsight {
                HStack(alignment: .top, spacing: BaseTheme.Spacing.sm) {
                    Text(insight)
                        .font(Typography.caption(weight: .medium))
                        .foregroundStyle(Color(.label))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AIBadge()
                }
                .padding(BaseTheme.Spacing.lg)
                .background(Color.innerBackground)
                .locktyRadius(BaseTheme.Radius.md)
            }

            ForEach(Array(vm.recentActivity.enumerated()), id: \.offset) { i, event in
                ActivityRow(
                    event: event,
                    showDivider: i < vm.recentActivity.count - 1
                )
            }
        }
        .padding(BaseTheme.Spacing.lg)
        .background(Color.cardBackground)
        .locktyRadius(BaseTheme.Radius.card)
    }
}

#Preview {
    SocialView()
        .background(Color.pageBackground)
}
