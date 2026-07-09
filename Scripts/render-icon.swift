// Renders the app icon: a liquid-glass barbell on the app's ink color.
// Usage: swift Scripts/render-icon.swift <output.png>
import AppKit
import CoreGraphics

let size: CGFloat = 1024
guard CommandLine.arguments.count > 1 else {
    fputs("usage: render-icon.swift <output.png>\n", stderr)
    exit(1)
}
let outURL = URL(fileURLWithPath: CommandLine.arguments[1])

func color(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}

let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: Int(size), height: Int(size),
                    bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

// ── background: the app's ink, with a soft sheen from the top ──
ctx.setFillColor(color(0x1A1A18))
ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))

let bgGrad = CGGradient(colorsSpace: cs, colors: [
    color(0x2E2E2A, 0.9), color(0x1A1A18, 0.0),
] as CFArray, locations: [0, 1])!
ctx.drawRadialGradient(bgGrad,
    startCenter: CGPoint(x: size * 0.5, y: size * 1.05), startRadius: 0,
    endCenter: CGPoint(x: size * 0.5, y: size * 1.05), endRadius: size * 1.1,
    options: [])

// ── barbell geometry (y up; visual center slightly above middle) ──
let cy = size * 0.5
let barW: CGFloat = 700, barH: CGFloat = 54
let plateW: CGFloat = 100, plateH: CGFloat = 330
let collarW: CGFloat = 58, collarH: CGFloat = 200
let plateGap: CGFloat = 22
// bar ends tucked under the collars
let bar = CGRect(x: (size - barW) / 2, y: cy - barH / 2, width: barW, height: barH)
let collarL = CGRect(x: bar.minX + 44, y: cy - collarH / 2, width: collarW, height: collarH)
let collarR = CGRect(x: bar.maxX - 44 - collarW, y: cy - collarH / 2, width: collarW, height: collarH)
let plateL = CGRect(x: collarL.maxX + plateGap, y: cy - plateH / 2, width: plateW, height: plateH)
let plateR = CGRect(x: collarR.minX - plateGap - plateW, y: cy - plateH / 2, width: plateW, height: plateH)

func rounded(_ r: CGRect, _ radius: CGFloat) -> CGPath {
    CGPath(roundedRect: r, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

/// Draws one glass slab: translucent body, top specular gradient,
/// bright top rim, faint bottom rim, and a drop shadow onto the bg.
func glass(_ rect: CGRect, radius: CGFloat, body: CGFloat) {
    let path = rounded(rect, radius)

    // drop shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -26), blur: 60,
                  color: color(0x000000, 0.45))
    ctx.addPath(path)
    ctx.setFillColor(color(0xFFFFFF, body))
    ctx.fillPath()
    ctx.restoreGState()

    // inner vertical sheen: bright top fading out
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    let sheen = CGGradient(colorsSpace: cs, colors: [
        color(0xFFFFFF, 0.34), color(0xFFFFFF, 0.05), color(0xFFFFFF, 0.0),
        color(0xFFFFFF, 0.10),
    ] as CFArray, locations: [0, 0.42, 0.72, 1])!
    ctx.drawLinearGradient(sheen,
        start: CGPoint(x: rect.midX, y: rect.maxY),
        end: CGPoint(x: rect.midX, y: rect.minY), options: [])
    // diagonal caustic streak
    let streak = CGGradient(colorsSpace: cs, colors: [
        color(0xFFFFFF, 0.0), color(0xFFFFFF, 0.16), color(0xFFFFFF, 0.0),
    ] as CFArray, locations: [0.35, 0.5, 0.65])!
    ctx.drawLinearGradient(streak,
        start: CGPoint(x: rect.minX - rect.width, y: rect.maxY),
        end: CGPoint(x: rect.maxX + rect.width, y: rect.minY), options: [])
    ctx.restoreGState()

    // top rim light
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    ctx.addPath(rounded(rect.insetBy(dx: 2.5, dy: 2.5), max(2, radius - 2.5)))
    ctx.setStrokeColor(color(0xFFFFFF, 0.45))
    ctx.setLineWidth(4)
    let rimTop = CGGradient(colorsSpace: cs, colors: [
        color(0xFFFFFF, 0.55), color(0xFFFFFF, 0.0),
    ] as CFArray, locations: [0, 1])!
    ctx.replacePathWithStrokedPath()
    ctx.clip()
    ctx.drawLinearGradient(rimTop,
        start: CGPoint(x: rect.midX, y: rect.maxY),
        end: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.2), options: [])
    ctx.restoreGState()
}

// back-to-front: bar behind, then collars, then plates
glass(bar, radius: barH / 2, body: 0.10)
glass(collarL, radius: collarW / 2, body: 0.13)
glass(collarR, radius: collarW / 2, body: 0.13)
glass(plateL, radius: 44, body: 0.16)
glass(plateR, radius: 44, body: 0.16)

// ── write png ──
let image = ctx.makeImage()!
let rep = NSBitmapImageRep(cgImage: image)
rep.size = NSSize(width: size, height: size)
let png = rep.representation(using: .png, properties: [:])!
try! png.write(to: outURL)
print("wrote \(outURL.path)")
