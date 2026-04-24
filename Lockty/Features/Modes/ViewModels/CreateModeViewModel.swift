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
    var nfcTags: [NFCTag] = []
    var locationZones: [LocationZone] = []
    var blockedApps: FamilyActivitySelection = .init()
    var linkedAppGroupID: UUID? = nil

    // Sub-sheet visibility
    var showIconColorPicker: Bool = false
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
            if let blockedEntity = try? ctx.fetch(blockedReq).first {
                linkedAppGroupID = blockedEntity.appGroupId

                if let appGroupID = blockedEntity.appGroupId,
                   let group = AppGroupStore.shared.fetch(id: appGroupID) {
                    blockedApps = group.selection
                } else if let data = blockedEntity.selectionData,
                          let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
                    blockedApps = decoded
                } else {
                    linkedAppGroupID = nil
                }
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

        let nfcReq = NFCTagEntity.fetchRequest()
        nfcReq.predicate = NSPredicate(format: "modeId == %@", modeId as CVarArg)
        nfcTags = ((try? ctx.fetch(nfcReq)) ?? []).compactMap { entity in
            guard
                let id = entity.id,
                let name = entity.name
            else { return nil }

            return NFCTag(
                id: id,
                modeId: entity.modeId,
                name: name,
                systemIdentifier: entity.systemIdentifier,
                technology: NFCTagTechnology(rawValue: entity.technology ?? "") ?? .generic,
                payload: entity.payload,
                createdAt: entity.createdAt ?? .now,
                lastSeenAt: entity.lastSeenAt
            )
        }

        let locationReq = LocationZoneEntity.fetchRequest()
        locationReq.predicate = NSPredicate(format: "modeId == %@", modeId as CVarArg)
        locationZones = ((try? ctx.fetch(locationReq)) ?? []).compactMap { entity in
            guard
                let id = entity.id,
                let name = entity.name,
                let triggerRaw = entity.trigger,
                let trigger = LocationZone.LocationTrigger(rawValue: triggerRaw)
            else { return nil }

            return LocationZone(
                id: id,
                modeId: entity.modeId,
                name: name,
                latitude: entity.latitude,
                longitude: entity.longitude,
                radius: entity.radius,
                trigger: trigger,
                allowsImmediateManualStopOnExit: entity.allowsImmediateManualStopOnExit,
                createdAt: entity.createdAt ?? .now
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
        blockedEntity.appGroupId = linkedAppGroupID
        blockedEntity.selectionData = try? JSONEncoder().encode(blockedApps)

        let existingNFCTagReq = NFCTagEntity.fetchRequest()
        existingNFCTagReq.predicate = NSPredicate(format: "modeId == %@", id as CVarArg)
        for old in (try? ctx.fetch(existingNFCTagReq)) ?? [] { ctx.delete(old) }

        let existingLocationReq = LocationZoneEntity.fetchRequest()
        existingLocationReq.predicate = NSPredicate(format: "modeId == %@", id as CVarArg)
        for old in (try? ctx.fetch(existingLocationReq)) ?? [] { ctx.delete(old) }

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

        for tag in nfcTags {
            let entity = NFCTagEntity(context: ctx)
            entity.id = tag.id
            entity.modeId = id
            entity.name = tag.name
            entity.systemIdentifier = tag.systemIdentifier
            entity.technology = tag.technology.rawValue
            entity.payload = tag.payload
            entity.createdAt = tag.createdAt
            entity.lastSeenAt = tag.lastSeenAt
        }

        for zone in locationZones {
            let entity = LocationZoneEntity(context: ctx)
            entity.id = zone.id
            entity.modeId = id
            entity.name = zone.name
            entity.latitude = zone.latitude
            entity.longitude = zone.longitude
            entity.radius = zone.radius
            entity.trigger = zone.trigger.rawValue
            entity.allowsImmediateManualStopOnExit = zone.allowsImmediateManualStopOnExit
            entity.createdAt = zone.createdAt
        }

        try ctx.save()
    }

    func applyAppGroup(_ group: AppGroup) {
        linkedAppGroupID = group.id
        blockedApps = group.selection
    }

    func unlinkAppGroup() {
        linkedAppGroupID = nil
    }
}
