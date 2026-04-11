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

struct RuleGuard: Identifiable, Hashable, Codable {
    let id: UUID
    var ruleId: UUID
    var type: String    // GuardType.rawValue
    var config: Data
}

struct NFCTag: Identifiable, Hashable {
    let id: UUID
    var name: String
    var tagId: String
}

struct LocationZone: Identifiable, Hashable {
    let id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var radius: Double
    var trigger: LocationTrigger

    enum LocationTrigger: String, Codable {
        case enter
        case exit
    }
}
