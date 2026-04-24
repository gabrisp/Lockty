//
//  TimelineCard.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

// MARK: - TimelineEvent

struct TimelineEvent: Identifiable {
    let id = UUID()
    let time: String
    let title: String
    let subtitle: String
    let dotColor: Color
}

// MARK: - TimelineCard

/// Card "How your day went".
/// - `sessions`: array of session groups; each group renders as its own inner white card.
/// - Each inner card clips at `maxSessionHeight` and shows a bottom fade when content overflows.
/// - The outer gray card has no forced height — it grows to fit all inner cards.

struct TimelineCard: View {
    let pretitle: String
    let badge: String
    let sessions: [[TimelineEvent]]
    var insight: String? = nil
    var isLoadingInsight: Bool = false

    private let dotSize: CGFloat = 13
    private let connectorWidth: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
            // Header
            HStack {
                Text(pretitle)
                    .font(Typography.caption())
                    .foregroundStyle(Color(.secondaryLabel))
                Spacer()
                Text(badge)
                    .font(Typography.caption())
                    .foregroundStyle(Color(.secondaryLabel))
            }

                    // One inner white card per session
            ForEach(Array(sessions.enumerated()), id: \.offset) { _, session in
                sessionCard(events: session)
            }

            // AI insight sub-card
            if isLoadingInsight {
                insightRow(text: "Placeholder insight text for sizing")
                    .redacted(reason: .placeholder)
            } else if let insight {
                insightRow(text: insight)
            }
        }
        .padding(BaseTheme.Spacing.lg)
        .background(Color.cardBackground)
        .locktyRadius(BaseTheme.Radius.card)
    }

    // MARK: - Inner session card

    private func sessionCard(events: [TimelineEvent]) -> some View {
        eventList(events: events)
            .padding(BaseTheme.Spacing.md)
            .background(Color.innerBackground)
            .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.lg))
    }

    // MARK: - Event list

    private func eventList(events: [TimelineEvent]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(events.enumerated()), id: \.offset) { i, event in
                eventRow(event: event, isLast: i == events.count - 1)
            }
        }
    }

    @ViewBuilder
    private func eventRow(event: TimelineEvent, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: BaseTheme.Spacing.sm) {
            VStack(spacing: 0) {
                Circle()
                    .fill(event.dotColor)
                    .frame(width: dotSize, height: dotSize)

                if !isLast {
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(width: connectorWidth)
                        .frame(minHeight: 32)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(event.time)
                    .font(Typography.caption(weight: .semibold))
                    .foregroundStyle(Color(.secondaryLabel))

                Text(event.title)
                    .font(Typography.caption(weight: .semibold))
                    .foregroundStyle(Color(.label))

                Text(event.subtitle)
                    .font(Typography.micro())
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .padding(.bottom, isLast ? 0 : BaseTheme.Spacing.sm)
        }
    }

    // MARK: - Insight row

    @ViewBuilder
    private func insightRow(text: String) -> some View {
        HStack(alignment: .top, spacing: BaseTheme.Spacing.sm) {
            Text(text)
                .font(Typography.caption(weight: .medium))
                .foregroundStyle(Color(.label))
                .frame(maxWidth: .infinity, alignment: .leading)
            AIBadge()
        }
        .padding(BaseTheme.Spacing.md)
        .background(Color.innerBackground)
        .locktyRadius(BaseTheme.Radius.md)
    }
}

// MARK: - Preview

#Preview {
    let morning: [TimelineEvent] = [
        .init(time: "9:00",          title: "Study Started",  subtitle: "0 distractions", dotColor: Color(.systemGray3)),
        .init(time: "10:00 - 11:00", title: "Peak of Focus",  subtitle: "0 distractions", dotColor: .green),
        .init(time: "11:00 - 11:15", title: "Break",          subtitle: "Manual Init",    dotColor: .yellow),
        .init(time: "12:00",         title: "Session Ended",  subtitle: "Manual",         dotColor: Color(.systemGray3)),
    ]
    let evening: [TimelineEvent] = [
        .init(time: "16:00",         title: "Gym Started",    subtitle: "0 distractions", dotColor: Color(.systemGray3)),
        .init(time: "18:00 - 19:00", title: "Peak of Focus",  subtitle: "0 distractions", dotColor: .green),
        .init(time: "19:00 - 19:12", title: "Break",          subtitle: "Manual Init",    dotColor: .yellow),
        .init(time: "21:00",         title: "Session Ended",  subtitle: "NFC",            dotColor: Color(.systemGray3)),
    ]

    ScrollView {
        TimelineCard(
            pretitle: "How your day went",
            badge: "By hours, by modes.",
            sessions: [morning, evening],
            insight: "Your peak is consistently 10–11am — 3 Fridays in a row. Consider starting earlier to catch more of that window."
        )
        .padding(BaseTheme.Spacing.lg)
    }
    .background(Color.pageBackground)
}
