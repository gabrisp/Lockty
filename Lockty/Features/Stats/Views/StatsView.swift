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

    private let weekEntries: [WeekBarEntry] = [
        .init(label: "Mon", current: 53,  previous: 102),
        .init(label: "Tue", current: 117, previous: 86),
        .init(label: "Wed", current: 95,  previous: 55),
        .init(label: "Thu", current: 109, previous: 85),
        .init(label: "Fri", current: 59,  previous: 95),
        .init(label: "Sat", current: 0,   previous: 107),
        .init(label: "Sun", current: 0,   previous: 119),
    ]

    private let resistedApps: [ResistedApp] = [
        .init(name: "Instagram", icon: "camera",     count: 23),
        .init(name: "TikTok",    icon: "music.note", count: 17),
        .init(name: "X",         icon: "xmark",      count: 10),
    ]

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: BaseTheme.Spacing.lg) {

                // MARK: Date picker — sin padding lateral para llegar a bordes
                WeekDatePicker(days: weekDays, selectedDate: $selectedDate)
                    .padding(.horizontal, BaseTheme.Spacing.lg)

                // MARK: Focus today
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

                // MARK: Sessions / Breaks / Blocks
                HStack(spacing: BaseTheme.Spacing.lg) {
                    StatCard(pretitle: "Sessions", value: "\(stats.sessions)")
                    StatCard(pretitle: "Breaks",   value: "\(stats.breaks)")
                    StatCard(pretitle: "Blocks",   value: "\(stats.blocked)")
                }
                .padding(.horizontal, BaseTheme.Spacing.lg)

                // MARK: AI prediction
                StatCard(pretitle: "Tomorrow looks good", badge: { AIBadge() }) {
                    (Text("Based on your Saturdays, you usually focus ")
                    + Text("1h 20m").foregroundStyle(.green)
                    + Text(" in the morning. Your streak is active and you're well-rested — conditions are right for a strong session. Set a mode before 10am."))
                        .font(Typography.caption(weight: .medium))
                        .foregroundStyle(Color(.label))
                }
                .padding(.horizontal, BaseTheme.Spacing.lg)

                // MARK: Timeline
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

                // MARK: Week chart
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

                // MARK: Most resisted
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
            .padding(.top, BaseTheme.Spacing.md)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Helpers

    /// Índice del día actual en la semana (0 = lunes, 6 = domingo). nil si no aplica.
    private var currentWeekdayIndex: Int? {
        let weekday = Calendar.current.component(.weekday, from: .now)
        // weekday: 1=Sun, 2=Mon…7=Sat → convertir a 0=Mon…6=Sun
        let idx = (weekday + 5) % 7
        return idx < weekEntries.count ? idx : nil
    }

    // MARK: - Timeline sessions

    private var timelineSessions: [[TimelineEvent]] {
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

#Preview {
    StatsView()
        .background(Color.pageBackground)
}
