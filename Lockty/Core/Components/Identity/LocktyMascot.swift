//
//  LocktyMascot.swift
//  Lockty
//

import SwiftUI

// MARK: - Static mascot

struct LocktyMascot: View {
    var size: CGFloat = 200
    var color: Color = Color(.systemGray4)
    var lookOffset: CGFloat = 0
    var faceOpacity: CGFloat = 1
    var bodyOpacity: CGFloat = 1
    var bodyScale: CGFloat = 1
    var shackleOffsetY: CGFloat = 0
    /// Radio del círculo blanco animable. Natural = 168 (centrado en el body).
    var faceRadius: CGFloat = 168

    private var s: CGFloat { size / 400 }
    private var totalHeight: CGFloat { 592 * s }

    // Medidas base (en pts base 400)
    // Body: x=0, y=192, w=400, h=400, r=56
    // Shackle outer: x=54, y=0, w=291, h=345, r=89  (solo parte visible = h visible antes del body)
    // Shackle inner (hueco): x=96, y=24, w=207, h=255, r=65
    // Face circle: centrado en body → centerX=200, centerY=392, r=168

    var body: some View {
        ZStack {
            // ── Círculo blanco — animable desde grande a natural
            let faceCenterY = 392 * s  // centro absoluto en el frame
            Circle()
                .fill(Color.white)
                .frame(width: faceRadius * 2 * s, height: faceRadius * 2 * s)
                .offset(y: faceCenterY - totalHeight / 2)

            // ── Body + Shackle (outline) sobre el círculo
            Canvas { ctx, sz in
                // ── Body
                let bodyRect = CGRect(x: 0, y: 192 * s, width: sz.width, height: sz.width)
                ctx.fill(Path(roundedRect: bodyRect, cornerRadius: 56 * s), with: .color(color))

                // ── Círculo blanco recortado dentro del body (por si faceRadius < natural)
                // No hace falta — el Circle() de SwiftUI ya lo pinta encima.

                // ── Shackle outline: outer - inner = anillo
                // Solo pintamos la parte visible sobre el body (clipeamos a y < 192*s)
                ctx.drawLayer { inner in
                    var clip = Path()
                    clip.addRect(CGRect(x: 0, y: shackleOffsetY * s, width: sz.width, height: (192 - shackleOffsetY) * s))
                    inner.clip(to: clip)

                    // Outer shackle
                    let outerRect = CGRect(x: 54 * s, y: shackleOffsetY * s, width: 291 * s, height: 345 * s)
                    let outerPath = Path(roundedRect: outerRect, cornerRadius: 89 * s)

                    // Inner hole (blanco)
                    let innerRect = CGRect(x: 96 * s, y: (24 + shackleOffsetY) * s, width: 207 * s, height: 255 * s)
                    let innerPath = Path(roundedRect: innerRect, cornerRadius: 65 * s)

                    // Dibujamos outer en color, luego inner en blanco (knock-out)
                    inner.fill(outerPath, with: .color(color))
                    inner.fill(innerPath, with: .color(.white))
                }
            }
            .frame(width: size, height: totalHeight)
            .scaleEffect(bodyScale)
            .opacity(bodyOpacity)

            // ── Cara (ojos + sonrisa)
            Canvas { ctx, sz in
                let eyeSize = 46 * s
                let eyeY    = 345 * s
                let shift   = lookOffset * 20 * s

                let leftEye  = Path(ellipseIn: CGRect(x: 96  * s + shift, y: eyeY, width: eyeSize, height: eyeSize))
                let rightEye = Path(ellipseIn: CGRect(x: 258 * s + shift, y: eyeY, width: eyeSize, height: eyeSize))
                ctx.fill(leftEye,  with: .color(Color(.label)))
                ctx.fill(rightEye, with: .color(Color(.label)))

                var smile = Path()
                smile.addArc(
                    center: CGPoint(x: (200 * s) + shift * 0.4, y: 438 * s),
                    radius: 52 * s,
                    startAngle: .degrees(15),
                    endAngle: .degrees(165),
                    clockwise: false
                )
                ctx.stroke(smile, with: .color(Color(.label)),
                           style: StrokeStyle(lineWidth: 5 * s, lineCap: .round))
            }
            .frame(width: size, height: totalHeight)
            .opacity(faceOpacity)
        }
        .frame(width: size, height: totalHeight)
    }
}

