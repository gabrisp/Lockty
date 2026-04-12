//
//  OnboardingViewModel.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI
import UserNotifications
import FamilyControls
import CoreData
import FirebaseAuth
import FirebaseFirestore
import RevenueCat
import Drops
import AuthenticationServices

@MainActor
@Observable
final class OnboardingViewModel {

    enum Step: Int, CaseIterable {
        case name        = 1
        case permissions = 2
        case signIn      = 3
    }

    var displayName: String = ""
    var currentStep: Step = .name
    var isLoading: Bool = false
    var goingForward: Bool = true
    /// true cuando se llega al signIn desde el botón Login (no reemplaza datos existentes)
    var isLoginFlow: Bool = false

    enum PermissionState { case pending, granted, rejected }

    var notificationsState: PermissionState = .pending
    var screenTimeState: PermissionState = .pending

    var notificationsGranted: Bool { notificationsState == .granted }
    var screenTimeGranted: Bool { screenTimeState == .granted }

    var showAppleSignInSheet: Bool = false
    private let appleSignInHandler = AppleSignInHandler()

    var canAdvanceFromName: Bool {
        displayName.trimmingCharacters(in: .whitespaces).count >= 2
    }

    func nextStep(router: AppRouter? = nil) async {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        Drops.hideAll()
        switch currentStep {
        case .signIn:
            if let router { await signInWithApple(router: router) }
        default:
            guard let next = Step(rawValue: currentStep.rawValue + 1) else { return }
            withAnimation(.snappy) { currentStep = next }
        }
    }

    func prevStep() {
        Drops.hideAll()
        isLoading = false
        guard let prev = Step(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.snappy) { currentStep = prev }
    }

    /// Salta directamente al step de signIn sin pasar por los demás (flujo Login)
    func jumpToSignIn() {
        isLoginFlow = true
        withAnimation(.snappy) { currentStep = .signIn }
    }

    func signInWithApple(router: AppRouter) async {
        isLoading = true
        do {
            let signInResult = try await appleSignInHandler.signIn()
            let uid = signInResult.uid
            let ctx = PersistenceController.shared.context

            if isLoginFlow {
                // Login: buscar el usuario en Firestore
                let db = Firestore.firestore()
                let doc = try await db.collection("users").document(uid).getDocument()
                guard doc.exists, let name = doc.data()?["name"] as? String else {
                    // No existe en Firestore — no tiene cuenta
                    try? Auth.auth().signOut()
                    isLoginFlow = false
                    isLoading = false
                    Drops.show(Drop(title: "No encontramos tu cuenta", subtitle: "Crea una cuenta para continuar.", icon: UIImage(systemName: "person.slash.fill")))
                    withAnimation(.snappy) { currentStep = .name }
                    return
                }

                // Existe — upsert en CoreData y entrar
                let req = LocalUserEntity.fetchRequest()
                req.predicate = NSPredicate(format: "firebaseUserId == %@", uid)
                req.fetchLimit = 1
                let entity = (try? ctx.fetch(req).first) ?? LocalUserEntity(context: ctx)
                if entity.id == nil { entity.id = UUID() }
                if entity.createdAt == nil { entity.createdAt = .now }
                entity.displayName = name
                entity.firebaseUserId = uid
                try? ctx.save()

                let user = LocalUser(id: entity.id!, displayName: name, createdAt: entity.createdAt!, firebaseUserId: uid)
                Purchases.shared.logIn(uid) { _, _, _ in }
                await router.premium.refresh()
                withAnimation(.easeInOut(duration: 0.3)) {
                    router.currentUser = user
                    router.authState = .authenticated
                }
            } else {
                // Registro
                let name = displayName.trimmingCharacters(in: .whitespaces)
                let existingReq = LocalUserEntity.fetchRequest()
                existingReq.fetchLimit = 1
                if let existing = try? ctx.fetch(existingReq).first,
                   existing.firebaseUserId != uid {
                    for entity in (try? ctx.fetch(LocalUserEntity.fetchRequest())) ?? [] { ctx.delete(entity) }
                    for entity in (try? ctx.fetch(ModeEntity.fetchRequest())) ?? [] { ctx.delete(entity) }
                    for entity in (try? ctx.fetch(SessionEntity.fetchRequest())) ?? [] { ctx.delete(entity) }
                    for entity in (try? ctx.fetch(RuleEntity.fetchRequest())) ?? [] { ctx.delete(entity) }
                    for entity in (try? ctx.fetch(SyncSettingsEntity.fetchRequest())) ?? [] { ctx.delete(entity) }
                    try ctx.save()
                }

                // Upsert
                let req = LocalUserEntity.fetchRequest()
                req.predicate = NSPredicate(format: "firebaseUserId == %@", uid)
                req.fetchLimit = 1
                let entity = (try? ctx.fetch(req).first) ?? LocalUserEntity(context: ctx)
                if entity.id == nil { entity.id = UUID() }
                entity.displayName = name
                if entity.createdAt == nil { entity.createdAt = .now }
                entity.firebaseUserId = uid
                try ctx.save()

                // Guardar en Firestore
                let db = Firestore.firestore()
                try await db.collection("users").document(uid).setData(["name": name, "id": uid])

                // Guardar displayName en Firebase Auth profile
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = name
                try await changeRequest?.commitChanges()

                Purchases.shared.logIn(uid) { _, _, _ in }

                let user = LocalUser(id: entity.id!, displayName: name, createdAt: entity.createdAt!, firebaseUserId: uid)
                withAnimation(.easeInOut(duration: 0.3)) {
                    router.currentUser = user
                    router.authState = .authenticated
                }
            }
        } catch let error as ASAuthorizationError where error.code == .canceled {
            isLoading = false
        } catch {
            isLoading = false
            Drops.show(Drop(title: "Error al iniciar sesión", subtitle: "Inténtalo de nuevo.", icon: UIImage(systemName: "xmark.circle.fill")))
        }
    }

    func requestNotifications() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .denied {
            Drops.show(Drop(title: "Notificaciones denegadas", subtitle: "Ábrelas desde Ajustes.", icon: UIImage(systemName: "bell.slash.fill")))
            if let url = URL(string: UIApplication.openSettingsURLString) {
                await UIApplication.shared.open(url)
            }
            return
        }
        let result = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])
        withAnimation(.snappy) {
            notificationsState = result == true ? .granted : .rejected
        }
        if result == true {
            Drops.show(Drop(title: "Notificaciones activadas", icon: UIImage(systemName: "bell.fill")))
        }
    }

    func requestScreenTime() async {
        let result: ()? = try? await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        withAnimation(.snappy) {
            screenTimeState = (result != nil) ? .granted : .rejected
        }
        if result != nil {
            Drops.show(Drop(title: "Screen Time activado", icon: UIImage(systemName: "lock.shield.fill")))
        } else {
            Drops.show(Drop(title: "Screen Time denegado", subtitle: "Es necesario para continuar.", icon: UIImage(systemName: "lock.slash.fill")))
        }
    }

    func requestPermissions() async {
        await requestNotifications()
        await requestScreenTime()
    }
}
