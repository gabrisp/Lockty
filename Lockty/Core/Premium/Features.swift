//
//  Features.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import Foundation

enum ProFeature: String, Hashable, CaseIterable {
    case unlimitedModes
    case friendRules
    case nfcRules
    case customGuards
    case aiInsights
    case cloudSync

    var title: String {
        switch self {
        case .unlimitedModes: return "Unlimited Modes"
        case .friendRules:    return "Friend Rules"
        case .nfcRules:       return "NFC Rules"
        case .customGuards:   return "Custom Guards"
        case .aiInsights:     return "AI Insights"
        case .cloudSync:      return "Cloud Sync"
        }
    }

    var description: String {
        switch self {
        case .unlimitedModes: return "Create as many modes as you need. Free plan is limited to 2."
        case .friendRules:    return "Let a trusted friend block you on demand. Accountability that works."
        case .nfcRules:       return "Tap an NFC tag to instantly activate or stop a mode."
        case .customGuards:   return "Add conditions to your rules — location, time, break count and more."
        case .aiInsights:     return "Get personalized insights about your focus patterns powered by Apple Intelligence."
        case .cloudSync:      return "Sync your modes and stats across all your devices via iCloud."
        }
    }

    var icon: String {
        switch self {
        case .unlimitedModes: return "square.stack.3d.up.fill"
        case .friendRules:    return "person.2.fill"
        case .nfcRules:       return "wave.3.right"
        case .customGuards:   return "shield.lefthalf.filled"
        case .aiInsights:     return "sparkles"
        case .cloudSync:      return "icloud.fill"
        }
    }
}
