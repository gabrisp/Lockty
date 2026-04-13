//
//  Session.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import Foundation

struct Session: Identifiable, Hashable, Codable {
    let id: UUID
    var modeId: UUID?
    var startedAt: Date
    var endedAt: Date?
    var startTrigger: String    // TriggerSource.rawValue
    var endTrigger: String?
    var totalBreakTime: Int     // segundos
    var blockedCount: Int
    var payload: Data           // JSON snapshot del modo+rules en el momento

    var duration: TimeInterval {
        let end = endedAt ?? .now
        return end.timeIntervalSince(startedAt) - TimeInterval(totalBreakTime)
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
        guard let end = endedAt else { return Date.now.timeIntervalSince(startedAt) }
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

struct ActiveModeRuntimeStatus: Hashable {
    var elapsedTimeText: String
    var triggerLabel: String
    var blockedAppsSummary: String
    var rulesSummary: String
    var breakPolicy: BreakPolicyStatus
    var finishPolicy: FinishPolicyStatus
    var helperText: String
}

struct BreakPolicyStatus: Hashable {
    var breaksUsed: Int
    var maxBreaks: Int
    var maxBreakDurationText: String
    var minIntervalText: String
    var nextBreakAvailableInText: String?

    var breaksRemaining: Int {
        max(maxBreaks - breaksUsed, 0)
    }

    var canStartBreak: Bool {
        breaksRemaining > 0 && nextBreakAvailableInText == nil
    }
}

struct FinishPolicyStatus: Hashable {
    var canFinish: Bool
    var requirementText: String
}
