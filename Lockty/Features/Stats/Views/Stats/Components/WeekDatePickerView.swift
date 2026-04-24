//
//  WeekDatePicker.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

// MARK: - WeekDatePicker

/// Selector de días dinámico. El primer elemento de `days` queda seleccionado por defecto.
/// Cada item muestra `label` (p.ej. "MAR") y `number` (p.ej. 17).
/// El día seleccionado muestra fondo `secondarySystemGroupedBackground`; los demás, 50% de opacidad.
///
/// Uso para semana:
///   WeekDatePicker(days: Calendar.current.currentWeekDays(), selectedDate: $date)
///
/// Configurable para mes/año pasando distintos arrays de `PickerDay`.

struct PickerDay: Identifiable {
    let id = UUID()
    let label: String   // "MAR", "ABR", "2024"…
    let number: String  // "17", "1", …
    let date: Date
}

struct WeekDatePicker: View {
    let days: [PickerDay]
    @Binding var selectedDate: Date

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BaseTheme.Spacing.xs) {
                ForEach(days) { day in
                    let isSelected = Calendar.current.isDate(day.date, inSameDayAs: selectedDate)
                    Button {
                        selectedDate = day.date
                    } label: {
                        VStack(spacing: BaseTheme.Spacing.xs) {
                            Text(day.label)
                                .font(Typography.micro())
                            Text(day.number)
                                .font(Typography.body(weight: .semibold))
                        }
                        .frame(width: 48)
                        .padding(.vertical, BaseTheme.Spacing.sm)
                        .background(
                            isSelected
                                ? Color.innerBackground
                                : Color.clear
                        )
                        .locktyRadius(BaseTheme.Radius.md)
                        .opacity(isSelected ? 1 : 0.5)
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: selectedDate)
                }
            }
            .padding(.bottom, BaseTheme.Spacing.xs)
        }
    }
}

// MARK: - Calendar helpers

extension Calendar {
    /// Devuelve los 7 días de la semana que contiene `date` (lunes → domingo).
    func weekDays(containing date: Date = .now, locale: Locale = .current) -> [PickerDay] {
        let formatter = DateFormatter()
        formatter.locale = locale

        // Inicio de semana (lunes)
        var comps = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        comps.weekday = 2 // lunes
        guard let monday = self.date(from: comps) else { return [] }

        return (0..<7).compactMap { offset in
            guard let day = self.date(byAdding: .day, value: offset, to: monday) else { return nil }
            formatter.dateFormat = "MMM"
            let label = formatter.string(from: day).uppercased()
            formatter.dateFormat = "d"
            let number = formatter.string(from: day)
            return PickerDay(label: label, number: number, date: day)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selected: Date = .now
    let days = Calendar.current.weekDays()

    return WeekDatePicker(days: days, selectedDate: $selected)
        .padding(BaseTheme.Spacing.lg)
        .background(Color.pageBackground)
}
