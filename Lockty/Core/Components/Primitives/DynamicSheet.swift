//
//  DynamicSheet.swift
//  Lockty
//

import SwiftUI

struct DynamicSheet<Content: View>: View {
    var animation: Animation = .spring(duration: 0.35, bounce: 0.08)
    @ViewBuilder var content: Content
    @State private var sheetHeight: CGFloat = 0

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                content
            }
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGSize.self) {
                $0.size
            } action: { newValue in
                if sheetHeight == .zero {
                    sheetHeight = min(newValue.height, windowSize.height - 110)
                } else {
                    withAnimation(animation) {
                        sheetHeight = min(newValue.height, windowSize.height - 110)
                    }
                }
            }
        }
        .modifier(SheetHeightModifier(height: sheetHeight))
        .presentationDragIndicator(.visible)
    }

    var windowSize: CGSize {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size ?? .zero
    }
}

private struct SheetHeightModifier: ViewModifier, Animatable {
    var height: CGFloat
    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }
    func body(content: Content) -> some View {
        content
            .presentationDetents(height == .zero ? [.medium] : [.height(height)])
    }
}
