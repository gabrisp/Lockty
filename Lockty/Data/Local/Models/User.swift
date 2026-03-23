//
//  User.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import Foundation



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
    var fromUserId: UUID        // tú
    var toUserId: UUID          // tu amigo
    var modeId: UUID
    var modeName: String
    var modeColorHex: String
    var modeIconName: String
    var permissionType: PermissionType
}



struct FriendAction: Identifiable, Hashable {
    let id: UUID
    var fromUser: User          // quien SOLICITA — siempre tú
    var toUserId: UUID          // quien ejecuta — tu amigo
    var modeId: UUID
    var modeName: String
    var action: FriendActionType
    var status: FriendActionStatus
    var createdAt: Date
    var requestedAt: Date
    var acceptedAt: Date?

    enum FriendActionType: String, Codable {
        case block              // tú pides que te bloqueen
        case requestBreak       // tú pides un break
        case stopBreak          // tú pides parar el break
    }

    enum FriendActionStatus: String, Codable {
        case pendingAcceptance  // esperando que el amigo acepte
        case accepted           // amigo aceptó, acción ejecutada
        case declined           // amigo rechazó
        case expired            // nadie respondió en tiempo
        case cancelled          // tú lo cancelaste
    }
}
