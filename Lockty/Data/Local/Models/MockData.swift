import Foundation

// MARK: - Mode
extension Mode {
    static let preview = Mode(
        id: UUID(), name: "Deep Work", iconName: "target",
        colorHex: "#FCE8E3", state: .inactive, createdAt: .now
    )
    static let previewActive = Mode(
        id: UUID(), name: "Deep Work", iconName: "target",
        colorHex: "#FCE8E3", state: .active, createdAt: .now
    )
    static let previewOnBreak = Mode(
        id: UUID(), name: "Deep Work", iconName: "target",
        colorHex: "#FCE8E3", state: .onBreak, createdAt: .now
    )
    static let previewList: [Mode] = [
        Mode(id: UUID(), name: "Deep Work", iconName: "target",
             colorHex: "#FCE8E3", state: .active, createdAt: .now),
        Mode(id: UUID(), name: "Study", iconName: "book.fill",
             colorHex: "#E3ECF8", state: .inactive, createdAt: .now),
        Mode(id: UUID(), name: "Gym", iconName: "figure.run",
             colorHex: "#E8F5E9", state: .inactive, createdAt: .now),
        Mode(id: UUID(), name: "Evening", iconName: "moon.fill",
             colorHex: "#F3E8FF", state: .inactive, createdAt: .now)
    ]
}

// MARK: - Rule
extension Rule {
    static let previewActivate = Rule(
        id: UUID(), modeId: UUID(), transition: .activate,
        conditionType: .nfc, conditionConfig: Data(),
        guardLogic: .allMustPass, onGuardFail: .requireConfirmation,
        isActive: true
    )
    static let previewBreak = Rule(
        id: UUID(), modeId: UUID(), transition: .startBreak,
        conditionType: .manual, conditionConfig: Data(),
        guardLogic: .allMustPass, onGuardFail: .doNothing,
        isActive: true
    )
    static let previewStop = Rule(
        id: UUID(), modeId: UUID(), transition: .stop,
        conditionType: .friend, conditionConfig: Data(),
        guardLogic: .allMustPass, onGuardFail: .requireConfirmation,
        isActive: true
    )
    static let previewList: [Rule] = [
        .previewActivate, .previewBreak, .previewStop
    ]
}

// MARK: - Session
extension Session {
    static let preview = Session(
        id: UUID(),
        modeId: UUID(),
        modeName: "Deep Work",
        modeColorHex: "#FCE8E3",
        startedAt: Date.now.addingTimeInterval(-9840),
        endedAt: nil,
        startTrigger: .nfc,
        endTrigger: nil,
        startRuleId: UUID(),
        endRuleId: nil,
        totalBreakTime: 480,
        blockedCount: 47
    )
    static let previewCompleted = Session(
        id: UUID(),
        modeId: UUID(),
        modeName: "Study",
        modeColorHex: "#E3ECF8",
        startedAt: Date.now.addingTimeInterval(-6300),
        endedAt: Date.now.addingTimeInterval(-600),
        startTrigger: .manual,
        endTrigger: .manual,
        startRuleId: nil,
        endRuleId: nil,
        totalBreakTime: 300,
        blockedCount: 12
    )
}

// MARK: - SessionBreak
extension SessionBreak {
    static let preview = SessionBreak(
        id: UUID(),
        sessionId: UUID(),
        modeId: UUID(),
        startedAt: Date.now.addingTimeInterval(-300),
        endedAt: nil,
        startTrigger: .manual,
        endTrigger: nil,
        startRuleId: nil,
        endRuleId: nil,
        maxDuration: 900,
        wasForced: false
    )
}

// MARK: - AppBlock
extension AppBlock {
    static let preview = AppBlock(
        id: UUID(),
        sessionId: UUID(),
        modeId: UUID(),
        appBundleId: "com.instagram.ios",
        appName: "Instagram",
        timestamp: Date.now.addingTimeInterval(-1800),
        duringBreak: false
    )
    static let previewList: [AppBlock] = [
        AppBlock(
            id: UUID(), sessionId: UUID(), modeId: UUID(),
            appBundleId: "com.instagram.ios", appName: "Instagram",
            timestamp: .now, duringBreak: false
        ),
        AppBlock(
            id: UUID(), sessionId: UUID(), modeId: UUID(),
            appBundleId: "com.zhiliaoapp.musically", appName: "TikTok",
            timestamp: .now, duringBreak: false
        ),
        AppBlock(
            id: UUID(), sessionId: UUID(), modeId: UUID(),
            appBundleId: "com.atebits.Tweetie2", appName: "X",
            timestamp: .now, duringBreak: true
        )
    ]
}

