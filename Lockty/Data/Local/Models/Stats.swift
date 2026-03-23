//
//  Session.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import Foundation

struct Session: Identifiable, Hashable {
    let id: UUID
    var modeId: UUID
    var modeName: String
    var modeColorHex: String
    var startedAt: Date
    var endedAt: Date?
    var startTrigger: TriggerSource
    var endTrigger: TriggerSource?
    var startRuleId: UUID?
    var endRuleId: UUID?
    var totalBreakTime: TimeInterval
    var blockedCount: Int

    var duration: TimeInterval {
        guard let end = endedAt else {
            return Date.now.timeIntervalSince(startedAt) - totalBreakTime
        }
        return end.timeIntervalSince(startedAt) - totalBreakTime
    }

    var isActive: Bool { endedAt == nil }
}

struct SessionBreak: Identifiable, Hashable {
    let id: UUID
    var sessionId: UUID
    var modeId: UUID
    var startedAt: Date
    var endedAt: Date?
    var startTrigger: TriggerSource
    var endTrigger: TriggerSource?
    var startRuleId: UUID?
    var endRuleId: UUID?
    var maxDuration: TimeInterval
    var wasForced: Bool

    var duration: TimeInterval {
        guard let end = endedAt else {
            return Date.now.timeIntervalSince(startedAt)
        }
        return end.timeIntervalSince(startedAt)
    }

    var isActive: Bool { endedAt == nil }
}

struct AppBlock: Identifiable, Hashable {
    let id: UUID
    var sessionId: UUID
    var modeId: UUID
    var appBundleId: String
    var appName: String
    var timestamp: Date
    var duringBreak: Bool
}
