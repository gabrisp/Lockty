//
//  LocktyView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI
import CoreData
import FirebaseAuth
import RevenueCat

struct LocktyView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            switch router.authState {
            case .loading:
                SplashView()
                    .task { await resolveAuthState() }

            case .onboarding:
                OnboardingView()
                    .transition(AnyTransition(.blurReplace).combined(with: .opacity))

            case .authenticated:
                RootView()
                    .transition(AnyTransition(.blurReplace).combined(with: .opacity))
                    .task(id: router.authState) {
                        router.selectedTab = .modes
                        router.navigation.popToRoot()
                        router.sheet.popToRoot()
                    }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: router.authState)
    }
}

// MARK: - Auth Resolution

private extension LocktyView {
    func resolveAuthState() async {
        guard router.authState == .loading else { return }

        let destination: AppRouter.AuthState

        if let firebaseUser = Auth.auth().currentUser {
            let uid = firebaseUser.uid
            let ctx = PersistenceController.shared.context
            let req = LocalUserEntity.fetchRequest()
            req.predicate = NSPredicate(format: "firebaseUserId == %@", uid)
            req.fetchLimit = 1

            if let entity = try? ctx.fetch(req).first,
               let id = entity.id,
               let displayName = entity.displayName,
               let createdAt = entity.createdAt {
                let user = LocalUser(id: id, displayName: displayName, createdAt: createdAt, firebaseUserId: uid)
                Purchases.shared.logIn(uid) { _, _, _ in }
                await router.premium.refresh()
                await MainActor.run { router.currentUser = user }
                destination = .authenticated
            } else {
                destination = .onboarding
            }
        } else {
            destination = .onboarding
        }

        await MainActor.run {
            router.authState = destination
        }
    }
}
