//
//  IconColorPickerSheet.swift
//  Lockty
//

import SwiftUI

struct IconColorPickerSheet: View {
    @Bindable var vm: CreateModeViewModel

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

    // Organizado por columnas: cada grupo de 3 = [intenso, normal, pastel] del mismo tono
    private let colors: [String] = [
        // Rojo
        "#CC0000", "#FF3B30", "#FFB3AE",
        // Rojo-Rosa
        "#B30050", "#FF2D78", "#FFB3D1",
        // Rosa
        "#8B0057", "#FF375F", "#FFAFD1",
        // Fucsia
        "#990099", "#FF44CC", "#FFB3F0",
        // Naranja-Rojo
        "#CC3300", "#FF6B35", "#FFCBB3",
        // Naranja
        "#CC5500", "#FF9500", "#FFD9A3",
        // Ámbar
        "#CC7700", "#FFBF00", "#FFE8A3",
        // Amarillo
        "#997700", "#FFD60A", "#FFF3A3",
        // Lima
        "#557700", "#AACC00", "#DDFFAA",
        // Verde claro
        "#337700", "#34C759", "#B3F5C8",
        // Verde
        "#006600", "#00A86B", "#A3FFCC",
        // Verde azulado
        "#006655", "#00C7BE", "#A3F0EE",
        // Cian
        "#005577", "#32ADE6", "#A3DAFF",
        // Azul cielo
        "#003399", "#0A84FF", "#A3C8FF",
        // Azul
        "#001F99", "#3352FF", "#A3B3FF",
        // Índigo
        "#220099", "#5E5CE6", "#C3B3FF",
        // Violeta
        "#550099", "#9B59B6", "#DDB3FF",
        // Lavanda
        "#770099", "#BF5AF2", "#E8B3FF",
        // Magenta
        "#990066", "#FF2FD2", "#FFB3F5",
        // Gris cálido
        "#3A3330", "#8E8E93", "#E5E1DF",
        // Gris frío
        "#2C2C2E", "#636366", "#E5E5EA",
    ]

    private let iconRows = Array(repeating: GridItem(.fixed(56), spacing: BaseTheme.Spacing.xs), count: 5)
    private let colorRows = Array(repeating: GridItem(.fixed(56), spacing: BaseTheme.Spacing.xs), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {

            // MARK: Icono
            VStack(alignment: .center, spacing: BaseTheme.Spacing.md) {
                Text("Icono")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
                    .padding(.horizontal, BaseTheme.Spacing.lg)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: iconRows, spacing: BaseTheme.Spacing.xs) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                vm.iconName = icon
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: BaseTheme.Radius.md)
                                        .fill(vm.iconName == icon ? Color(hex: vm.colorHex) : Color.cardBackground)
                                        .frame(width: 56, height: 56)
                                    Image(systemName: icon)
                                        .font(.system(size: 22, weight: .medium))
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

            // MARK: Color
            VStack(alignment: .center, spacing: BaseTheme.Spacing.md) {
                Text("Color")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
                    .padding(.horizontal, BaseTheme.Spacing.lg)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: colorRows, spacing: BaseTheme.Spacing.xs) {
                        ForEach(colors, id: \.self) { hex in
                            Button {
                                vm.colorHex = hex
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: BaseTheme.Radius.md)
                                        .fill(Color(hex: hex))
                                        .frame(width: 56, height: 56)
                                    if vm.colorHex == hex {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Color(hex: hex).contrastingLabel)
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
        .padding(.vertical, BaseTheme.Spacing.xl)
        .padding(.top, BaseTheme.Spacing.xxl)
        .navigationBarBackButtonHidden(true)
    }
}
