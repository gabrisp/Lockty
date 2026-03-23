//
//  AI.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import Foundation

struct CachedInsight: Identifiable, Hashable {
    let id: UUID
    var contextKey: String
    var text: String
    var generatedAt: Date
    var expiresAt: Date

    var isExpired: Bool { Date.now > expiresAt }
}

enum InsightContext {
    // Stats
    case dailySummary(stats: DailyStats)
    case weeklyPattern(stats: WeeklyStats)
    case monthlyPattern(stats: MonthlyStats)
    case streakRisk(current: Int, best: Int)
    case appResistance(appName: String, today: Int, yesterday: Int)
    case peakFocusTime(hour: Int, consistency: Double)

    // Mode detail
    case sessionInProgress(duration: TimeInterval, personalBest: TimeInterval)
    case sessionCompleted(duration: TimeInterval, blocked: Int, breaks: Int)
    case ruleUnused(ruleName: String, modeName: String, conditionType: ConditionType)
    case scheduleInconsistency(modeName: String, missedDays: [String])
    case breakPatternDetected(avgBreakDuration: TimeInterval, breakCount: Int)

    // Social
    case friendPattern(friendName: String, action: String, dayOfWeek: String)

    var cacheKey: String {
        switch self {
        case .dailySummary(let s):
            return "daily_\(s.date.ISO8601Format())"
        case .weeklyPattern(let s):
            return "weekly_\(s.weekStart.ISO8601Format())"
        case .monthlyPattern(let s):
            return "monthly_\(s.month.ISO8601Format())"
        case .streakRisk(let current, _):
            return "streak_risk_\(current)"
        case .appResistance(let app, _, _):
            return "app_resistance_\(app)_\(Date.now.ISO8601Format())"
        case .sessionInProgress:
            return "session_inprogress_\(UUID())"
        case .sessionCompleted(let d, _, _):
            return "session_completed_\(d)"
        case .ruleUnused(_, let mode, _):
            return "rule_unused_\(mode)"
        case .scheduleInconsistency(let mode, _):
            return "schedule_\(mode)"
        case .breakPatternDetected:
            return "break_pattern_\(Date.now.ISO8601Format())"
        case .peakFocusTime(let hour, _):
            return "peak_\(hour)"
        case .friendPattern(let friend, let action, _):
            return "friend_\(friend)_\(action)"
        }
    }

    var ttl: TimeInterval {
        switch self {
        case .dailySummary:          return 86400
        case .weeklyPattern:         return 86400 * 7
        case .monthlyPattern:        return 86400 * 30
        case .streakRisk:            return 3600
        case .appResistance:         return 86400
        case .sessionInProgress:     return 0
        case .sessionCompleted:      return 86400 * 7
        case .ruleUnused:            return 86400 * 7
        case .scheduleInconsistency: return 86400 * 7
        case .breakPatternDetected:  return 86400
        case .peakFocusTime:         return 86400 * 7
        case .friendPattern:         return 86400 * 7
        }
    }
}
