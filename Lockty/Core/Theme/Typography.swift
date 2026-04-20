//
//  Typography.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

enum Typography {
    
    // MARK: - Base — único sitio donde se define la font
    private static func base(size: CGFloat, weight: Font.Weight) -> Font {
        .system(size: size, weight: weight, design: .default)
        // .custom("HankenGrotesk-\(weight.name)", size: size)
    }
    
    // MARK: - Scale
    static func extraLargeTitle(weight: Font.Weight = .bold) -> Font { base(size: 48, weight: weight) }
    static func largeTitle(weight: Font.Weight = .bold) -> Font      { base(size: 34, weight: weight) }
    static func title(weight: Font.Weight = .bold) -> Font           { base(size: 18, weight: weight) }
    static func sectionTitle(weight: Font.Weight = .semibold) -> Font { base(size: 18, weight: weight) }
    static func body(weight: Font.Weight = .regular) -> Font         { base(size: 15, weight: weight) }
    static func caption(weight: Font.Weight = .regular) -> Font      { base(size: 12, weight: weight) }
    static func micro(weight: Font.Weight = .semibold) -> Font       { base(size: 10, weight: weight) }
}
