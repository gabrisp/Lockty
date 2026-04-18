//
//  ModeDetailViewModel.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI
import CoreData
import FamilyControls
import ManagedSettings

// MARK: - Supporting types

struct BlockedApp: Identifiable {
    let id = UUID()
    let token: ApplicationToken
}

struct BlockedCategory: Identifiable {
    let id = UUID()
    let token: ActivityCategoryToken
}

struct RuleParticipant: Identifiable {
    let id: UUID
    let label: String
    let sublabel: String
    let accentColor: Color

    init(id: UUID = UUID(), label: String, sublabel: String, accentColor: Color) {
        self.id = id
        self.label = label
        self.sublabel = sublabel
        self.accentColor = accentColor
    }
}

struct RuleGroup: Identifiable {
    let id = UUID()
    let transition: Transition
    let participants: [RuleParticipant]

    var title: String {
        switch transition {
        case .activate:   return "Activate"
        case .startBreak: return "Break"
        case .stop:       return "Finish"
        }
    }

    var accentColor: Color {
        switch transition {
        case .activate:   return .green
        case .startBreak: return .yellow
        case .stop:       return .red
        }
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class ModeDetailViewModel {

    // nil = modo nuevo (siempre en edición)
    private(set) var mode: Mode?
    var selectedTab: ModeDetailTab = .overview
    var blockedApps: [BlockedApp] = []
    var blockedCategories: [BlockedCategory] = []
    var nfcTags: [NFCTag] = []
    var locationZones: [LocationZone] = []
    var ruleGroups: [RuleGroup] = []
    var blockedAppsInsight: String? = nil
    var rulesInsight: String? = nil

    var isEditing: Bool = false
    var editVM: CreateModeViewModel? = nil
    var showDeleteAlert: Bool = false

    /// true cuando es modo nuevo (creación)
    var isNew: Bool { mode == nil }

    enum ModeDetailTab: String, CaseIterable {
        case overview = "Overview"
        case stats    = "Stats"
    }

    init(mode: Mode? = nil) {
        self.mode = mode
        if let mode {
            self.mode = fetchMode(id: mode.id) ?? mode
            loadData(for: mode.id)
        } else {
            // Creación: arranca en edición con VM vacío
            editVM = CreateModeViewModel()
            isEditing = true
        }
    }

    func startEditing() {
        guard let mode else { return }
        editVM = CreateModeViewModel(modeId: mode.id)
        selectedTab = .overview
        withAnimation(.snappy(duration: 0.3)) { isEditing = true }
    }

    func saveEdit() throws {
        try editVM?.save()
        if isNew {
            // Después de guardar modo nuevo, cargamos el modo recién creado
            // El caller hace pop
        } else {
            withAnimation(.snappy(duration: 0.3)) { isEditing = false }
            if let mode {
                self.mode = fetchMode(id: mode.id) ?? mode
                loadData(for: mode.id)
            }
        }
        editVM = nil
    }

    func cancelEdit() {
        if isNew { return } // en modo nuevo no se puede cancelar sin pop
        editVM = nil
        withAnimation(.snappy(duration: 0.3)) { isEditing = false }
    }

    func deleteMode() {
        guard let mode else { return }
        let ctx = PersistenceController.shared.context
        let id = mode.id

        let modeReq = ModeEntity.fetchRequest()
        modeReq.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        for e in (try? ctx.fetch(modeReq)) ?? [] { ctx.delete(e) }

        let ruleReq = RuleEntity.fetchRequest()
        ruleReq.predicate = NSPredicate(format: "modeId == %@", id as CVarArg)
        for e in (try? ctx.fetch(ruleReq)) ?? [] { ctx.delete(e) }

        let blockedReq = BlockedAppsEntity.fetchRequest()
        blockedReq.predicate = NSPredicate(format: "modeId == %@", id as CVarArg)
        for e in (try? ctx.fetch(blockedReq)) ?? [] { ctx.delete(e) }

        try? ctx.save()
    }

    func loadData(for id: UUID) {
        let ctx = PersistenceController.shared.context

        let req = RuleEntity.fetchRequest()
        req.predicate = NSPredicate(format: "modeId == %@", id as CVarArg)
        let entities = (try? ctx.fetch(req)) ?? []

        var grouped: [Transition: [RuleParticipant]] = [:]
        for e in entities {
            guard let t = Transition(rawValue: e.transition ?? "") else { continue }
            grouped[t, default: []].append(participantFrom(entity: e))
        }
        ruleGroups = Transition.allCases.compactMap { t in
            guard let p = grouped[t], !p.isEmpty else { return nil }
            return RuleGroup(transition: t, participants: p)
        }

        let bReq = BlockedAppsEntity.fetchRequest()
        bReq.predicate = NSPredicate(format: "modeId == %@", id as CVarArg)
        bReq.fetchLimit = 1
        if let entity = try? ctx.fetch(bReq).first,
           let data = entity.selectionData,
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            blockedApps = selection.applicationTokens.map { BlockedApp(token: $0) }
            blockedCategories = selection.categoryTokens.map { BlockedCategory(token: $0) }
        }

        let nfcReq = NFCTagEntity.fetchRequest()
        nfcReq.predicate = NSPredicate(format: "modeId == %@", id as CVarArg)
        nfcTags = ((try? ctx.fetch(nfcReq)) ?? []).compactMap { entity in
            guard
                let entityID = entity.id,
                let name = entity.name
            else { return nil }

            return NFCTag(
                id: entityID,
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
        locationReq.predicate = NSPredicate(format: "modeId == %@", id as CVarArg)
        locationZones = ((try? ctx.fetch(locationReq)) ?? []).compactMap { entity in
            guard
                let entityID = entity.id,
                let name = entity.name,
                let triggerRaw = entity.trigger,
                let trigger = LocationZone.LocationTrigger(rawValue: triggerRaw)
            else { return nil }

            return LocationZone(
                id: entityID,
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

    // MARK: - Private

    func participantFrom(rule: Rule) -> RuleParticipant {
        participant(
            id: rule.id,
            conditionType: ConditionType(rawValue: rule.conditionType),
            conditionConfig: rule.conditionConfig
        )
    }

    private func participantFrom(entity: RuleEntity) -> RuleParticipant {
        participant(
            id: entity.id ?? UUID(),
            conditionType: ConditionType(rawValue: entity.conditionType ?? ""),
            conditionConfig: entity.conditionConfig
        )
    }

    private func participant(id: UUID, conditionType: ConditionType?, conditionConfig: Data?) -> RuleParticipant {
        let payload = decodedPayload(conditionConfig, conditionType: conditionType)

        switch conditionType {
        case .manual:
            return RuleParticipant(id: id, label: "Manual", sublabel: "", accentColor: .blue)
        case .nfc:
            let tagName = payload.nfc?.tagName ?? nfcTag(id: payload.nfc?.tagId)?.name ?? ""
            return RuleParticipant(id: id, label: "NFC", sublabel: tagName, accentColor: .purple)
        case .location:
            let locationName = payload.location?.locationName ?? locationZone(id: payload.location?.locationId)?.name ?? ""
            return RuleParticipant(id: id, label: "Ubicación", sublabel: locationName, accentColor: .orange)
        case .friend:
            return RuleParticipant(id: id, label: "Amigo", sublabel: payload.friend?.note ?? "", accentColor: .green)
        case .reminder:
            let ts = payload.reminder?.timeIntervalSince1970 ?? 0
            let label = Date(timeIntervalSince1970: ts).formatted(date: .omitted, time: .shortened)
            return RuleParticipant(id: id, label: "Recordatorio", sublabel: label, accentColor: .yellow)
        case nil:
            return RuleParticipant(id: id, label: "?", sublabel: "", accentColor: .gray)
        }
    }

    private func decodedPayload(_ data: Data?, conditionType: ConditionType?) -> RuleConditionConfigPayload {
        guard let data else { return .manual }
        if let payload = try? JSONDecoder().decode(RuleConditionConfigPayload.self, from: data) {
            return payload
        }

        guard
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let conditionType
        else {
            return .manual
        }

        switch conditionType {
        case .manual:
            return .manual
        case .nfc:
            return RuleConditionConfigPayload(
                nfc: NFCConditionConfig(tagName: object["name"] as? String ?? "")
            )
        case .location:
            return RuleConditionConfigPayload(
                location: LocationConditionConfig(
                    locationName: object["name"] as? String ?? "",
                    radius: object["radius"] as? Double ?? 100
                )
            )
        case .friend:
            return RuleConditionConfigPayload(
                friend: FriendConditionConfig(note: object["note"] as? String ?? "")
            )
        case .reminder:
            return RuleConditionConfigPayload(
                reminder: ReminderConditionConfig(timeIntervalSince1970: object["time"] as? TimeInterval ?? 0)
            )
        }
    }

    private func nfcTag(id: UUID?) -> NFCTag? {
        guard let id else { return nil }
        return nfcTags.first { $0.id == id }
    }

    private func locationZone(id: UUID?) -> LocationZone? {
        guard let id else { return nil }
        return locationZones.first { $0.id == id }
    }

    private func fetchMode(id: UUID) -> Mode? {
        let ctx = PersistenceController.shared.context
        let req = ModeEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        req.fetchLimit = 1
        guard let entity = try? ctx.fetch(req).first,
              let entityID = entity.id,
              let name = entity.name,
              let iconName = entity.iconName,
              let colorHex = entity.colorHex,
              let state = entity.state,
              let createdAt = entity.createdAt else {
            return nil
        }

        return Mode(
            id: entityID,
            name: name,
            iconName: iconName,
            colorHex: colorHex,
            state: state,
            createdAt: createdAt
        )
    }
}
