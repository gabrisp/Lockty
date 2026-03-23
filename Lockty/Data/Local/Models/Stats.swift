//
//  Stats.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import Foundation

struct DailyAggregate: Identifiable, Hashable {
    let id: UUID
    var date: Date
    var modeId: UUID?
    var focusTime: TimeInterval
    var sessions: Int
    var breaks: Int
    var blocked: Int
}

struct AppDailyAggregate: Identifiable, Hashable {
    let id: UUID
    var date: Date
    var modeId: UUID
    var appBundleId: String
    var appName: String
    var blocked: Int
}

enum StatsPeriod: String, Codable, CaseIterable {
    case day
    case week
    case month
    case year
    case custom
}

struct StatsFilters: Equatable {
    var modeId: UUID? = nil
    var period: StatsPeriod = .day
    var startDate: Date = .now
    var endDate: Date = .now
    var appBundleId: String? = nil

    static let empty = StatsFilters()

    var isActive: Bool {
        modeId != nil || appBundleId != nil || period != .day
    }

    var activeCount: Int {
        var count = 0
        if modeId != nil { count += 1 }
        if appBundleId != nil { count += 1 }
        if period != .day { count += 1 }
        return count
    }
}

struct DailyStats: Hashable {
    var date: Date
    var focusTime: TimeInterval
    var sessions: Int
    var breaks: Int
    var blocked: Int
    var topApps: [AppDailyAggregate]       // ordenados por count desc
    var vsDelta: TimeInterval
    var streak: Int
    var bestStreak: Int
    var avgSessionDuration: TimeInterval

    var topApp: AppDailyAggregate? { topApps.first }

    var focusFormatted: String {
        let hours = Int(focusTime) / 3600
        let minutes = Int(focusTime) / 60 % 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }

    var vsDeltaFormatted: String {
        let abs = Swift.abs(vsDelta)
        let hours = Int(abs) / 3600
        let minutes = Int(abs) / 60 % 60
        let formatted = hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
        return vsDelta >= 0 ? "↑ \(formatted)" : "↓ \(formatted)"
    }
}
struct WeeklyStats: Hashable {
    var weekStart: Date
    var weekEnd: Date
    var totalFocusTime: TimeInterval
    var sessions: Int
    var breaks: Int
    var blocked: Int
    var dailyBreakdown: [DailyStats]
    var vsLastWeek: TimeInterval
    var streak: Int
}

struct MonthlyStats: Hashable {
    var month: Date
    var totalFocusTime: TimeInterval
    var sessions: Int
    var breaks: Int
    var blocked: Int
    var weeklyBreakdown: [WeeklyStats]
    var vsLastMonth: TimeInterval
    var consistencyPercent: Double
}
