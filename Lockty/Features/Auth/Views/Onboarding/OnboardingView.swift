//
//  OnboardingView.swift
//  Lockty
//

import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @Environment(AppRouter.self) private var router
    @State private var vm = OnboardingViewModel()

    @State private var hideBar: Bool = false
    @State private var hideCTA: Bool = false
    @State private var ctaLabelOverride: String? = nil
    @State private var backOverride: OnboardingBackAction? = nil
    @State private var secondaryAction: OnboardingSecondaryAction? = nil

    private let animation: Animation = .snappy(duration: 0.7, extraBounce: 0)

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            stepContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onPreferenceChange(OnboardingHideBarKey.self)        { v in withAnimation(.easeInOut(duration: 0.2)) { hideBar = v } }
                .onPreferenceChange(OnboardingHideCTAKey.self)        { v in withAnimation(animation) { hideCTA = v } }
                .onPreferenceChange(OnboardingCTALabelKey.self)       { ctaLabelOverride = $0 }
                .onPreferenceChange(OnboardingBackOverrideKey.self)   { backOverride = $0 }
                .onPreferenceChange(OnboardingSecondaryActionKey.self) { v in withAnimation(.easeInOut(duration: 0.2)) { secondaryAction = v } }

            topOverlay
            bottomOverlay
        }
    }
}

// MARK: - Top Overlay

private extension OnboardingView {
    var topOverlay: some View {
        VStack(spacing: 0) {
            HStack(spacing: vm.currentStep == .name ? 0 : BaseTheme.Spacing.md) {
                if vm.currentStep != .name {
                    Button {
                        Haptics.play(.selection)
                        vm.goingForward = false
                        if let override = backOverride { override.action() } else { vm.prevStep() }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color(.label))
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(NoFlashButtonStyle())
                    .transition(.opacity)
                } else {
                    Color.clear.frame(width: 0, height: 32)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(.tertiaryLabel)).frame(height: 3).frame(maxWidth: .infinity, alignment: .leading)
                        Capsule().fill(Color(.label))
                            .frame(width: geo.size.width * progress, height: 3)
                            .animation(.spring(duration: 0.5, bounce: 0.1), value: vm.currentStep)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(height: 3)
                .opacity(vm.currentStep == .signIn && vm.isLoginFlow ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: vm.currentStep)
                .allowsHitTesting(!(vm.currentStep == .signIn && vm.isLoginFlow))
            }
            .animation(.easeInOut(duration: 0.2), value: vm.currentStep)
            .padding(.horizontal, BaseTheme.Spacing.lg)
            .padding(.top, BaseTheme.Spacing.xxl)
            Spacer()
        }
    }
}

// MARK: - Bottom Overlay

private extension OnboardingView {
    var bottomOverlay: some View {
        VStack(spacing: BaseTheme.Spacing.xs) {
            Spacer().frame(maxHeight: .infinity)
            if !hideCTA {
                PrimaryButton(
                    isLoading: vm.currentStep == .signIn ? vm.isLoading : false,
                    isDisabled: !ctaEnabled,
                    action: {
                        withAnimation(animation) {
                            Haptics.play(.button)
                            vm.goingForward = true
                            Task { await vm.nextStep(router: router) }
                        }
                    }
                ) {
                    Text(ctaLabel)
                        .font(Typography.body(weight: .semibold))
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: ctaLabel)
                }
                .padding(.horizontal, BaseTheme.Spacing.lg)
                .geometryGroup()
                .transition(AnyTransition.move(edge: .bottom).combined(with: AnyTransition(.blurReplace)))
            }

            HStack {
                if let action = secondaryAction {
                    Button {
                        Haptics.play(.selection)
                        action.action()
                    } label: {
                        Text(action.label)
                            .font(Typography.caption())
                            .foregroundStyle(Color(.secondaryLabel))
                            .underline()
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 32)
            .opacity(secondaryAction != nil ? 1 : 0)
            .padding(.bottom, BaseTheme.Spacing.xxl)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

// MARK: - Step Content

private extension OnboardingView {
    @ViewBuilder
    var stepContent: some View {
        ZStack {
            if vm.currentStep == .name {
                NameStepView(vm: vm).geometryGroup().transition(AnyTransition(.blurReplace))
            }
            if vm.currentStep == .permissions {
                PermissionsStepView(vm: vm).geometryGroup().transition(AnyTransition(.blurReplace))
            }
            if vm.currentStep == .signIn {
                SignInStepView(vm: vm, router: router).geometryGroup().transition(AnyTransition(.blurReplace))
            }
        }
    }
}

// MARK: - Computed

private extension OnboardingView {
    var progress: CGFloat {
        CGFloat(vm.currentStep.rawValue) / CGFloat(OnboardingViewModel.Step.allCases.count)
    }

    var ctaLabel: String {
        if let override = ctaLabelOverride { return override }
        return vm.currentStep == .signIn ? "Iniciar sesión" : "Continuar"
    }

    var ctaEnabled: Bool {
        switch vm.currentStep {
        case .name:        return vm.canAdvanceFromName
        case .permissions: return vm.screenTimeState != .rejected
        case .signIn:      return false
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environment(AppRouter.shared)
}
