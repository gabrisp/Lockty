//
//  PremiumGate.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct PremiumGate<Content: View>: View {
    let feature: ProFeature
    let content: () -> Content

    @Environment(AppRouter.self) var router

    private var premium: PremiumManager { .shared }

    var body: some View {
        if premium.isUnlocked(feature) {
            content()
        } else {
            content()
                .disabled(true)
                .overlay(alignment: .topTrailing) {
                    ProLockBadge()
                        .padding(BaseTheme.Spacing.sm)
                }
                .tappable()
                .onTapGesture {
                    router.sheet.push(.premium(reason: feature))
                }
        }
    }
}

struct ProLockBadge: View {
    var body: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.white)
            .padding(5)
            .background(Color(.label))
            .clipShape(Circle())
    }
}
