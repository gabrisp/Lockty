//
//  IconPickerSheet.swift
//  Lockty
//

import SwiftUI

struct IconPickerSheet: View {
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

    private let cols = Array(repeating: GridItem(.flexible(), spacing: BaseTheme.Spacing.xs), count: 9)

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {
            // MARK: Iconos
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
                Text("Icono")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
                    .padding(.horizontal, BaseTheme.Spacing.lg)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: BaseTheme.Spacing.xs), count: 4), spacing: BaseTheme.Spacing.xs) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                vm.iconName = icon
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: BaseTheme.Radius.md)
                                        .fill(vm.iconName == icon ? Color(hex: vm.colorHex) : Color.cardBackground)
                                        .frame(width: 52, height: 52)
                                    Image(systemName: icon)
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundStyle(vm.iconName == icon
                                            ? Color(hex: vm.colorHex).contrastingLabel
                                            : Color(.label))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, BaseTheme.Spacing.lg)
                }
            }

            Divider()
                .padding(.horizontal, BaseTheme.Spacing.lg)

            // MARK: Colores
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
                Text("Color")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
                    .padding(.horizontal, BaseTheme.Spacing.lg)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: BaseTheme.Spacing.xs), count: 2), spacing: BaseTheme.Spacing.xs) {
                        ForEach(colors, id: \.1) { name, hex in
                            Button {
                                vm.colorHex = hex
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: BaseTheme.Radius.md)
                                        .fill(Color(hex: hex))
                                        .frame(width: 52, height: 52)
                                    if vm.colorHex == hex {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Color(hex: hex).isDark ? .white : .black)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, BaseTheme.Spacing.lg)
                }
            }
        }
        .padding(.vertical, BaseTheme.Spacing.md)
    }
}

