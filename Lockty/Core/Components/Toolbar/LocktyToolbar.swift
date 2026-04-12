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

    @State private var appeared = false

    var body: some View {
        let tabs = AppRouter.Tab.allCases
        HStack(alignment: .bottom, spacing: 16) {
            ForEach(Array(tabs.enumerated()), id: \.element) { index, tab in
                Button {
                    withAnimation(.snappy) { selectedTab = tab }
                } label: {
                    Text(tab.label)
                        .font(.system(size: 26, weight: .semibold))
                        .opacity(tab == selectedTab ? 1.0 : 0.5)
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
                .opacity(appeared ? 1 : 0)
                .blur(radius: appeared ? 0 : 12)
                .animation(.snappy(duration: 0.6, extraBounce: 0.02).delay(Double(index) * 0.12), value: appeared)
            }

            Spacer()

            AvatarView(name: user.displayName, size: .toolbar, action: onAvatarTap)
                .opacity(appeared ? 1 : 0)
                .blur(radius: appeared ? 0 : 12)
                .animation(.easeOut(duration: 0.6).delay(Double(tabs.count) * 0.12), value: appeared)
        }
        .frame(height: 46)
        .padding(.horizontal, BaseTheme.Spacing.lg)
        .onAppear { appeared = true }
    }
}

#Preview {
    @Previewable @State var selectedTab: AppRouter.Tab = .modes
    LocktyToolbar(selectedTab: $selectedTab, user: .preview) {}  // LocalUser.preview
        .locktyPageBackground()
}
