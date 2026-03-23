//
//  PrimaryButton.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//
import SwiftUI

struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .locktyGlass(
                .regular.tint(Color(.label).opacity(0.9)).interactive(),
               in: .roundedRectangle(BaseTheme.Radius.lg)
                       )
    }
}

struct PrimaryButton<Label: View>: View {
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
            foregroundColor: Color(.secondarySystemBackground),  
            styleModifier: PrimaryButtonStyle(),
            action: action,
            label: label
        )
    }
}

#Preview {
    @Previewable @State var isLoading: Bool = false

    VStack(spacing: BaseTheme.Spacing.lg) {

        // Solo texto
        PrimaryButton(isLoading: isLoading, action: {
            isLoading = true
            Task {
                try? await Task.sleep(for: .seconds(2))
                isLoading = false
            }
        }) {
            Text("Activate")
                .font(Typography.body(weight: .semibold))
                .foregroundStyle(.primary)
        }

        // VStack con título y subtítulo
        PrimaryButton(action: {}) {
            VStack(spacing: 2) {
                Text("Take a break")
                    .font(Typography.body(weight: .semibold))
                    .foregroundStyle(.primary)
                Text("1/3 used")
                    .font(Typography.caption())
                    .foregroundStyle(.secondary)
            }
            .padding(BaseTheme.Spacing.xs)
        }

        PrimaryButton(isLoading: true, action: {}) {
            Text("Loading")
                .font(Typography.body(weight: .semibold))
                .foregroundStyle(.white)
        }

        PrimaryButton(isDisabled: true, action: {}) {
            Text("Disabled")
                .font(Typography.body(weight: .semibold))
        }
    }
    .padding()
}
