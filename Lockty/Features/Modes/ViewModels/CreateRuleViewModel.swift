//
//  CreateRuleViewModel.swift
//  Lockty
//

import SwiftUI
import CoreLocation

enum CreateRuleStep { case type, config }

@MainActor
@Observable
final class CreateRuleViewModel {

    var step: CreateRuleStep = .type
    var preselectedTransition: Transition? = nil

    var selectedType: ConditionType? = nil {
        didSet {
            if selectedType == .location {
                requestLocationIfNeeded()
            }
        }
    }
    var transition: Transition = .activate

    private let locationManager = CLLocationManager()

    // Manual — sin config extra
    // NFC — sin config extra (se lee el tag al activar)
    // Location
    var locationName: String = ""
    var locationRadius: Double = 100
    // Friend
    var friendNote: String = ""
    // Reminder
    var reminderTime: Date = .now

    var canSave: Bool { selectedType != nil }

    private func requestLocationIfNeeded() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func buildRule(modeId: UUID) -> Rule {
        let config: [String: Any]
        switch selectedType {
        case .location:
            config = ["name": locationName, "radius": locationRadius]
        case .friend:
            config = ["note": friendNote]
        case .reminder:
            config = ["time": reminderTime.timeIntervalSince1970]
        default:
            config = [:]
        }
        let configData = (try? JSONSerialization.data(withJSONObject: config)) ?? Data()

        return Rule(
            id: UUID(),
            modeId: modeId,
            transition: transition.rawValue,
            conditionType: selectedType!.rawValue,
            conditionConfig: configData,
            guardLogic: GuardLogic.allMustPass.rawValue,
            onGuardFail: GuardFailBehavior.doNothing.rawValue,
            isActive: true
        )
    }
}
