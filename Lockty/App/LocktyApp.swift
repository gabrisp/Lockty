//
//  LocktyApp.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI
import FirebaseCore
import RevenueCat

@main
struct LocktyApp: App {
    @State private var router = AppRouter()

    init() {
        FirebaseApp.configure()
        Purchases.configure(withAPIKey: "test_ktzhLaELUjtxuPbCChwNtSxZyUR")
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
    }

    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environment(router)
        }
    }
}
