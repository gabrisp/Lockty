//
//  CustomGlassTabBar.swift
//  Lockty
//

import SwiftUI

struct CustomGlassTabBar<TabItemView: View>: UIViewRepresentable {
    var size: CGSize
    var activeTint: Color = .primary
    var inActiveTint: Color = .primary.opacity(0.45)
    var barTint: Color = .gray.opacity(0.2)
    @Binding var activeTab: AppRouter.Tab
    @ViewBuilder var tabItemView: (AppRouter.Tab) -> TabItemView

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UISegmentedControl {
        // let items = AppRouter.Tab.allCases.map { _ in "" }
        let items = AppRouter.Tab.allCases.map(\.label)
        let control = UISegmentedControl(items: items)

        control.selectedSegmentIndex = activeTab.index

        for (index, tab) in AppRouter.Tab.allCases.enumerated() {
            let renderer = ImageRenderer(content: tabItemView(tab))
            // renderer.scale = 2
            renderer.scale = 2
            let image = renderer.uiImage
            control.setImage(image, forSegmentAt: index)
        }

        DispatchQueue.main.async {
            for subview in control.subviews {
                if subview is UIImageView && subview != control.subviews.last {
                    subview.alpha = 0
                }
            }
        }

        control.selectedSegmentTintColor = UIColor(barTint)
        // control.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        // control.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        control.setTitleTextAttributes([
            .foregroundColor: UIColor(activeTint)
        ], for: .selected)
        control.setTitleTextAttributes([
            .foregroundColor: UIColor(inActiveTint)
        ], for: .normal)

        control.addTarget(context.coordinator, action: #selector(context.coordinator.tabSelected(_:)), for: .valueChanged)
        return control
    }

    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        // Intentionally kept in sync with router-selected tab.
        // The sample leaves this empty; here we still mirror external tab changes.
        let index = activeTab.index
        if uiView.selectedSegmentIndex != index {
            uiView.selectedSegmentIndex = index
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
        size
    }

    class Coordinator: NSObject {
        var parent: CustomGlassTabBar
        init(parent: CustomGlassTabBar) { self.parent = parent }

        @objc func tabSelected(_ control: UISegmentedControl) {
            let tab = AppRouter.Tab.allCases[control.selectedSegmentIndex]
            withAnimation(.snappy) { parent.activeTab = tab }
        }
    }
}
