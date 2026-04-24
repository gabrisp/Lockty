//
//  UINavigationController+SwipeBack.swift
//  Lockty
//

import SwiftUI
import UIKit

private struct InteractivePopGestureConfigurator: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> Controller {
        let controller = Controller()
        controller.coordinator = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {
        uiViewController.coordinator = context.coordinator
        uiViewController.configureInteractivePopGesture()
    }

    final class Controller: UIViewController {
        weak var coordinator: Coordinator?

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            configureInteractivePopGesture()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            configureInteractivePopGesture()
        }

        func configureInteractivePopGesture() {
            guard
                let navigationController,
                let gestureRecognizer = navigationController.interactivePopGestureRecognizer,
                let coordinator
            else { return }

            gestureRecognizer.delegate = coordinator
            gestureRecognizer.isEnabled = navigationController.viewControllers.count > 1
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let navigationController = navigationController(for: gestureRecognizer) else { return false }
            return navigationController.viewControllers.count > 1
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            guard let navigationController = navigationController(for: gestureRecognizer) else { return false }
            return navigationController.viewControllers.count > 1
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            guard let navigationController = navigationController(for: gestureRecognizer) else { return false }
            return navigationController.viewControllers.count > 1
        }

        private func navigationController(for gestureRecognizer: UIGestureRecognizer) -> UINavigationController? {
            var responder = gestureRecognizer.view?.next

            while let current = responder {
                if let navigationController = current as? UINavigationController {
                    return navigationController
                }
                responder = current.next
            }

            return nil
        }
    }
}

extension View {
    func enableInteractivePopGesture() -> some View {
        background(InteractivePopGestureConfigurator().frame(width: 0, height: 0))
    }
}
