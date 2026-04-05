//
//  ModeDetailViewModel.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

// MARK: - Supporting view models

struct BlockedApp: Identifiable {
    let id = UUID()
    let name: String
    let bundleId: String
    /// SF Symbol para mostrar mientras no hay icono real
    let iconSymbol: String
}

struct RuleParticipant: Identifiable {
    let id = UUID()
    let label: String    // "Friend", "Location", "NFC"…
    let sublabel: String // nombre del amigo, zona, tag…
    let accentColor: Color
}

struct RuleGroup: Identifiable {
    let id = UUID()
    let transition: Transition
    let participants: [RuleParticipant]

    var title: String {
        switch transition {
        case .activate:    return "Activate"
        case .startBreak:  return "Break"
        case .stop:        return "Finish"
        }
    }

    var accentColor: Color {
        switch transition {
        case .activate:    return .green
        case .startBreak:  return .yellow
        case .stop:        return .red
        }
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class ModeDetailViewModel {

    // MARK: State
    let mode: Mode
    var selectedTab: ModeDetailTab = .overview
    var blockedApps: [BlockedApp] = []
    var ruleGroups: [RuleGroup] = []
    var blockedAppsInsight: String? = nil
    var rulesInsight: String? = nil

    enum ModeDetailTab: String, CaseIterable {
        case overview = "Overview"
        case stats    = "Stats"
    }

    // MARK: Init
    init(mode: Mode) {
        self.mode = mode
        loadDummyData()
    }

    // MARK: Private
    private func loadDummyData() {
        blockedApps = [
            BlockedApp(name: "Instagram", bundleId: "com.instagram.ios",          iconSymbol: "camera"),
            BlockedApp(name: "Facebook",  bundleId: "com.facebook.ios",           iconSymbol: "person.2"),
            BlockedApp(name: "Facebook",  bundleId: "com.facebook.ios.2",         iconSymbol: "person.2"),
            BlockedApp(name: "Facebook",  bundleId: "com.facebook.ios.3",         iconSymbol: "person.2"),
            BlockedApp(name: "Facebook",  bundleId: "com.facebook.ios.4",         iconSymbol: "person.2"),
            BlockedApp(name: "Twitter",   bundleId: "com.atebits.Tweetie2",       iconSymbol: "bird"),
            BlockedApp(name: "LinkedIn",  bundleId: "com.linkedin.LinkedIn",      iconSymbol: "briefcase"),
            BlockedApp(name: "TikTok",    bundleId: "com.zhiliaoapp.musically",   iconSymbol: "music.note"),
        ]

        let friendParticipants = (0..<3).map { _ in
            RuleParticipant(label: "Friend", sublabel: "Jorge", accentColor: .green)
        }
        let breakParticipants = (0..<3).map { _ in
            RuleParticipant(label: "Friend", sublabel: "Jorge", accentColor: .yellow)
        }
        let finishParticipants = (0..<3).map { _ in
            RuleParticipant(label: "Friend", sublabel: "Jorge", accentColor: .red)
        }

        ruleGroups = [
            RuleGroup(transition: .activate,   participants: friendParticipants),
            RuleGroup(transition: .startBreak, participants: breakParticipants),
            RuleGroup(transition: .stop,       participants: finishParticipants),
        ]

        blockedAppsInsight = "Instagram accounts for 78% of your blocked attempts. Consider if the other 2 apps are worth blocking."
        rulesInsight = "Your Location rule has never fired — your NFC tag always beats it. You could simplify by removing it."
    }
}
