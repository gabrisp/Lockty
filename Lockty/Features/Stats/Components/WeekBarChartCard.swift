//
//  WeekBarChartCard.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

// MARK: - WeekBarChartCard

/// Tarjeta "This week vs last" construida sobre StatCard.
/// - `entries`: array de 7 elementos ordenados lunes→domingo.
/// - `highlightIndex`: índice del día resaltado (hoy). nil = ninguno.
/// - `insight`: texto AI opcional.

struct WeekBarEntry {
    let label: String       // "Mon", "Tue"…
    let current: CGFloat    // minutos esta semana (0 = sin datos / futuro)
    let previous: CGFloat   // minutos semana pasada
}

struct WeekBarChartCard: View {
    let pretitle: String
    let entries: [WeekBarEntry]
    var highlightIndex: Int? = nil
    var insight: String? = nil
    var isLoadingInsight: Bool = false

    private let maxBarHeight: CGFloat = BaseTheme.Spacing.xxl * 5   // 120 pt

    var body: some View {
        StatCard(
            pretitle: pretitle,
            insight: insight,
            isLoadingInsight: isLoadingInsight
        ) {
            chart
        }
    }

    // MARK: - Chart

    private var chart: some View {
        let maxVal = entries.map { max($0.current, $0.previous) }.max() ?? 1

        return HStack(alignment: .bottom, spacing: BaseTheme.Spacing.sm) {
            ForEach(Array(entries.enumerated()), id: \.offset) { i, entry in
                let isFuture = entry.current == 0
                let isHighlighted = highlightIndex == i
                VStack(spacing: BaseTheme.Spacing.xs) {
                    HStack(alignment: .bottom, spacing: 3) {
                        if entry.current > 0 {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.blue)
                                .frame(maxWidth: .infinity)
                                .frame(height: entry.current / maxVal * maxBarHeight)
                        }
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(.systemFill))
                            .frame(maxWidth: .infinity)
                            .frame(height: entry.previous / maxVal * maxBarHeight)
                    }
                    Text(entry.label)
                        .font(Typography.micro())
                        .foregroundStyle(isHighlighted ? Color.blue : Color(.label))
                }
                .opacity(isFuture ? 0.5 : 1)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: maxBarHeight + BaseTheme.Spacing.lg)
    }
}

// MARK: - Preview

#Preview {
    let entries: [WeekBarEntry] = [
        .init(label: "Mon", current: 53,  previous: 102),
        .init(label: "Tue", current: 117, previous: 86),
        .init(label: "Wed", current: 95,  previous: 55),
        .init(label: "Thu", current: 109, previous: 85),
        .init(label: "Fri", current: 59,  previous: 95),
        .init(label: "Sat", current: 0,   previous: 107),
        .init(label: "Sun", current: 0,   previous: 119),
    ]

    ScrollView {
        WeekBarChartCard(
            pretitle: "This week vs last",
            entries: entries,
            highlightIndex: 4,
            insight: "Tuesdays keep slipping — last 4 weeks in a row. Last Tuesday you had 3 meetings before noon. Worth protecting that time."
        )
        .padding(BaseTheme.Spacing.lg)
    }
    .background(Color.pageBackground)
}
