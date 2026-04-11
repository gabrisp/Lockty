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
    @State private var goingForward: Bool = true

    private let anim: Animation = .snappy(duration: 0.4, extraBounce: 0)

    private var progress: CGFloat {
        CGFloat(vm.currentStep.rawValue) / CGFloat(OnboardingViewModel.Step.allCases.count)
    }

    private var ctaLabel: String {
        ctaLabelOverride ?? (vm.currentStep == .permissions ? "Empezar" : "Continuar")
    }

    private var stepTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: goingForward ? .bottom : .top).combined(with: .opacity),
            removal:   .move(edge: goingForward ? .top : .bottom).combined(with: .opacity)
        )
    }

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            // MARK: - Step content
            stepContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onPreferenceChange(OnboardingHideBarKey.self)      { v in withAnimation(anim) { hideBar = v } }
                .onPreferenceChange(OnboardingHideCTAKey.self)      { v in withAnimation(anim) { hideCTA = v } }
                .onPreferenceChange(OnboardingCTALabelKey.self)     { ctaLabelOverride = $0 }
                .onPreferenceChange(OnboardingBackOverrideKey.self) { backOverride = $0 }

            // MARK: - Top overlay
            VStack(spacing: 0) {
                HStack(spacing: vm.currentStep == .name ? 0 : BaseTheme.Spacing.md) {
                    if vm.currentStep != .name {
                        Button {
                            Haptics.play(.selection)
                            if let override = backOverride {
                                override.action()
                            } else {
                                goingForward = false
                                vm.prevStep()
                            }
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
                            Capsule().fill(Color(.tertiaryLabel)).frame(height: 3)
                            Capsule().fill(Color(.label))
                                .frame(width: geo.size.width * progress, height: 3)
                                .animation(anim, value: vm.currentStep)
                        }
                    }
                    .frame(height: 3)
                }
                .animation(anim, value: vm.currentStep)
                .padding(.horizontal, BaseTheme.Spacing.lg)
                .padding(.top, BaseTheme.Spacing.xxl)
                Spacer()
            }
            .opacity(hideBar ? 0 : 1)
            .allowsHitTesting(!hideBar)
            .animation(anim, value: hideBar)

            // MARK: - Bottom overlay
            VStack(spacing: 0) {
                Spacer()
                if !hideCTA {
                    PrimaryButton(
                        isLoading: vm.isLoading,
                        isDisabled: !ctaEnabled,
                        action: {
                            Haptics.play(.button)
                            goingForward = true
                            Task { await vm.nextStep(router: router) }
                        }
                    ) {
                        Text(ctaLabel)
                            .font(Typography.body(weight: .semibold))
                            .contentTransition(.interpolate)
                            .animation(anim, value: ctaLabel)
                    }
                    .padding(.horizontal, BaseTheme.Spacing.lg)
                    .padding(.bottom, BaseTheme.Spacing.xxl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(anim, value: hideCTA)
        }
    }

    private var ctaEnabled: Bool {
        switch vm.currentStep {
        case .name:        return vm.canAdvanceFromName
        case .signIn:      return false
        case .permissions: return vm.screenTimeState != .rejected
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        ZStack {
            if vm.currentStep == .name        { NameStep(vm: vm).transition(stepTransition) }
            if vm.currentStep == .signIn      { SignInStep(vm: vm, router: router).transition(stepTransition) }
            if vm.currentStep == .permissions { PermissionsStep(vm: vm).transition(stepTransition) }
        }
        .animation(anim, value: vm.currentStep)
    }
}

#Preview {
    OnboardingView()
        .environment(AppRouter())
}
