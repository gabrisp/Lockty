//
//  ScreenTimePickerSheetRoute.swift
//  Lockty
//

import Foundation

/// Centralizes the nested sheets used by the Screen Time flow.
enum ScreenTimePickerSheetRoute: String, Identifiable {
    case appGroupBrowser
    case appGroupEditor

    var id: String { rawValue }
}
