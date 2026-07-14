import AppKit

private enum CatMotion { case idle, walking }

private final class CatView: NSView {
    private var phase: CGFloat = 0
    private var motion: CatMotion = .idle
    private var direction: CGFloat = 1
    private var targetX: CGFloat = 110
    private var lastTick = Date()

    override var isFlipped: Bool { true }

    func start() {
        Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            self.tick()
        }
    }

    private func tick() {
        let now = Date()
        let delta = min(now.timeIntervalSince(lastTick), 0.1)
        lastTick = now
        phase += CGFloat(delta)

        if motion == .idle && Int.random(in: 0...900) == 0 {
            motion = .walking
            targetX = CGFloat.random(in: 72...148)
            direction = targetX >= bounds.midX ? 1 : -1
        }

        if motion == .walking {
            let step = CGFloat(delta) * 34
            let nextX = frame.midX + step * direction
            if direction > 0 ? nextX >= targetX : nextX <= targetX {
                motion = .idle
            } else {
                setFrameOrigin(NSPoint(x: frame.origin.x + step * direction, y: frame.origin.y))
            }
        }
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        let body = NSRect(x: 42, y: 72, width: 116, height: 78)
        let head = NSRect(x: 30, y: 22, width: 140, height: 96)
        let leftEar = NSBezierPath()
        leftEar.move(to: NSPoint(x: 38, y: 52)); leftEar.line(to: NSPoint(x: 45, y: 5)); leftEar.line(to: NSPoint(x: 78, y: 35)); leftEar.close()
        let rightEar = NSBezierPath()
        rightEar.move(to: NSPoint(x: 122, y: 35)); rightEar.line(to: NSPoint(x: 155, y: 5)); rightEar.line(to: NSPoint(x: 162, y: 52)); rightEar.close()

        NSColor(calibratedWhite: 0.055, alpha: 1).setFill()
        NSBezierPath(ovalIn: body).fill(); NSBezierPath(ovalIn: head).fill(); leftEar.fill(); rightEar.fill()

        NSColor(calibratedWhite: 0.19, alpha: 1).setFill()
        NSBezierPath(ovalIn: NSRect(x: 55, y: 46, width: 31, height: 38)).fill()
        NSBezierPath(ovalIn: NSRect(x: 114, y: 46, width: 31, height: 38)).fill()
        NSColor(calibratedRed: 0.94, green: 0.72, blue: 0.18, alpha: 1).setFill()
        NSBezierPath(ovalIn: NSRect(x: 63, y: 55, width: 15, height: 22)).fill()
        NSBezierPath(ovalIn: NSRect(x: 122, y: 55, width: 15, height: 22)).fill()
        NSColor.white.setFill()
        NSBezierPath(ovalIn: NSRect(x: 67, y: 58, width: 5, height: 7)).fill()
        NSBezierPath(ovalIn: NSRect(x: 126, y: 58, width: 5, height: 7)).fill()
        NSColor(calibratedRed: 0.72, green: 0.28, blue: 0.32, alpha: 1).setFill()
        NSBezierPath(ovalIn: NSRect(x: 94, y: 78, width: 12, height: 8)).fill()

        let tail = NSBezierPath()
        tail.lineWidth = 13; tail.lineCapStyle = .round
        tail.move(to: NSPoint(x: 148, y: 124))
        let sway = sin(phase * 2.2) * 14
        tail.curve(to: NSPoint(x: 180 + sway, y: 88), controlPoint1: NSPoint(x: 190 + sway, y: 132), controlPoint2: NSPoint(x: 192 + sway, y: 95))
        NSColor(calibratedWhite: 0.075, alpha: 1).setStroke(); tail.stroke()

        NSColor(calibratedWhite: 0.11, alpha: 0.65).setFill()
        NSBezierPath(ovalIn: NSRect(x: 74, y: 143, width: 26, height: 15)).fill()
        NSBezierPath(ovalIn: NSRect(x: 106, y: 143, width: 26, height: 15)).fill()
    }
}

private final class CatWindowController: NSObject {
    private let window: NSWindow
    private let catView: CatView

    override init() {
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let size = NSSize(width: 220, height: 190)
        let origin = NSPoint(x: screen.midX - size.width / 2, y: screen.minY + 72)
        window = NSWindow(contentRect: NSRect(origin: origin, size: size), styleMask: [.borderless], backing: .buffered, defer: false)
        catView = CatView(frame: NSRect(origin: .zero, size: size))
        super.init()
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.ignoresMouseEvents = true
        window.contentView = catView
    }

    func show() { window.orderFrontRegardless(); catView.start() }
}

private final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: CatWindowController?
    func applicationDidFinishLaunching(_ notification: Notification) { controller = CatWindowController(); controller?.show() }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

let app = NSApplication.shared
private let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
