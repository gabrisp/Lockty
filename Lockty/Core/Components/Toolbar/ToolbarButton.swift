//
//  ToolbarButton.swift
//  Lockty
//

import SwiftUI

struct ToolbarButton: View {
    let icon: String
    var size: CGFloat
    var iconSize: CGFloat
    let action: () -> Void

    init(icon: String, size: CGFloat  = 32 , iconSize: CGFloat  = 16 , action: @escaping () -> Void = {print("no action")}) {
        self.icon = icon
        self.size = size
        self.iconSize = iconSize
        self.action = action
    }
    var body: some View {
        
           
            Button {
             action()
            } label: {
                Image(systemName: icon)
                   // .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(Color(.label))
                    .frame(width: size, height: size)
            }
        .buttonBorderShape(.circle)
        .buttonStyle(.glass)
        .transition(.blurReplace)
        .tappable()
    }
}
