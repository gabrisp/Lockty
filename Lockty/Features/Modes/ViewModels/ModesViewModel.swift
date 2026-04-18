//
//  ModesViewModel.swift
//  Lockty
//

import SwiftUI
import CoreData

struct ModeActivationPrompt: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let icon: String
}

@MainActor
@Observable
final class ModesViewModel {

    var modes: [Mode] = []
    var activationPrompt: ModeActivationPrompt? = nil

    var activeMode: Mode? {
        modes.first { $0.state == ModeState.active.rawValue }
    }

    var inactiveModes: [Mode] {
        modes.filter { $0.state != ModeState.active.rawValue }
    }

    var activeModeStatus: ActiveModeRuntimeStatus? {
        guard let activeMode else { return nil }
        return runtimeStatus(for: activeMode)
    }

    var isEmpty: Bool { modes.isEmpty }

    func loadModes() {
        let ctx = PersistenceController.shared.context
        let req = ModeEntity.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        let entities = (try? ctx.fetch(req)) ?? []
        modes = entities.compactMap { entity in
            guard let id = entity.id,
                  let name = entity.name,
                  let iconName = entity.iconName,
                  let colorHex = entity.colorHex,
                  let state = entity.state,
                  let createdAt = entity.createdAt else { return nil }
            return Mode(id: id, name: name, iconName: iconName, colorHex: colorHex, state: state, createdAt: createdAt)
        }
    }

    func handlePlay(for mode: Mode) {
        let activateRules = activationRules(for: mode.id)

        guard let firstRule = activateRules.first else {
            activationPrompt = ModeActivationPrompt(
                title: "No activation rule",
                message: "Add an activation rule before starting this mode from Home.",
                icon: "exclamationmark.circle"
            )
            return
        }

        guard let conditionType = ConditionType(rawValue: firstRule.conditionType) else { return }

        switch conditionType {
        case .manual:
            activateMode(mode.id)
        case .nfc:
            let payload = firstRule.typedConditionConfig
            let tagName = payload.nfc?.tagName
            activationPrompt = ModeActivationPrompt(
                title: "NFC required",
                message: tagName?.isEmpty == false
                    ? "This mode starts by tapping the NFC tag “\(tagName!)”."
                    : "This mode starts by tapping its NFC tag.",
                icon: "wave.3.right"
            )
        case .location:
            let payload = firstRule.typedConditionConfig
            let place = payload.location?.locationName.isEmpty == false
                ? payload.location?.locationName
                : "this location"
            activationPrompt = ModeActivationPrompt(
                title: "Location needed",
                message: "You are not in \(place ?? "this location") right now.",
                icon: "location"
            )
        case .friend:
            let payload = firstRule.typedConditionConfig
            let note = payload.friend?.note
            activationPrompt = ModeActivationPrompt(
                title: "Friend trigger",
                message: note?.isEmpty == false ? note! : "This mode can only be started by a friend trigger.",
                icon: "person.2"
            )
        case .reminder:
            let payload = firstRule.typedConditionConfig
            let ts = payload.reminder?.timeIntervalSince1970 ?? 0
            let time = Date(timeIntervalSince1970: ts).formatted(date: .omitted, time: .shortened)
            activationPrompt = ModeActivationPrompt(
                title: "Scheduled mode",
                message: "This mode starts from its reminder at \(time).",
                icon: "bell"
            )
        }
    }

    private func activateMode(_ modeID: UUID) {
        let ctx = PersistenceController.shared.context
        let req = ModeEntity.fetchRequest()
        let entities = (try? ctx.fetch(req)) ?? []

        for entity in entities {
            guard let id = entity.id else { continue }
            entity.state = (id == modeID) ? ModeState.active.rawValue : ModeState.inactive.rawValue
        }

        try? ctx.save()
        loadModes()
    }

    private func activationRules(for modeID: UUID) -> [Rule] {
        let ctx = PersistenceController.shared.context
        let req = RuleEntity.fetchRequest()
        req.predicate = NSPredicate(
            format: "modeId == %@ AND transition == %@ AND isActive == YES",
            modeID as CVarArg,
            Transition.activate.rawValue
        )

        let entities = (try? ctx.fetch(req)) ?? []
        return entities.compactMap { entity in
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

    private func runtimeStatus(for mode: Mode) -> ActiveModeRuntimeStatus {
        if mode.name.localizedCaseInsensitiveContains("university")
            || mode.name.localizedCaseInsensitiveContains("universidad") {
            return .previewUniversity
        }

        return ActiveModeRuntimeStatus(
            elapsedTimeText: "42m",
            triggerLabel: "Manual",
            blockedAppsSummary: "2 blocked apps",
            rulesSummary: "3 active rules",
            breakPolicy: BreakPolicyStatus(
                breaksUsed: 0,
                maxBreaks: 2,
                maxBreakDurationText: "10m max",
                minIntervalText: "20m between breaks",
                nextBreakAvailableInText: nil
            ),
            finishPolicy: FinishPolicyStatus(
                canFinish: true,
                requirementText: "You can finish now"
            ),
            helperText: "Break and finish availability depend on this mode's trigger rules."
        )
    }
}