// MARK: - DailyStats
extension DailyStats {
    static let preview = DailyStats(
        date: .now,
        focusTime: 9840,
        sessions: 2,
        breaks: 3,
        blocked: 47,
        topApps: [
            AppDailyAggregate(
                id: UUID(), date: .now, modeId: UUID(),
                appBundleId: "com.instagram.ios",
                appName: "Instagram", blocked: 23
            ),
            AppDailyAggregate(
                id: UUID(), date: .now, modeId: UUID(),
                appBundleId: "com.zhiliaoapp.musically",
                appName: "TikTok", blocked: 14
            ),
            AppDailyAggregate(
                id: UUID(), date: .now, modeId: UUID(),
                appBundleId: "com.atebits.Tweetie2",
                appName: "X", blocked: 10
            )
        ],
        vsDelta: 2040,
        streak: 12,
        bestStreak: 21,
        avgSessionDuration: 4920
    )
}

// MARK: - WeeklyStats
extension WeeklyStats {
    static let preview = WeeklyStats(
        weekStart: Date.now.addingTimeInterval(-604800),
        weekEnd: .now,
        totalFocusTime: 52440,
        sessions: 12,
        breaks: 18,
        blocked: 256,
        dailyBreakdown: [],
        vsLastWeek: 7200,
        streak: 12
    )
}

// MARK: - User
extension User {
    static let preview = User(
        id: UUID(),
        email: "gabriel@me.com",
        displayName: "Gabriel",
        username: "gabrisp",
        avatarURL: nil
    )
}

// MARK: - Friendship
extension Friendship {
    static let previewList: [Friendship] = [
        Friendship(
            id: UUID(), fromUserId: UUID(),
            toUser: User(
                id: UUID(), email: "jorge@me.com",
                displayName: "Jorge M.", username: "jorgemp"
            ),
            status: .accepted, createdAt: .now
        ),
        Friendship(
            id: UUID(), fromUserId: UUID(),
            toUser: User(
                id: UUID(), email: "carlos@me.com",
                displayName: "Carlos L.", username: "carloslf"
            ),
            status: .accepted, createdAt: .now
        ),
        Friendship(
            id: UUID(), fromUserId: UUID(),
            toUser: User(
                id: UUID(), email: "maria@me.com",
                displayName: "María R.", username: "mariaruiz"
            ),
            status: .pending, createdAt: .now
        )
    ]
}

// MARK: - FriendPermission
extension FriendPermission {
    static let previewList: [FriendPermission] = [
        FriendPermission(
            id: UUID(), fromUserId: UUID(), toUserId: UUID(),
            modeId: UUID(), modeName: "Deep Work",
            modeColorHex: "#FCE8E3", modeIconName: "target",
            permissionType: .preAuthorized
        ),
        FriendPermission(
            id: UUID(), fromUserId: UUID(), toUserId: UUID(),
            modeId: UUID(), modeName: "Study",
            modeColorHex: "#E3ECF8", modeIconName: "book.fill",
            permissionType: .onRequest
        )
    ]
}

// MARK: - FriendAction
extension FriendAction {
    static let previewList: [FriendAction] = [
        FriendAction(
            id: UUID(),
            fromUser: .preview,
            toUserId: UUID(),
            modeId: UUID(),
            modeName: "Deep Work",
            action: .block,
            status: .accepted,
            createdAt: Date.now.addingTimeInterval(-7200),
            requestedAt: Date.now.addingTimeInterval(-7200),
            acceptedAt: Date.now.addingTimeInterval(-7100)
        ),
        FriendAction(
            id: UUID(),
            fromUser: .preview,
            toUserId: UUID(),
            modeId: UUID(),
            modeName: "Study",
            action: .requestBreak,
            status: .pendingAcceptance,
            createdAt: Date.now.addingTimeInterval(-300),
            requestedAt: Date.now.addingTimeInterval(-300),
            acceptedAt: nil
        )
    ]
}
