//
//  SplashView.swift
//  Lockty
//

import SwiftUI

struct SplashView: View {
    /// Llamado cuando la animación termina — AppEntryView navega cuando esto Y resolveAuthState estén listos.
    var onAnimationFinished: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()
            Text("Lockty")
        }
    }
}

#Preview {
    SplashView()
}
