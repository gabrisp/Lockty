//
//  View+Sticker.swift
//  Lockty
//

import SwiftUI

private struct StickerOutlineModifier: ViewModifier {
    let width: CGFloat
    let color: AnyShapeStyle
    private let symbolID = UUID()

    func body(content: Content) -> some View {
        guard width > 0 else { return AnyView(content) }

        return AnyView(
            content.background {
                Rectangle()
                    .foregroundStyle(color)
                    .mask {
                        Canvas { context, size in
                            context.addFilter(.alphaThreshold(min: 0.01))
                            if let resolved = context.resolveSymbol(id: symbolID) {
                                context.draw(
                                    resolved,
                                    at: CGPoint(x: size.width / 2, y: size.height / 2)
                                )
                            }
                        } symbols: {
                            content
                                .tag(symbolID)
                                .blur(radius: width)
                        }
                    }
            }
        )
    }
}

extension View {
    func stickerOutline(color: some ShapeStyle, width: CGFloat = 1) -> some View {
        modifier(StickerOutlineModifier(width: width, color: AnyShapeStyle(color)))
    }

    func stickered(width: CGFloat = 4) -> some View {
        self
            .stickerOutline(color: .white, width: width)
            .stickerOutline(color: Color.black.opacity(0.14), width: 1)
            .shadow(color: Color.black.opacity(0.12), radius: 8, y: 2)
    }
}
