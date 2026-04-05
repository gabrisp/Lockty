//
//  SocialViewModel.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

@MainActor
@Observable
final class SocialViewModel {

    // MARK: - State

    var friends: [Friend] = []
    var pendingRequests: [SocialRequest] = []
    var pendingActions: [SocialRequest] = []
    var recentActivity: [ActivityEvent] = []
    var aiInsight: String? = nil
    var isLoadingInsight: Bool = false

    var requestCount: Int { pendingRequests.count }
    var actionCount: Int { pendingActions.count }

    // MARK: - Init

    init() {
        loadDummyData()
    }

    // MARK: - Intents

    func acceptRequest(_ request: SocialRequest) {
        pendingRequests.removeAll { $0.id == request.id }
    }

    func declineRequest(_ request: SocialRequest) {
        pendingRequests.removeAll { $0.id == request.id }
    }

    func acceptAction(_ action: SocialRequest) {
        pendingActions.removeAll { $0.id == action.id }
    }

    func declineAction(_ action: SocialRequest) {
        pendingActions.removeAll { $0.id == action.id }
    }

    // MARK: - Private

    private func loadDummyData() {
        friends = Friend.preview
        recentActivity = ActivityEvent.preview
        aiInsight = "Tuesdays keep slipping — last 4 weeks in a row. Last Tuesday you had 3 meetings before noon. Worth protecting that time."
        pendingRequests = [
            SocialRequest(id: UUID(), fromUser: "Maria", type: .friendRequest),
            SocialRequest(id: UUID(), fromUser: "Carlos", type: .friendRequest),
        ]
        pendingActions = [
            SocialRequest(id: UUID(), fromUser: "Lola", type: .action),
            SocialRequest(id: UUID(), fromUser: "Pedro", type: .action),
        ]
    }
}
