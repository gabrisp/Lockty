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
import RevenueCat
import Drops
import AuthenticationServices

@MainActor
@Observable
final class OnboardingViewModel {

    enum Step: Int, CaseIterable {
        case name        = 1
        case signIn      = 2
        case permissions = 3
    }

    var displayName: String = ""
    var currentStep: Step = .name
    var isLoading: Bool = false

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
        case .permissions:
            if let router { await complete(router: router) }
        default:
            guard let next = Step(rawValue: currentStep.rawValue + 1) else { return }
            withAnimation(.snappy) { currentStep = next }
        }
    }

    func prevStep() {
        Drops.hideAll()
        guard let prev = Step(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.snappy) { currentStep = prev }
    }

    func signInWithApple(router: AppRouter) async {
        isLoading = true
        do {
            let uid = try await appleSignInHandler.signIn()
            let name = displayName.trimmingCharacters(in: .whitespaces)
            let ctx = PersistenceController.shared.context

            // Si hay un usuario con distinto firebaseUserId → cuenta diferente, borrar todo
            let existingReq = LocalUserEntity.fetchRequest()
            existingReq.fetchLimit = 1
            if let existing = try? ctx.fetch(existingReq).first,
               existing.firebaseUserId != uid {
                // Borrar todos los datos del usuario anterior
                for entity in (try? ctx.fetch(LocalUserEntity.fetchRequest())) ?? [] { ctx.delete(entity) }
                for entity in (try? ctx.fetch(ModeEntity.fetchRequest())) ?? [] { ctx.delete(entity) }
                for entity in (try? ctx.fetch(SessionEntity.fetchRequest())) ?? [] { ctx.delete(entity) }
                for entity in (try? ctx.fetch(RuleEntity.fetchRequest())) ?? [] { ctx.delete(entity) }
                for entity in (try? ctx.fetch(SyncSettingsEntity.fetchRequest())) ?? [] { ctx.delete(entity) }
                try ctx.save()
            }

            // Upsert — busca por firebaseUserId, crea si no existe
            let req = LocalUserEntity.fetchRequest()
            req.predicate = NSPredicate(format: "firebaseUserId == %@", uid)
            req.fetchLimit = 1
            let entity = (try? ctx.fetch(req).first) ?? LocalUserEntity(context: ctx)
            if entity.id == nil { entity.id = UUID() }
            entity.displayName = name
            if entity.createdAt == nil { entity.createdAt = .now }
            entity.firebaseUserId = uid

            let user = LocalUser(id: entity.id!, displayName: name, createdAt: entity.createdAt!, firebaseUserId: uid)
            try ctx.save()
            Purchases.shared.logIn(uid) { _, _, _ in }
            await nextStep()
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

    func complete(router: AppRouter) async {
        isLoading = true
        guard let firebaseUser = Auth.auth().currentUser else {
            isLoading = false
            Drops.show(Drop(title: "Sesión no encontrada", subtitle: "Inténtalo de nuevo.", icon: UIImage(systemName: "person.slash.fill")))
            return
        }
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
            withAnimation(.easeInOut(duration: 0.3)) {
                router.currentUser = user
                router.authState = .authenticated
            }
        } else {
            isLoading = false
            Drops.show(Drop(title: "Algo ha ido mal", subtitle: "Inténtalo de nuevo.", icon: UIImage(systemName: "exclamationmark.triangle.fill")))
        }
    }
}
