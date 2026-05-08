// Renders a 1200x630 Open Graph share image for social previews.
// Run:  swift generate_og.swift
import AppKit
import CoreGraphics
import CoreText

let W: CGFloat = 1200
let H: CGFloat = 630
let url = URL(fileURLWithPath: "og.png")

let cs = CGColorSpaceCreateDeviceRGB()
let ctx = CGContext(
    data: nil, width: Int(W), height: Int(H),
    bitsPerComponent: 8, bytesPerRow: 0, space: cs,
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
)!

// ── Sunset gradient background ──
let bgColors = [
    CGColor(red: 1.00, green: 0.55, blue: 0.20, alpha: 1.0),
    CGColor(red: 0.97, green: 0.30, blue: 0.40, alpha: 1.0),
    CGColor(red: 0.55, green: 0.18, blue: 0.55, alpha: 1.0)
] as CFArray
let gradient = CGGradient(colorsSpace: cs, colors: bgColors, locations: [0, 0.5, 1])!
ctx.drawLinearGradient(
    gradient,
    start: CGPoint(x: 0, y: H),
    end: CGPoint(x: W, y: 0),
    options: []
)

// ── Soft glow ──
let glow = CGGradient(
    colorsSpace: cs,
    colors: [
        CGColor(red: 1, green: 1, blue: 1, alpha: 0.20),
        CGColor(red: 1, green: 1, blue: 1, alpha: 0.0)
    ] as CFArray,
    locations: [0, 1]
)!
ctx.drawRadialGradient(
    glow,
    startCenter: CGPoint(x: W * 0.7, y: H * 0.5), startRadius: 0,
    endCenter:   CGPoint(x: W * 0.7, y: H * 0.5), endRadius: 360,
    options: []
)

// ── Countdown ring (centered on right side) ──
let ringCenter = CGPoint(x: W * 0.78, y: H * 0.5)
let ringRadius: CGFloat = 130
let ringWidth: CGFloat = 36

// Track
ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.20))
ctx.setLineWidth(ringWidth)
ctx.setLineCap(.round)
ctx.addArc(center: ringCenter, radius: ringRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
ctx.strokePath()

// Foreground arc (270°)
ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1.0))
ctx.setLineWidth(ringWidth)
ctx.setLineCap(.round)
let start: CGFloat = .pi / 2
let end: CGFloat = start - (.pi * 2 * 0.75)
ctx.addArc(center: ringCenter, radius: ringRadius, startAngle: start, endAngle: end, clockwise: true)
ctx.strokePath()

// Marker dot
let dotR: CGFloat = ringWidth * 0.95
let dotX = ringCenter.x + cos(end) * ringRadius
let dotY = ringCenter.y + sin(end) * ringRadius
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1.0))
ctx.fillEllipse(in: CGRect(x: dotX - dotR, y: dotY - dotR, width: dotR*2, height: dotR*2))

// ── Text on the left ──
func draw(text: String, at point: CGPoint, font: NSFont, color: NSColor = .white) {
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color
    ]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attrs))
    ctx.textPosition = point
    CTLineDraw(line, ctx)
}

// "TIMETILL" eyebrow
draw(
    text: "TIMETILL",
    at: CGPoint(x: 80, y: H - 200),
    font: NSFont.systemFont(ofSize: 22, weight: .bold),
    color: NSColor(white: 1, alpha: 0.85)
)

// Headline
draw(
    text: "Live countdown to",
    at: CGPoint(x: 80, y: H - 280),
    font: NSFont.systemFont(ofSize: 60, weight: .heavy)
)
draw(
    text: "your next event.",
    at: CGPoint(x: 80, y: H - 350),
    font: NSFont.systemFont(ofSize: 60, weight: .heavy)
)

// Subhead
draw(
    text: "iPhone · Apple Watch · Lock Screen · Dynamic Island",
    at: CGPoint(x: 80, y: H - 415),
    font: NSFont.systemFont(ofSize: 22, weight: .medium),
    color: NSColor(white: 1, alpha: 0.85)
)

// ── Write PNG ──
let cgImage = ctx.makeImage()!
let rep = NSBitmapImageRep(cgImage: cgImage)
let png = rep.representation(using: .png, properties: [:])!
try png.write(to: url)
print("wrote \(url.path)")
