//
//  ModesView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct ModesView: View {
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: BaseTheme.Spacing.md) {
                ForEach(0..<30) { _ in
                    RoundedRectangle(cornerRadius: BaseTheme.Radius.card)
                        .fill(Color(.systemGray5))
                        .frame(height: 120)
                }
            }
            .padding(.horizontal, BaseTheme.Spacing.lg)
            .padding(.vertical, BaseTheme.Spacing.md)
        }
        .scrollIndicators(.hidden)
    }
}