// MARK: - Keyframe values

private struct MascotKeyValues {
    var faceRadius: CGFloat   = 500
    var bodyScale: CGFloat    = 0
    var bodyOpacity: CGFloat  = 0
    var shackleOffsetY: CGFloat = 80
    var faceOpacity: CGFloat  = 0
    var lookOffset: CGFloat   = 0
    var opacity: CGFloat      = 1
}

// MARK: - Animated splash mascot

struct LocktyMascotSplash: View {
    var size: CGFloat = 240
    var color: Color = Color(.systemGray4)
    var onFinished: (() -> Void)? = nil

    @State private var trigger = false

    var body: some View {
        KeyframeAnimator(
            initialValue: MascotKeyValues(),
            trigger: trigger
        ) { v in
            LocktyMascot(
                size: size,
                color: color,
                lookOffset: v.lookOffset,
                faceOpacity: v.faceOpacity,
                bodyOpacity: v.bodyOpacity,
                bodyScale: v.bodyScale,
                shackleOffsetY: v.shackleOffsetY,
                faceRadius: v.faceRadius
            )
            .opacity(v.opacity)
        } keyframes: { _ in
            // 1. Círculo blanco grande → encoge (0–1.2s)
            KeyframeTrack(\.faceRadius) {
                LinearKeyframe(500, duration: 0)
                SpringKeyframe(168, duration: 1.2, spring: .smooth(duration: 1.0))
            }
            // 2. Body aparece en escala (0.9–1.5s)
            KeyframeTrack(\.bodyScale) {
                LinearKeyframe(0,    duration: 0.9)
                SpringKeyframe(1.06, duration: 0.4, spring: .bouncy)
                SpringKeyframe(1.0,  duration: 0.2, spring: .smooth)
            }
            KeyframeTrack(\.bodyOpacity) {
                LinearKeyframe(0, duration: 0.9)
                LinearKeyframe(1, duration: 0.1)
            }
            // 3. Shackle sube (0.9–1.6s)
            KeyframeTrack(\.shackleOffsetY) {
                LinearKeyframe(80, duration: 0.9)
                SpringKeyframe(0, duration: 0.6, spring: .bouncy(duration: 0.5))
            }
            // 4. Cara aparece (1.6–2.0s)
            KeyframeTrack(\.faceOpacity) {
                LinearKeyframe(0, duration: 1.6)
                LinearKeyframe(1, duration: 0.35)
            }
            // 5. Mirada: izq → der → izq → der (2.0–5.8s)
            KeyframeTrack(\.lookOffset) {
                LinearKeyframe(0,  duration: 2.0)
                CubicKeyframe(-1,  duration: 0.5)
                CubicKeyframe(1,   duration: 0.9)
                CubicKeyframe(-1,  duration: 0.9)
                CubicKeyframe(1,   duration: 0.9)
                CubicKeyframe(0,   duration: 0.6)
            }
            // 6. Fade out (5.8–7.0s)
            KeyframeTrack(\.opacity) {
                LinearKeyframe(1, duration: 5.8)
                LinearKeyframe(0, duration: 0.9)
            }
        }
        .onAppear {
            trigger = true
            // Haptics sincronizados con la animación
            Haptics.play(.selection)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9)  { Haptics.play(.button) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.55) { Haptics.play(.selection) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.95) { Haptics.play(.success) }
            // Ojos izq → der → izq → der
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5)  { Haptics.play(.light) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.4)  { Haptics.play(.light) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.3)  { Haptics.play(.light) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.2)  { Haptics.play(.light) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0)  { onFinished?() }
        }
    }
}

// MARK: - Preview

#Preview("Static") {
    VStack(spacing: 40) {
        LocktyMascot(size: 200)
        LocktyMascot(size: 140, lookOffset: -1)
        LocktyMascot(size: 80,  lookOffset: 1)
    }
    .padding()
}

#Preview("Animated Splash") {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        LocktyMascotSplash(size: 240)
    }
}
