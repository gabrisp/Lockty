//
//  CreateRuleViewModel.swift
//  Lockty
//

import SwiftUI
import CoreLocation

enum CreateRuleStep { case type, config }

struct CreateRuleOutput {
    let rule: Rule
    let nfcTag: NFCTag?
    let locationZone: LocationZone?
}

@MainActor
@Observable
final class CreateRuleViewModel: NSObject, CLLocationManagerDelegate {

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
    // NFC
    var nfcTagName: String = ""
    var nfcTechnology: NFCTagTechnology = .generic
    // Location
    var locationName: String = ""
    var locationRadius: Double = 100
    var locationCoordinate: CLLocationCoordinate2D? = nil
    var allowsImmediateManualStopOnExit: Bool = false
    // Friend
    var friendNote: String = ""
    // Reminder
    var reminderTime: Date = .now

    var canSave: Bool {
        guard let selectedType else { return false }
        switch selectedType {
        case .manual:
            return true
        case .nfc:
            return !nfcTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .location:
            return !locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .friend, .reminder:
            return true
        }
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func requestLocationIfNeeded() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
    }

    func buildOutput(modeId: UUID) -> CreateRuleOutput {
        let payload: RuleConditionConfigPayload
        var nfcTag: NFCTag?
        var locationZone: LocationZone?

        switch selectedType {
        case .manual:
            payload = .manual
        case .nfc:
            let createdTag = NFCTag(
                name: nfcTagName.trimmingCharacters(in: .whitespacesAndNewlines),
                technology: nfcTechnology
            )
            nfcTag = createdTag
            payload = RuleConditionConfigPayload(
                nfc: NFCConditionConfig(
                    tagId: createdTag.id,
                    tagName: createdTag.name,
                    technology: createdTag.technology,
                    requiresRegisteredTag: true
                )
            )
        case .location:
            let coordinate = locationCoordinate ?? locationManager.location?.coordinate
            let createdZone = LocationZone(
                name: locationName.trimmingCharacters(in: .whitespacesAndNewlines),
                latitude: coordinate?.latitude ?? 0,
                longitude: coordinate?.longitude ?? 0,
                radius: locationRadius,
                trigger: .enter,
                allowsImmediateManualStopOnExit: allowsImmediateManualStopOnExit
            )
            locationZone = createdZone
            payload = RuleConditionConfigPayload(
                location: LocationConditionConfig(
                    locationId: createdZone.id,
                    locationName: createdZone.name,
                    radius: createdZone.radius
                )
            )
        case .friend:
            payload = RuleConditionConfigPayload(
                friend: FriendConditionConfig(note: friendNote)
            )
        case .reminder:
            payload = RuleConditionConfigPayload(
                reminder: ReminderConditionConfig(timeIntervalSince1970: reminderTime.timeIntervalSince1970)
            )
        default:
            payload = .manual
        }

        let configData = (try? JSONEncoder().encode(payload)) ?? Data()

        let rule = Rule(
            id: UUID(),
            modeId: modeId,
            transition: transition.rawValue,
            conditionType: selectedType!.rawValue,
            conditionConfig: configData,
            guardLogic: GuardLogic.allMustPass.rawValue,
            onGuardFail: GuardFailBehavior.doNothing.rawValue,
            isActive: true
        )

        return CreateRuleOutput(rule: rule, nfcTag: nfcTag, locationZone: locationZone)
    }

    func buildRule(modeId: UUID) -> Rule {
        buildOutput(modeId: modeId).rule
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            locationCoordinate = locations.last?.coordinate
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Keep the form usable even if location capture fails.
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
