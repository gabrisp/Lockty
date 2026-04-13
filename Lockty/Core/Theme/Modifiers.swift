//
//  Modifiers.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

@MainActor
@Observable
final class MainToolbarStore {
    var leadingContent: AnyView? = nil
    var ownerID: UUID? = nil

    func set<Content: View>(ownerID: UUID, @ViewBuilder content: () -> Content) {
        self.ownerID = ownerID
        self.leadingContent = AnyView(content())
    }

    func clear(ownerID: UUID) {
        guard self.ownerID == ownerID else { return }
        self.ownerID = nil
        self.leadingContent = nil
    }
}

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

struct MainToolbarCustomModifier<ToolbarContent: View>: ViewModifier {
    @Environment(MainToolbarStore.self) private var toolbarStore

    let visible: Bool
    let refreshID: AnyHashable
    let toolbarContent: () -> ToolbarContent

    @State private var ownerID = UUID()

    func body(content: Content) -> some View {
        content
            .onAppear { updateToolbar() }
            .onDisappear { toolbarStore.clear(ownerID: ownerID) }
            .onChange(of: visible) { _, _ in updateToolbar() }
            .onChange(of: refreshID) { _, _ in updateToolbar() }
    }

    private func updateToolbar() {
        if visible {
            toolbarStore.set(ownerID: ownerID, content: toolbarContent)
        } else {
            toolbarStore.clear(ownerID: ownerID)
        }
    }
}



// MARK: - Onboarding hide preference keys

struct OnboardingHideBarKey: PreferenceKey {
    static let defaultValue = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

struct OnboardingHideCTAKey: PreferenceKey {
    static let defaultValue = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

struct OnboardingCTALabelKey: PreferenceKey {
    static let defaultValue: String? = nil
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = value ?? nextValue()
    }
}

struct OnboardingSecondaryAction: Equatable {
    let label: String
    let action: () -> Void
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.label == rhs.label }
}

struct OnboardingSecondaryActionKey: PreferenceKey {
    static let defaultValue: OnboardingSecondaryAction? = nil
    static func reduce(value: inout OnboardingSecondaryAction?, nextValue: () -> OnboardingSecondaryAction?) {
        value = value ?? nextValue()
    }
}

struct OnboardingBackAction: Equatable {
    let action: () -> Void
    static func == (lhs: Self, rhs: Self) -> Bool { false }
}

struct OnboardingBackOverrideKey: PreferenceKey {
    static let defaultValue: OnboardingBackAction? = nil
    static func reduce(value: inout OnboardingBackAction?, nextValue: () -> OnboardingBackAction?) {
        value = value ?? nextValue()
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

    func mainToolbarCustom<ToolbarContent: View>(
        visible: Bool = true,
        refreshID: AnyHashable = 0,
        @ViewBuilder _ content: @escaping () -> ToolbarContent
    ) -> some View {
        modifier(
            MainToolbarCustomModifier(
                visible: visible,
                refreshID: refreshID,
                toolbarContent: content
            )
        )
    }

    /// Oculta la barra de progreso del onboarding en este step.
    func hideOnboardingBar(_ hide: Bool = true) -> some View {
        preference(key: OnboardingHideBarKey.self, value: hide)
    }

    /// Oculta el botón CTA del onboarding en este step.
    func hideOnboardingButton(_ hide: Bool = true) -> some View {
        preference(key: OnboardingHideCTAKey.self, value: hide)
    }

    /// Personaliza el label del botón CTA del onboarding en este step.
    func onboardingButtonLabel(_ label: String) -> some View {
        preference(key: OnboardingCTALabelKey.self, value: label)
    }

    /// Pasa contenido a la sección secundaria del bottom overlay del onboarding.
    func onboardingSecondaryAction(label: String, action: @escaping () -> Void) -> some View {
        preference(key: OnboardingSecondaryActionKey.self, value: OnboardingSecondaryAction(label: label, action: action))
    }

    /// Override de la acción del botón de back del onboarding en este step.
    func onboardingBackButtonOverride(_ action: (() -> Void)?) -> some View {
        preference(key: OnboardingBackOverrideKey.self, value: action.map { OnboardingBackAction(action: $0) })
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
