//
//  Model.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import Foundation

// MARK: - Enums

enum ModeState: String, Codable, CaseIterable {
    case inactive
    case active
    case onBreak
}

enum Transition: String, Codable, CaseIterable {
    case activate
    case startBreak
    case stop
}

enum ConditionType: String, Codable, CaseIterable {
    case manual
    case nfc
    case location
    case friend
    case reminder
}

enum GuardType: String, Codable, CaseIterable {
    case location
    case timeWindow
    case breakCount
    case activeDuration
}

enum GuardLogic: String, Codable {
    case allMustPass
    case anyMustPass
}

enum GuardFailBehavior: String, Codable {
    case doNothing
    case requireConfirmation
    case triggerAnyway
}

enum TriggerSource: String, Codable {
    case manual
    case nfc
    case location
    case friend
    case reminder
}

enum PermissionType: String, Codable {
    case preAuthorized
    case onRequest
}

enum NFCTagTechnology: String, Codable, CaseIterable {
    case generic
    case ndef
    case miFare
    case iso7816
    case iso15693
    case felica
}

// MARK: - Models

struct Mode: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var state: String   // ModeState.rawValue
    var createdAt: Date
}

struct Rule: Identifiable, Hashable, Codable {
    let id: UUID
    var modeId: UUID
    var transition: String      // Transition.rawValue
    var conditionType: String   // ConditionType.rawValue
    var conditionConfig: Data
    var guardLogic: String      // GuardLogic.rawValue
    var onGuardFail: String     // GuardFailBehavior.rawValue
    var isActive: Bool
}

struct RuleConditionConfigPayload: Hashable, Codable {
    var manual: ManualConditionConfig?
    var nfc: NFCConditionConfig?
    var location: LocationConditionConfig?
    var friend: FriendConditionConfig?
    var reminder: ReminderConditionConfig?

    static let manual = RuleConditionConfigPayload(manual: .init())

    init(
        manual: ManualConditionConfig? = nil,
        nfc: NFCConditionConfig? = nil,
        location: LocationConditionConfig? = nil,
        friend: FriendConditionConfig? = nil,
        reminder: ReminderConditionConfig? = nil
    ) {
        self.manual = manual
        self.nfc = nfc
        self.location = location
        self.friend = friend
        self.reminder = reminder
    }
}

struct ManualConditionConfig: Hashable, Codable {
}

struct NFCConditionConfig: Hashable, Codable {
    var tagId: UUID?
    var tagName: String
    var technology: NFCTagTechnology
    var requiresRegisteredTag: Bool

    init(
        tagId: UUID? = nil,
        tagName: String = "",
        technology: NFCTagTechnology = .generic,
        requiresRegisteredTag: Bool = true
    ) {
        self.tagId = tagId
        self.tagName = tagName
        self.technology = technology
        self.requiresRegisteredTag = requiresRegisteredTag
    }
}

struct LocationConditionConfig: Hashable, Codable {
    var locationId: UUID?
    var locationName: String
    var radius: Double

    init(locationId: UUID? = nil, locationName: String = "", radius: Double = 100) {
        self.locationId = locationId
        self.locationName = locationName
        self.radius = radius
    }
}

struct FriendConditionConfig: Hashable, Codable {
    var note: String

    init(note: String = "") {
        self.note = note
    }
}

struct ReminderConditionConfig: Hashable, Codable {
    var timeIntervalSince1970: TimeInterval

    init(timeIntervalSince1970: TimeInterval) {
        self.timeIntervalSince1970 = timeIntervalSince1970
    }
}

struct RuleGuard: Identifiable, Hashable, Codable {
    let id: UUID
    var ruleId: UUID
    var type: String    // GuardType.rawValue
    var config: Data
}

struct NFCTag: Identifiable, Hashable, Codable {
    let id: UUID
    var modeId: UUID?
    var name: String
    var systemIdentifier: String?
    var technology: NFCTagTechnology
    var payload: Data?
    var createdAt: Date
    var lastSeenAt: Date?

    init(
        id: UUID = UUID(),
        modeId: UUID? = nil,
        name: String,
        systemIdentifier: String? = nil,
        technology: NFCTagTechnology = .generic,
        payload: Data? = nil,
        createdAt: Date = .now,
        lastSeenAt: Date? = nil
    ) {
        self.id = id
        self.modeId = modeId
        self.name = name
        self.systemIdentifier = systemIdentifier
        self.technology = technology
        self.payload = payload
        self.createdAt = createdAt
        self.lastSeenAt = lastSeenAt
    }
}

struct LocationZone: Identifiable, Hashable, Codable {
    let id: UUID
    var modeId: UUID?
    var name: String
    var latitude: Double
    var longitude: Double
    var radius: Double
    var trigger: LocationTrigger
    var allowsImmediateManualStopOnExit: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        modeId: UUID? = nil,
        name: String,
        latitude: Double,
        longitude: Double,
        radius: Double,
        trigger: LocationTrigger,
        allowsImmediateManualStopOnExit: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.modeId = modeId
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.trigger = trigger
        self.allowsImmediateManualStopOnExit = allowsImmediateManualStopOnExit
        self.createdAt = createdAt
    }

    enum LocationTrigger: String, Codable {
        case enter
        case exit
    }
}

extension Rule {
    var typedConditionConfig: RuleConditionConfigPayload {
        guard let decoded = try? JSONDecoder().decode(RuleConditionConfigPayload.self, from: conditionConfig) else {
            return legacyDecodedConditionConfig
        }
        return decoded
    }

    mutating func setTypedConditionConfig(_ payload: RuleConditionConfigPayload) {
        conditionConfig = (try? JSONEncoder().encode(payload)) ?? Data()
    }

    private var legacyDecodedConditionConfig: RuleConditionConfigPayload {
        guard
            let object = try? JSONSerialization.jsonObject(with: conditionConfig) as? [String: Any],
            let type = ConditionType(rawValue: conditionType)
        else {
            return .manual
        }

        switch type {
        case .manual:
            return .manual
        case .nfc:
            return RuleConditionConfigPayload(
                nfc: NFCConditionConfig(
                    tagName: object["name"] as? String ?? "",
                    technology: .generic,
                    requiresRegisteredTag: true
                )
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
}
