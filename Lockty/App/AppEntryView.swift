//
//  AppEntryView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI
import CoreData
import FirebaseAuth
import RevenueCat

struct AppEntryView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        Group {
            switch router.authState {
            case .loading:
                // SPLASH DESHABILITADO — se navega en cuanto resolveAuthState termina
                Color.pageBackground.ignoresSafeArea()
                    .task { await resolveAuthState() }

            case .onboarding:
                OnboardingView()
                    .environment(router)

            case .authenticated:
                RootView()
                    .environment(router)
            }
        }
    }

    // MARK: - Auth resolution

    private func resolveAuthState() async {
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
            withAnimation(.easeInOut(duration: 0.4)) {
                router.authState = destination
            }
        }
    }
}
