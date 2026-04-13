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
        switch conditionType {
        case .manual:
            return RuleParticipant(id: id, label: "Manual", sublabel: "", accentColor: .blue)
        case .nfc:
            return RuleParticipant(id: id, label: "NFC", sublabel: "", accentColor: .purple)
        case .location:
            let config = decoded(conditionConfig)
            return RuleParticipant(id: id, label: "Ubicación", sublabel: config["name"] as? String ?? "", accentColor: .orange)
        case .friend:
            let config = decoded(conditionConfig)
            return RuleParticipant(id: id, label: "Amigo", sublabel: config["note"] as? String ?? "", accentColor: .green)
        case .reminder:
            let config = decoded(conditionConfig)
            let ts = config["time"] as? TimeInterval ?? 0
            let label = Date(timeIntervalSince1970: ts).formatted(date: .omitted, time: .shortened)
            return RuleParticipant(id: id, label: "Recordatorio", sublabel: label, accentColor: .yellow)
        case nil:
            return RuleParticipant(id: id, label: "?", sublabel: "", accentColor: .gray)
        }
    }

    private func decoded(_ data: Data?) -> [String: Any] {
        guard let data else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
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
