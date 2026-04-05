//
//  AIBadge.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct AIBadge: View {
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            Text("AI")
                .font(Typography.caption(weight: .semibold))
                .foregroundStyle(Color(.label))
                .frame(width: 64, height: 32)
                .background(Color.innerBackground)
                .clipShape(Capsule())
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.7),
                                    Color.pink.opacity(0.5),
                                    Color.yellow.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blur(radius: 8)
                        .opacity(0.7)
                        .scaleEffect(1.4)
                )
        }
        .buttonStyle(NoFlashButtonStyle())
    }
}

#Preview {
    HStack(spacing: BaseTheme.Spacing.xl) {
        AIBadge()
        AIBadge { print("tapped") }
    }
    .padding()
    .background(Color.pageBackground)
}
