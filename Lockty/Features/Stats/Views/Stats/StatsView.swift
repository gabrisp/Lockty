//
//  StatsView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct StatsView: View {
    @Environment(AppRouter.self) private var router
    let stats: DailyStats = .preview

    @State private var selectedDate: Date = .now

    private var weekDays: [PickerDay] {
        Calendar.current.weekDays(containing: selectedDate)
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: BaseTheme.Spacing.lg) {
                datePicker
                focusCard
                usageHighlights
                quickStats
                aiPrediction
                timelineCard
                weekChartCard
                mostResistedCard
            }
            .padding(.top, 44 + BaseTheme.Spacing.md)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Sections

private extension StatsView {
    var datePicker: some View {
        WeekDatePicker(days: weekDays, selectedDate: $selectedDate)
            .padding(.horizontal, BaseTheme.Spacing.lg)
    }

    var focusCard: some View {
        Button { router.openStatFocusDetail(date: selectedDate) } label: {
            StatCard(
                pretitle: "Focused today",
                badge: {
                    Text("↑ 34m vs yesterday")
                        .font(Typography.caption(weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, BaseTheme.Spacing.sm)
                        .padding(.vertical, BaseTheme.Spacing.xs)
                        .background(Color.green)
                        .shadow(color: .green.opacity(0.6), radius: BaseTheme.Spacing.md)
                        .clipShape(Capsule())
                },
                content: {
                    Text("2h 44m")
                        .font(Typography.largeTitle(weight: .bold))
                        .foregroundStyle(Color(.label))
                },
                insight: "You resisted Instagram twice as well as yesterday. This is your longest Friday session ever."
            )
        }
        .buttonStyle(NoFlashButtonStyle())
        .padding(.horizontal, BaseTheme.Spacing.lg)
    }

    var usageHighlights: some View {
        UsageHighlightsSection(
            weekUsage: "19h 24m",
            weeklyPickups: 142,
            apps: mostUsedApps
        )
        .padding(.horizontal, BaseTheme.Spacing.lg)
    }

    var quickStats: some View {
        HStack(spacing: BaseTheme.Spacing.lg) {
            StatCard(pretitle: "Sessions", value: "\(stats.sessions)")
            StatCard(pretitle: "Breaks",   value: "\(stats.breaks)")
            StatCard(pretitle: "Blocks",   value: "\(stats.blocked)")
        }
        .padding(.horizontal, BaseTheme.Spacing.lg)
    }

    var aiPrediction: some View {
        StatCard(pretitle: "Tomorrow looks good", badge: { AIBadge() }) {
            Text("Based on your Saturdays, you usually focus \(Text("1h 20m").foregroundStyle(.green)) in the morning. Your streak is active and you're well-rested — conditions are right for a strong session. Set a mode before 10am.")
                .font(Typography.caption(weight: .medium))
                .foregroundStyle(Color(.label))
        }
        .padding(.horizontal, BaseTheme.Spacing.lg)
    }

    var timelineCard: some View {
        Button { router.openStatTimeline(date: selectedDate) } label: {
            TimelineCard(
                pretitle: "How your day went",
                badge: "By hours, by modes.",
                sessions: timelineSessions,
                insight: "Your peak is consistently 10–11am — 3 Fridays in a row. Consider starting earlier to catch more of that window."
            )
        }
        .buttonStyle(NoFlashButtonStyle())
        .padding(.horizontal, BaseTheme.Spacing.lg)
    }

    var weekChartCard: some View {
        Button { router.openStatWeekChart() } label: {
            WeekBarChartCard(
                pretitle: "This week vs last",
                entries: weekEntries,
                highlightIndex: currentWeekdayIndex,
                insight: "Tuesdays keep slipping — last 4 weeks in a row. Last Tuesday you had 3 meetings before noon. Worth protecting that time."
            )
        }
        .buttonStyle(NoFlashButtonStyle())
        .padding(.horizontal, BaseTheme.Spacing.lg)
    }

    var mostResistedCard: some View {
        Button { router.openStatMostResisted() } label: {
            MostResistedCard(
                pretitle: "Most Resisted",
                apps: resistedApps,
                insight: "Instagram attempts drop 60% on days you start before 9am. Today you started at 9:30 — tomorrow try 9:00"
            )
        }
        .buttonStyle(NoFlashButtonStyle())
        .padding(.horizontal, BaseTheme.Spacing.lg)
    }
}

// MARK: - Helpers

private extension StatsView {
    var currentWeekdayIndex: Int? {
        let weekday = Calendar.current.component(.weekday, from: .now)
        let idx = (weekday + 5) % 7
        return idx < weekEntries.count ? idx : nil
    }

    var timelineSessions: [[TimelineEvent]] {
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
        return [morning, evening]
    }
}

// MARK: - Static data

private extension StatsView {
    var weekEntries: [WeekBarEntry] { [
        .init(label: "Mon", current: 53,  previous: 102),
        .init(label: "Tue", current: 117, previous: 86),
        .init(label: "Wed", current: 95,  previous: 55),
        .init(label: "Thu", current: 109, previous: 85),
        .init(label: "Fri", current: 59,  previous: 95),
        .init(label: "Sat", current: 0,   previous: 107),
        .init(label: "Sun", current: 0,   previous: 119),
    ]}

    var resistedApps: [ResistedApp] { [
        .init(name: "Instagram", icon: "camera",     count: 23),
        .init(name: "TikTok",    icon: "music.note", count: 17),
        .init(name: "X",         icon: "xmark",      count: 10),
    ]}

    var mostUsedApps: [UsageHighlightApp] { [
        .init(name: "Instagram", tint: Color(hex: "#FCE8E3"), time: "5h 12m"),
        .init(name: "WhatsApp",  tint: Color(hex: "#D4F1E4"), time: "3h 48m"),
        .init(name: "Safari",    tint: Color(hex: "#D6EEFF"), time: "2h 26m"),
        .init(name: "YouTube",   tint: Color(hex: "#FFE5CC"), time: "2h 03m"),
    ]}
}

// MARK: - Preview

#Preview {
    StatsView()
        .background(Color.pageBackground)
}
