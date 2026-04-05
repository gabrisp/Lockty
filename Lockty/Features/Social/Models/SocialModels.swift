//
//  SocialModels.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import Foundation

// MARK: - Friend

struct Friend: Identifiable {
    let id: UUID
    let displayName: String
    let username: String
    let avatarURL: URL?
    /// Modos a los que este amigo tiene acceso para verte
    let sharedModes: [FriendMode]
    /// Sin permisos de ningún modo
    var hasNoPermissions: Bool { sharedModes.isEmpty }
}

struct FriendMode: Identifiable {
    let id: UUID
    let name: String
    let colorHex: String
}

// MARK: - Social Request

enum SocialRequestType {
    case friendRequest
    case action         // accept/decline de breaks, etc.
}

struct SocialRequest: Identifiable {
    let id: UUID
    let fromUser: String
    let type: SocialRequestType
}

// MARK: - Activity Event

enum ActivityEventKind {
    case blocked
    case rejectedBreak
    case acceptedBreak
    case sentRequest
    case acceptedRequest
}

struct ActivityEvent: Identifiable {
    let id: UUID
    let actorName: String
    let actorAvatarURL: URL?
    let kind: ActivityEventKind
    let modeName: String?
    let modeColorHex: String?
    let timestamp: Date

    var description: String {
        switch kind {
        case .blocked:          return "blocked you"
        case .rejectedBreak:    return "rejected your break"
        case .acceptedBreak:    return "accepted your break"
        case .sentRequest:      return "sent you a request"
        case .acceptedRequest:  return "accepted your request"
        }
    }

    var relativeTime: String {
        let diff = Date.now.timeIntervalSince(timestamp)
        let hours = Int(diff / 3600)
        if hours < 1 { return "now" }
        if hours < 24 { return "\(hours)h" }
        return "\(hours / 24)d"
    }
}

// MARK: - Dummy preview data

extension Friend {
    static let preview: [Friend] = [
        Friend(
            id: UUID(), displayName: "Gabriel", username: "@gabrisp", avatarURL: nil,
            sharedModes: [FriendMode(id: UUID(), name: "Gym", colorHex: "#FFDFC3")]
        ),
        Friend(
            id: UUID(), displayName: "Juan", username: "@juan", avatarURL: nil,
            sharedModes: []
        ),
        Friend(
            id: UUID(), displayName: "Lulu", username: "@lulu", avatarURL: nil,
            sharedModes: [
                FriendMode(id: UUID(), name: "Gym",   colorHex: "#FFDFC3"),
                FriendMode(id: UUID(), name: "Study", colorHex: "#C3D7FF"),
            ]
        ),
        Friend(
            id: UUID(), displayName: "Gabriel", username: "@gabrisp2", avatarURL: nil,
            sharedModes: []
        ),
        Friend(
            id: UUID(), displayName: "Gabriel", username: "@gabrisp3", avatarURL: nil,
            sharedModes: []
        ),
    ]
}

extension ActivityEvent {
    static let preview: [ActivityEvent] = [
        ActivityEvent(
            id: UUID(), actorName: "Gabriel", actorAvatarURL: nil,
            kind: .blocked, modeName: "Gym", modeColorHex: "#FFDFC3",
            timestamp: Date.now.addingTimeInterval(-7200)
        ),
        ActivityEvent(
            id: UUID(), actorName: "Lola", actorAvatarURL: nil,
            kind: .rejectedBreak, modeName: "Study", modeColorHex: "#C5C3FF",
            timestamp: Date.now.addingTimeInterval(-7200)
        ),
    ]
}
