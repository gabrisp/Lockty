//
//  User.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import Foundation

// MARK: - Local user (persisted via CoreData)

struct LocalUser: Identifiable, Hashable, Codable {
    let id: UUID
    var displayName: String
    var createdAt: Date
    var firebaseUserId: String
}

// MARK: - Remote/social models (sin persistencia local aún)

struct User: Identifiable, Hashable {
    let id: UUID
    var email: String
    var displayName: String
    var username: String
    var avatarURL: URL?
}

struct Friendship: Identifiable, Hashable {
    let id: UUID
    var fromUserId: UUID
    var toUser: User
    var status: FriendshipStatus
    var createdAt: Date

    enum FriendshipStatus: String, Codable {
        case pending
        case accepted
        case declined
    }
}

struct FriendPermission: Identifiable, Hashable {
    let id: UUID
    var fromUserId: UUID
    var toUserId: UUID
    var modeId: UUID
    var modeName: String
    var modeColorHex: String
    var modeIconName: String
    var permissionType: PermissionType
}

struct FriendAction: Identifiable, Hashable {
    let id: UUID
    var fromUser: User
    var toUserId: UUID
    var modeId: UUID
    var modeName: String
    var action: FriendActionType
    var status: FriendActionStatus
    var createdAt: Date
    var requestedAt: Date
    var acceptedAt: Date?

    enum FriendActionType: String, Codable {
        case block
        case requestBreak
        case stopBreak
    }

    enum FriendActionStatus: String, Codable {
        case pendingAcceptance
        case accepted
        case declined
        case expired
        case cancelled
    }
}
