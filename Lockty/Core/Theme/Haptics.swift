//
//  Haptics.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

// MARK: - HapticStyle

enum HapticStyle {
    case light
    case medium
    case heavy
    case rigid
    case soft
    case selection
    case success
    case warning
    case error
    case button                          // medium impact, estándar para botones
    case buttonRepeat(duration: Double)  // impactos repetidos durante N segundos
}

// MARK: - Factory

enum Haptics {
    static func play(_ style: HapticStyle) {
        switch style {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .rigid:
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case .soft:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .button:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .buttonRepeat(let duration):
            let interval: Double = 0.1
            let count = max(1, Int(duration / interval))
            for i in 0..<count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }
    }
}

// MARK: - View modifier (trigger-based)

private struct HapticModifier: ViewModifier {
    let style: HapticStyle
    let trigger: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, newValue in
                if newValue { Haptics.play(style) }
            }
    }
}

// MARK: - View extensions

extension View {
    /// Dispara haptic cuando `trigger` cambia a `true`.
    func haptic(_ style: HapticStyle, trigger: Bool) -> some View {
        modifier(HapticModifier(style: style, trigger: trigger))
    }

    /// Dispara haptic en cada tap.
    func hapticOnTap(_ style: HapticStyle = .button) -> some View {
        simultaneousGesture(TapGesture().onEnded { Haptics.play(style) })
    }
}
