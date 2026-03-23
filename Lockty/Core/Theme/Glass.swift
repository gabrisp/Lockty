//
//  Glass.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct GlassModifier: ViewModifier {
    let effect: Glass
    let shape: GlassShape

    enum GlassShape {
        case circle
        case capsule
        case roundedRectangle(CGFloat)
    }

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            switch shape {
            case .circle:
                content.glassEffect(effect, in: .circle)
            case .capsule:
                content.glassEffect(effect, in: .capsule)
            case .roundedRectangle(let radius):
                content.glassEffect(effect, in: .rect(cornerRadius: radius))
            }
        } else {
            switch shape {
            case .circle:
                content.background(.ultraThinMaterial).clipShape(Circle())
            case .capsule:
                content.background(.ultraThinMaterial).clipShape(Capsule())
            case .roundedRectangle(let radius):
                content.background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: radius))
            }
        }
    }
}

extension View {
    func locktyGlass(
        _ effect: Glass = .regular,
        in shape: GlassModifier.GlassShape = .capsule
    ) -> some View {
        modifier(GlassModifier(effect: effect, shape: shape))
    }
}
