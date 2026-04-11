//
//  SheetWrapper.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//
import SwiftUI

struct SheetWrapper: View {
    @Environment(AppRouter.self) var router
    let currentSheet: Sheet
    let content: () -> AnyView

    init(sheet: Sheet, content: @escaping () -> AnyView) {
        self.currentSheet = sheet
        self.content = content
    }

    var body: some View {
        @Bindable var router = router

        ZStack {
            content()
        }
        .presentationBackground(Color.pageBackground)
        .presentationCornerRadius(BaseTheme.Radius.xl)
        .sheet(item: Binding(
            get: { router.sheet.nextSheet(after: currentSheet) },
            set: { if $0 == nil { router.sheet.pop() } }
        )) { next in
            SheetWrapper(sheet: next) {
                SheetFactory.view(for: next, user: router.currentUser)
            }
            .environment(router)
        }
    }
}
