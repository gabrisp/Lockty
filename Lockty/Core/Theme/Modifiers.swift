//
//  Modifiers.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

// MARK: - Card
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
    }
}

// MARK: - Inner Card (dentro de una card)
struct InnerCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.innerBackground)
            .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.lg))
    }
}

// MARK: - Corner Radius genérico
struct CornerRadiusModifier: ViewModifier {
    let radius: CGFloat
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

// MARK: - Page Background
struct PageBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.pageBackground.ignoresSafeArea())
    }
}


struct TappableModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
    }
}



// MARK: - Namespace environment key (for zoom transitions)
private struct ModeZoomNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    var modeZoomNamespace: Namespace.ID? {
        get { self[ModeZoomNamespaceKey.self] }
        set { self[ModeZoomNamespaceKey.self] = newValue }
    }
}

// MARK: - Extensions — uso limpio en views
extension View {
    func locktyCard() -> some View {
        modifier(CardModifier())
    }

    func locktyInnerCard() -> some View {
        modifier(InnerCardModifier())
    }

    func locktyRadius(_ radius: CGFloat) -> some View {
        modifier(CornerRadiusModifier(radius: radius))
    }

    func locktyPageBackground() -> some View {
        modifier(PageBackgroundModifier())
    }
    func tappable() -> some View {
        modifier(TappableModifier())
    }

    @ViewBuilder
    func ifLet<T, V: View>(_ value: T?, transform: (Self, T) -> V) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}
