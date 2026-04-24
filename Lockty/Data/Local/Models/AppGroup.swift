//
//  AppGroup.swift
//  Lockty
//

import Foundation
import FamilyControls

struct AppGroup: Identifiable, Codable {
    let id: UUID
    var name: String
    var emoji: String
    var selection: FamilyActivitySelection
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        selection: FamilyActivitySelection,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.selection = selection
        self.createdAt = createdAt
    }
}

struct AppGroupSelectionStats {
    var applications: Int
    var categories: Int
    var webDomains: Int

    var totalItems: Int {
        applications + categories + webDomains
    }

    var isEmpty: Bool {
        totalItems == 0
    }
}

extension AppGroup {
    var stats: AppGroupSelectionStats {
        Self.stats(for: selection)
    }

    var summary: String {
        Self.summary(for: selection)
    }

    func matches(selection other: FamilyActivitySelection) -> Bool {
        Self.matches(selection, other)
    }

    static func stats(for selection: FamilyActivitySelection) -> AppGroupSelectionStats {
        AppGroupSelectionStats(
            applications: selection.applicationTokens.count,
            categories: selection.categoryTokens.count,
            webDomains: selection.webDomainTokens.count
        )
    }

    static func summary(for selection: FamilyActivitySelection) -> String {
        let stats = stats(for: selection)
        var parts: [String] = []

        if stats.applications > 0 {
            parts.append("\(stats.applications) app\(stats.applications == 1 ? "" : "s")")
        }
        if stats.categories > 0 {
            parts.append("\(stats.categories) categor\(stats.categories == 1 ? "y" : "ies")")
        }
        if stats.webDomains > 0 {
            parts.append("\(stats.webDomains) web")
        }

        return parts.isEmpty ? "No items" : parts.joined(separator: " · ")
    }

    static func matches(_ lhs: FamilyActivitySelection, _ rhs: FamilyActivitySelection) -> Bool {
        lhs.applicationTokens == rhs.applicationTokens &&
        lhs.categoryTokens == rhs.categoryTokens &&
        lhs.webDomainTokens == rhs.webDomainTokens
    }
}
