//
//  RootToolbar.swift
//  Lockty
//

import UIKit
import SwiftUI

struct RootToolbar: UIViewRepresentable {
    let user: LocalUser?

    func makeUIView(context: Context) -> UIToolbar {
        let toolbar = UIToolbar()
        let toolbarAppearance = UIToolbarAppearance()
        
        toolbarAppearance.backgroundColor = .red
        let blur = UIBlurEffect(style: .extraLight)
        
        toolbarAppearance.backgroundEffect = blur
        toolbar.isTranslucent = true

        toolbar.barStyle = .default
        toolbar.standardAppearance = toolbarAppearance
        
        let name = user?.displayName ?? "?"
        let avatarView = AvatarView(name: name, size: .toolbar) {
            AppRouter.shared.openSettings()
        }
        let host = UIHostingController(rootView: avatarView)
        host.view.backgroundColor = .clear

        let avatarItem = UIBarButtonItem(customView: host.view)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let titleLabel = UILabel()
        titleLabel.text = "Hola"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        let titleItem = UIBarButtonItem(customView: titleLabel)

        toolbar.items = [spacer, titleItem, spacer, avatarItem]

        return toolbar
    }

    func updateUIView(_ uiView: UIToolbar, context: Context) {}

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIToolbar, context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? UIScreen.main.bounds.width, height: 44)
    }
}
