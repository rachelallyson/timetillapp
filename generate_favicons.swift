// Renders apple-touch-icon (180x180) + favicon (32x32) PNGs from
// the same gradient + countdown ring as the app icon.
import AppKit
import CoreGraphics

func render(size: CGFloat, to path: String) throws {
    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(
        data: nil, width: Int(size), height: Int(size),
        bitsPerComponent: 8, bytesPerRow: 0, space: cs,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )!

    // Sunset gradient
    let bg = CGGradient(
        colorsSpace: cs,
        colors: [
            CGColor(red: 1.00, green: 0.55, blue: 0.20, alpha: 1.0),
            CGColor(red: 0.97, green: 0.30, blue: 0.40, alpha: 1.0),
            CGColor(red: 0.55, green: 0.18, blue: 0.55, alpha: 1.0)
        ] as CFArray,
        locations: [0, 0.5, 1.0]
    )!
    ctx.drawLinearGradient(bg,
        start: CGPoint(x: 0, y: size),
        end: CGPoint(x: size, y: 0),
        options: []
    )

    // Countdown ring (270° clockwise from 12 o'clock)
    let center = CGPoint(x: size/2, y: size/2)
    let radius: CGFloat = size * 0.32
    let lineWidth: CGFloat = max(3, size * 0.085)

    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.22))
    ctx.setLineWidth(lineWidth)
    ctx.setLineCap(.round)
    ctx.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.strokePath()

    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1.0))
    let start: CGFloat = .pi / 2
    let end: CGFloat = start - (.pi * 2 * 0.75)
    ctx.addArc(center: center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
    ctx.strokePath()

    let dotR: CGFloat = lineWidth * 0.95
    let dotX = center.x + cos(end) * radius
    let dotY = center.y + sin(end) * radius
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1.0))
    ctx.fillEllipse(in: CGRect(x: dotX - dotR, y: dotY - dotR, width: dotR*2, height: dotR*2))

    // Center pip — only draw on larger sizes
    if size >= 96 {
        let pipR: CGFloat = size * 0.022
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.9))
        ctx.fillEllipse(in: CGRect(x: center.x - pipR, y: center.y - pipR, width: pipR*2, height: pipR*2))
    }

    let cgImage = ctx.makeImage()!
    let rep = NSBitmapImageRep(cgImage: cgImage)
    let png = rep.representation(using: .png, properties: [:])!
    try png.write(to: URL(fileURLWithPath: path))
    print("wrote \(path)")
}

try render(size: 180, to: "apple-touch-icon.png")
try render(size: 32, to: "favicon-32.png")
try render(size: 16, to: "favicon-16.png")
