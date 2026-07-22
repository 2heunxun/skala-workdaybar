import AppKit

enum FillDirection {
    case leftToRight
    case bottomToTop
}

enum IconRenderer {
    static func render(base: NSImage, progress: Double, dimAlpha: CGFloat, direction: FillDirection) -> NSImage {
        let clamped = min(max(progress, 0), 1)
        let size = base.size

        return NSImage(size: size, flipped: false) { rect in
            base.draw(in: rect, from: .zero, operation: .sourceOver, fraction: dimAlpha)

            guard clamped > 0 else { return true }

            let clipRect: NSRect
            switch direction {
            case .leftToRight:
                clipRect = NSRect(x: rect.minX, y: rect.minY, width: rect.width * CGFloat(clamped), height: rect.height)
            case .bottomToTop:
                clipRect = NSRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height * CGFloat(clamped))
            }

            NSGraphicsContext.saveGraphicsState()
            NSBezierPath(rect: clipRect).setClip()
            base.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()

            return true
        }
    }
}
