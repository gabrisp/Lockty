//
//  CreateModeViewModel.swift
//  Lockty
//

import SwiftUI
import CoreData
import FamilyControls

@MainActor
@Observable
final class CreateModeViewModel {

    var name: String = ""
    var iconName: String = "target"
    var colorHex: String = "#FCE8E3"
    var rules: [Rule] = []
    var blockedApps: FamilyActivitySelection = .init()

    // Sub-sheet visibility
    var showIconPicker: Bool = false
    var showColorPicker: Bool = false
    var showScreenTimePicker: Bool = false
    var showCreateRule: Bool = false
    var preselectedTransition: Transition? = nil

    var canSave: Bool {
        name.trimmingCharacters(in: .whitespaces).count >= 2
    }

    // nil = nuevo modo, UUID = editar existente
    private let modeId: UUID?

    init(modeId: UUID? = nil) {
        self.modeId = modeId
        if let modeId {
            loadExisting(modeId: modeId)
        }
    }

    private func loadExisting(modeId: UUID) {
        let ctx = PersistenceController.shared.context

        let modeReq = ModeEntity.fetchRequest()
        modeReq.predicate = NSPredicate(format: "id == %@", modeId as CVarArg)
        modeReq.fetchLimit = 1
        if let entity = try? ctx.fetch(modeReq).first {
            name = entity.name ?? ""
            iconName = entity.iconName ?? "target"
            colorHex = entity.colorHex ?? "#FCE8E3"
            let blockedReq = BlockedAppsEntity.fetchRequest()
            blockedReq.predicate = NSPredicate(format: "modeId == %@", modeId as CVarArg)
            blockedReq.fetchLimit = 1
            if let blockedEntity = try? ctx.fetch(blockedReq).first,
               let data = blockedEntity.selectionData,
               let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
                blockedApps = decoded
            }
        }

        let ruleReq = RuleEntity.fetchRequest()
        ruleReq.predicate = NSPredicate(format: "modeId == %@", modeId as CVarArg)
        let entities = (try? ctx.fetch(ruleReq)) ?? []
        rules = entities.compactMap { entity in
            guard let id = entity.id,
                  let mid = entity.modeId,
                  let transition = entity.transition,
                  let conditionType = entity.conditionType,
                  let guardLogic = entity.guardLogic,
                  let onGuardFail = entity.onGuardFail else { return nil }
            return Rule(
                id: id,
                modeId: mid,
                transition: transition,
                conditionType: conditionType,
                conditionConfig: entity.conditionConfig ?? Data(),
                guardLogic: guardLogic,
                onGuardFail: onGuardFail,
                isActive: entity.isActive
            )
        }
    }

    func save() throws {
        let ctx = PersistenceController.shared.context
        let id = modeId ?? UUID()

        // Upsert ModeEntity
        let req = ModeEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        req.fetchLimit = 1
        let entity = (try? ctx.fetch(req).first) ?? ModeEntity(context: ctx)
        entity.id = id
        entity.name = name.trimmingCharacters(in: .whitespaces)
        entity.iconName = iconName
        entity.colorHex = colorHex
        entity.state = ModeState.inactive.rawValue
        if entity.createdAt == nil { entity.createdAt = .now }
        // Upsert BlockedAppsEntity
        let blockedReq = BlockedAppsEntity.fetchRequest()
        blockedReq.predicate = NSPredicate(format: "modeId == %@", id as CVarArg)
        blockedReq.fetchLimit = 1
        let blockedEntity = (try? ctx.fetch(blockedReq).first) ?? BlockedAppsEntity(context: ctx)
        blockedEntity.modeId = id
        blockedEntity.selectionData = try? JSONEncoder().encode(blockedApps)

        // Reemplazar rules
        let existingRuleReq = RuleEntity.fetchRequest()
        existingRuleReq.predicate = NSPredicate(format: "modeId == %@", id as CVarArg)
        for old in (try? ctx.fetch(existingRuleReq)) ?? [] { ctx.delete(old) }

        for rule in rules {
            let ruleEntity = RuleEntity(context: ctx)
            ruleEntity.id = rule.id
            ruleEntity.modeId = id
            ruleEntity.transition = rule.transition
            ruleEntity.conditionType = rule.conditionType
            ruleEntity.conditionConfig = rule.conditionConfig
            ruleEntity.guardLogic = rule.guardLogic
            ruleEntity.onGuardFail = rule.onGuardFail
            ruleEntity.isActive = rule.isActive
        }

        try ctx.save()
    }
}
