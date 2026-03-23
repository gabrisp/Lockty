//
//  DestructiveButton.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//
import SwiftUI

struct DestructiveButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .locktyGlass(
                .regular.tint(Color.red.opacity(0.15)).interactive(),
                in: .roundedRectangle(BaseTheme.Radius.lg)
            )
    }
}

struct DestructiveButton<Label: View>: View {
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var completedLabel: (() -> any View)? = nil
    let action: () -> Void
    let label: () -> Label

    var body: some View {
        BaseButton(
            isLoading: isLoading,
            isDisabled: isDisabled,
            completedLabel: completedLabel,
            foregroundColor: .red,
            styleModifier: DestructiveButtonStyle(),
            action: action,
            label: label
        )
    }
}

#Preview {
    VStack(spacing: BaseTheme.Spacing.lg) {
        DestructiveButton(action: {}) {
            Text("Delete mode")
                .font(Typography.body(weight: .semibold))
        }
        DestructiveButton(isLoading: true, action: {}) {
            Text("Deleting...")
                .font(Typography.body(weight: .semibold))
        }
        DestructiveButton(isDisabled: true, action: {}) {
            Text("Disabled")
                .font(Typography.body(weight: .semibold))
        }
    }
    .padding()
    .frame(maxHeight: .infinity, alignment: .center)
    .background(Color.pageBackground)
}
