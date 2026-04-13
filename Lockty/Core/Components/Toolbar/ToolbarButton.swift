//
//  ToolbarButton.swift
//  Lockty
//

import SwiftUI

struct ToolbarButton: View {
    let icon: String
    var size: CGFloat = 50
    var iconSize: CGFloat = 16
    let action: () -> Void

    var body: some View {
        Circle()
            .foregroundStyle(.clear)
            .frame(width: size, height: size)
            .glassEffect(.regular.interactive(), in: .circle)
            .overlay {
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(Color(.label))
                    .frame(width: size, height: size)
            }
            .zIndex(1000)
            .transition(.blurReplace)
            .tappable()
            .onTapGesture { action() }
    }
}
