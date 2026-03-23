//
//  Avatar.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct AvatarView: View {
    let name: String
    var image: Image? = nil
    var imageURL: URL? = nil
    var size: AvatarSize = .toolbar
    var action: (() -> Void)? = nil

    enum AvatarSize: Equatable {
        case toolbar
        case large
        case custom(CGFloat)

        var diameter: CGFloat {
            switch self {
            case .toolbar:        return 38
            case .large:          return 80
            case .custom(let d):  return d
            }
        }

        var fontSize: CGFloat { diameter * 0.4 }
    }

    var body: some View {
        Group {
            if let action {
                Button(action: action) { avatar }
                    .buttonStyle(NoFlashButtonStyle())
            } else {
                avatar
            }
        }
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color.avatarGradient(for: name))

            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } else if let url = imageURL {
                AsyncImage(url: url) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    initial
                }
                .clipShape(Circle())
            } else {
                initial
            }
        }
        .frame(width: size.diameter, height: size.diameter)
        .padding(size == .toolbar ? BaseTheme.Spacing.xs : BaseTheme.Spacing.sm)
        .locktyGlass(.regular.interactive(),
            in: .circle
        )
    }

    private var initial: some View {
        Text(name.prefix(1).uppercased())
            .font(.system(size: size.fontSize, weight: .semibold))
            .foregroundStyle(.white)
    }
}

#Preview {
    VStack(spacing: BaseTheme.Spacing.xl) {
        AvatarView(name: "Gabriel", size: .toolbar)
        AvatarView(name: "Gabriel", image: Image("pfp"), size: .toolbar) {
            print("tapped")
        }
        AvatarView(name: "Gabriel", image: Image("pfp"), size: .large)
    }
    .padding()
    .background(Color.pageBackground)
}
