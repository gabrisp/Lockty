//
//  LocktyApp.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

@main
struct LocktyApp: App {
    @State private var router = AppRouter()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
        }
    }
}
