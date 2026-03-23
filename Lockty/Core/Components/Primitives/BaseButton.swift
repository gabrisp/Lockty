import SwiftUI

enum ButtonState {
    case idle
    case loading
    case completed
    case disabled
}

struct NoFlashButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct BaseButton<Label: View, S: ViewModifier>: View {
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var completedLabel: (() -> any View)? = nil
    var foregroundColor: Color = Color(.systemBackground)
    let styleModifier: S
    let action: () -> Void
    let label: () -> Label

    @State private var state: ButtonState = .idle

    var body: some View {
        Button(action: {
            withAnimation(.spring(duration: 0.3)) { action() }
        }) {
            ZStack {
                label().opacity(0)

                switch state {
                case .idle, .disabled:
                    label()
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))

                case .loading:
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.8)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))

                case .completed:
                    if let completed = completedLabel {
                        AnyView(completed())
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BaseTheme.Spacing.lg)
            .tappable()
            .animation(.spring(duration: 0.3), value: state)
            .modifier(styleModifier)
        }
        .buttonStyle(NoFlashButtonStyle())
        .opacity(state == .disabled ? 0.8 : 1)
        .disabled(state == .loading || state == .disabled)
        .onChange(of: isLoading) { _, newValue in
            if newValue {
                withAnimation(.spring(duration: 0.3)) { state = .loading }
            } else if state == .loading {
                if completedLabel != nil {
                    withAnimation(.spring(duration: 0.3)) { state = .completed }
                    Task {
                        try? await Task.sleep(for: .seconds(3))
                        withAnimation(.spring(duration: 0.3)) { state = .idle }
                    }
                } else {
                    withAnimation(.spring(duration: 0.3)) { state = .idle }
                }
            }
        }
        .onChange(of: isDisabled) { _, newValue in
            withAnimation(.spring(duration: 0.3)) {
                state = newValue ? .disabled : .idle
            }
        }
        .onAppear {
            if isDisabled { state = .disabled }
            else if isLoading { state = .loading }
        }
    }
}
