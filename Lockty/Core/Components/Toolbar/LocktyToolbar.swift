//
//  LocktyToolbar.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import UIKit
import SwiftUI

struct LocktyToolbar: UIViewRepresentable {
    @Binding var selectedTab: AppRouter.Tab
    let user: User
    var onAvatarTap: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolbar.isTranslucent = true

        context.coordinator.build(
            toolbar: toolbar,
            user: user,
            selectedTab: selectedTab,
            onTabSelected: { tab in selectedTab = tab },
            onAvatarTap: onAvatarTap
        )

        return toolbar
    }

    func updateUIView(_ toolbar: UIToolbar, context: Context) {
        context.coordinator.updateAlphas(selectedTab: selectedTab)
    }
}

// MARK: - Coordinator

extension LocktyToolbar {
    final class Coordinator {
        var tabButtons: [AppRouter.Tab: UIButton] = [:]
        private var avatarHost: UIHostingController<AvatarView>?

        func build(
            toolbar: UIToolbar,
            user: User,
            selectedTab: AppRouter.Tab,
            onTabSelected: @escaping (AppRouter.Tab) -> Void,
            onAvatarTap: @escaping () -> Void
        ) {
            let tabStack = UIStackView()
            tabStack.axis = .horizontal
            tabStack.spacing = 16
            tabStack.alignment = .bottom
            tabStack.distribution = .fill
            tabStack.translatesAutoresizingMaskIntoConstraints = false
            
            for tab in AppRouter.Tab.allCases {
                let btn = UIButton(type: .custom)
                btn.setTitle(tab.label, for: .normal)
                btn.titleLabel?.font = roundedFont(size: 26, weight: .semibold)
                btn.setTitleColor(.label, for: .normal)
                btn.contentHorizontalAlignment = .center
                btn.contentVerticalAlignment = .bottom
                btn.alpha = tab == selectedTab ? 1.0 : 0.5

                let captured = tab
                btn.addAction(UIAction { _ in onTabSelected(captured) }, for: .touchUpInside)

                tabButtons[tab] = btn
                tabStack.addArrangedSubview(btn)
            }

            toolbar.addSubview(tabStack)

            NSLayoutConstraint.activate([
                tabStack.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 16),
                tabStack.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: 0),
            ])

            let avatarView = AvatarView(name: user.displayName, size: .toolbar, action: onAvatarTap)
            let host = UIHostingController(rootView: avatarView)
            host.view.backgroundColor = .clear
            avatarHost = host

            toolbar.items = [.flexibleSpace(), UIBarButtonItem(customView: host.view)]
        }

        func updateAlphas(selectedTab: AppRouter.Tab) {
            UIView.animate(withDuration: 0.2) {
                for (tab, btn) in self.tabButtons {
                    btn.alpha = tab == selectedTab ? 1.0 : 0.5
                }
            }
        }

        private func roundedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
            let base = UIFont.systemFont(ofSize: size, weight: weight)
            let descriptor = base.fontDescriptor.withDesign(.default) ?? base.fontDescriptor
            return UIFont(descriptor: descriptor, size: size)
        }
    }
}
