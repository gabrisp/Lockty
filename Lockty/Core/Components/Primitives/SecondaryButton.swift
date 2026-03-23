//
//  SecondaryButton.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct SecondaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .locktyGlass(
                .regular.tint(Color(.tertiarySystemGroupedBackground)).interactive(),
               in: .roundedRectangle(BaseTheme.Radius.lg)
                       )
     
    }
}

struct SecondaryButton<Label: View>: View {
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
            foregroundColor: Color(.label),
            styleModifier: SecondaryButtonStyle(),
            action: action,
            label: label
        )
    }
}

#Preview {
    VStack(spacing: BaseTheme.Spacing.lg) {
        SecondaryButton(action: {}) {
            Text("Take a break")
                .font(Typography.body(weight: .semibold))
        }
        SecondaryButton(isLoading: true, action: {}) {
            Text("Loading")
                .font(Typography.body(weight: .semibold))
        }
        SecondaryButton(isDisabled: true, action: {}) {
            Text("Disabled")
                .font(Typography.body(weight: .semibold))
        }
    }
    .padding()
}
