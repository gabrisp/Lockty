//
//  LocktyToolbar.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct LocktyToolbar: View {
    @Binding var selectedTab: AppRouter.Tab
    let user: LocalUser
    var onAvatarTap: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            ForEach(AppRouter.Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.snappy) { selectedTab = tab }
                } label: {
                    Text(tab.label)
                        .font(.system(size: 26, weight: .semibold))
                        .opacity(tab == selectedTab ? 1.0 : 0.5)
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }

            Spacer()

            AvatarView(name: user.displayName, size: .toolbar, action: onAvatarTap)
        }
        .frame(height: 46)
        .padding(.horizontal, BaseTheme.Spacing.lg)
    }
}

#Preview {
    @Previewable @State var selectedTab: AppRouter.Tab = .modes
    LocktyToolbar(selectedTab: $selectedTab, user: .preview) {}  // LocalUser.preview
        .locktyPageBackground()
}
