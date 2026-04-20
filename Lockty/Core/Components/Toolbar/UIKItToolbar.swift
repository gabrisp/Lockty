//
//  UIKItToolbar.swift
//  Lockty
//
//  Created by Gabrisp on 20/4/26.
//
import UIKit
import SwiftUI


struct CustomToolbar: UIViewRepresentable {
    let title: String
    let onButtonTap: () -> Void

    func makeUIView(context: Context) -> UIToolbar {
        let toolbar = UIToolbar()

        let titleItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let button = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.tapped)
        )
        toolbar.items = [titleItem, spacer, button]

        return toolbar
    }

    func updateUIView(_ uiView: UIToolbar, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onButtonTap)
    }

    class Coordinator: NSObject {
        let onTap: () -> Void
        init(onTap: @escaping () -> Void) { self.onTap = onTap }

        @objc func tapped() { onTap() }
    }
}
