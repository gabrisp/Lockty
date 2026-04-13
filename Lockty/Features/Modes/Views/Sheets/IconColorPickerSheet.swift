//
//  IconColorPickerSheet.swift
//  Lockty
//

import SwiftUI

struct IconColorPickerSheet: View {
    @Bindable var vm: CreateModeViewModel
    @Environment(\.dismiss) private var dismiss

    private let icons: [String] = [
        "target", "brain.head.profile", "book.fill", "pencil", "laptopcomputer",
        "dumbbell.fill", "figure.run", "heart.fill", "moon.fill", "sun.max.fill",
        "leaf.fill", "flame.fill", "bolt.fill", "music.note", "headphones",
        "gamecontroller.fill", "cart.fill", "fork.knife", "cup.and.saucer.fill", "bed.double.fill",
        "airplane", "car.fill", "bicycle", "trophy.fill", "star.fill",
        "lock.fill", "shield.fill", "eye.slash.fill", "bell.slash.fill", "nosign",
        "timer", "stopwatch.fill", "chart.bar.fill", "waveform", "person.2.fill",
        "house.fill", "building.2.fill", "graduationcap.fill", "briefcase.fill", "stethoscope"
    ]

    private let colors: [(String, String)] = [
        ("Rosa",       "#FCE8E3"),
        ("Melocotón",  "#FFE5CC"),
        ("Amarillo",   "#FFF3CC"),
        ("Lima",       "#E8F5E9"),
        ("Menta",      "#D4F1E4"),
        ("Cielo",      "#D6EEFF"),
        ("Lavanda",    "#E8E0FF"),
        ("Lila",       "#F3D6FF"),
        ("Gris claro", "#F2F2F7"),
        ("Pizarra",    "#E5E7EB"),
        ("Carbón",     "#2C2C2E"),
        ("Negro",      "#1C1C1E"),
    ]

    private let iconColumns = [GridItem(.adaptive(minimum: 60), spacing: BaseTheme.Spacing.sm)]
    private let colorColumns = [GridItem(.adaptive(minimum: 72), spacing: BaseTheme.Spacing.sm)]

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {

            // MARK: Icono
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
                Text("Icono")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
                    .padding(.horizontal, BaseTheme.Spacing.lg)

                LazyVGrid(columns: iconColumns, spacing: BaseTheme.Spacing.sm) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            vm.iconName = icon
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: BaseTheme.Radius.lg)
                                    .fill(vm.iconName == icon ? Color(hex: vm.colorHex) : Color.cardBackground)
                                    .frame(width: 60, height: 60)
                                Image(systemName: icon)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(vm.iconName == icon
                                        ? (Color(hex: vm.colorHex).isDark ? .white : .black)
                                        : Color(.label))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, BaseTheme.Spacing.lg)
            }

            Divider()
                .padding(.horizontal, BaseTheme.Spacing.lg)

            // MARK: Color
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
                Text("Color")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
                    .padding(.horizontal, BaseTheme.Spacing.lg)

                LazyVGrid(columns: colorColumns, spacing: BaseTheme.Spacing.sm) {
                    ForEach(colors, id: \.1) { name, hex in
                        Button {
                            vm.colorHex = hex
                        } label: {
                            VStack(spacing: BaseTheme.Spacing.xs) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: BaseTheme.Radius.lg)
                                        .fill(Color(hex: hex))
                                        .frame(height: 56)
                                    if vm.colorHex == hex {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(Color(hex: hex).isDark ? .white : .black)
                                    }
                                }
                                Text(name)
                                    .font(Typography.caption())
                                    .foregroundStyle(Color(.secondaryLabel))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, BaseTheme.Spacing.lg)
            }
        }
        .padding(.vertical, BaseTheme.Spacing.lg)
    }
}

private extension Color {
    var isDark: Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        return (0.299 * r + 0.587 * g + 0.114 * b) < 0.5
    }
}
