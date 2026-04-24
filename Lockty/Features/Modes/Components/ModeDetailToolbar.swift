//
//  ModeDetailToolbar.swift
//  Lockty
//

import UIKit
import SwiftUI

struct ModeDetailToolbar: UIViewRepresentable {
    let onBack: () -> Void

    func makeUIView(context: Context) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolbar.backgroundColor = .clear
        toolbar.isTranslucent = true

        let backItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.didTapBack)
        )
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [backItem, spacer]

        return toolbar
    }

    func updateUIView(_ uiView: UIToolbar, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onBack: onBack)
    }

    class Coordinator: NSObject {
        let onBack: () -> Void
        init(onBack: @escaping () -> Void) { self.onBack = onBack }
        @objc func didTapBack() { onBack() }
    }
}
