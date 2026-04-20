//
//  ColorPickerSheet.swift
//  Lockty
//

import SwiftUI

struct ColorPickerSheet: View {
    @Bindable var vm: CreateModeViewModel
    @Environment(\.dismiss) private var dismiss

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

    private let columns = [GridItem(.adaptive(minimum: 72), spacing: BaseTheme.Spacing.sm)]

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.md) {
            Text("Color")
                .font(Typography.title())
                .foregroundStyle(Color(.label))
                .padding(.horizontal, BaseTheme.Spacing.lg)

            LazyVGrid(columns: columns, spacing: BaseTheme.Spacing.sm) {
                ForEach(colors, id: \.1) { name, hex in
                    Button {
                        vm.colorHex = hex
                        dismiss()
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
        .padding(.vertical, BaseTheme.Spacing.lg)
    }
}

