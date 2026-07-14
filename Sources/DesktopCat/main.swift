import AppKit

private enum CatActivity { case idle, walking, eating, playing }

private final class CatView: NSView {
    private var phase: CGFloat = 0
    private var activity: CatActivity = .idle
    private var direction: CGFloat = 1
    private var targetX: CGFloat = 110
    private var lastTick = Date()
    private var nextReminderAt = Date().addingTimeInterval(3600)
    private var feedback = ""
    private var feedbackUntil = Date.distantPast

    override var isFlipped: Bool { true }

    func start() {
        Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            self.tick()
        }
    }

    func pet() { showFeedback("喵") }
    func feed() { activity = .eating; showFeedback("谢谢你") }
    func play() { activity = .playing; showFeedback("来玩吧") }
    func remindWater() { showFeedback("喝点水吧") }

    private func showFeedback(_ text: String) {
        feedback = text
        feedbackUntil = Date().addingTimeInterval(2.2)
        activity = .idle
        needsDisplay = true
    }

    private func tick() {
        let now = Date()
        let delta = min(now.timeIntervalSince(lastTick), 0.1)
        lastTick = now
        phase += CGFloat(delta)

        if activity == .idle && Int.random(in: 0...900) == 0 {
            activity = .walking
            let desktop = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
            targetX = CGFloat.random(in: (desktop.minX + 90)...(desktop.maxX - 90))
            direction = targetX >= (window?.frame.midX ?? targetX) ? 1 : -1
        }

        if activity == .walking {
            let speed: CGFloat = 34
            let step = CGFloat(delta) * speed
            let nextX = (window?.frame.midX ?? targetX) + step * direction
            if direction > 0 ? nextX >= targetX : nextX <= targetX {
                activity = .idle
            } else {
                let origin = window?.frame.origin ?? .zero
                window?.setFrameOrigin(NSPoint(x: origin.x + step * direction, y: origin.y))
            }
        }

        if now >= nextReminderAt {
            remindWater()
            nextReminderAt = now.addingTimeInterval(3600)
        }

        if activity == .eating && Int(phase * 10) % 45 == 0 { activity = .idle }
        if activity == .playing && Int(phase * 10) % 75 == 0 { activity = .idle }
        needsDisplay = true
    }

    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
        pet()
    }

    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        menu.addItem(withTitle: "摸摸", action: #selector(ActionTarget.pet), keyEquivalent: "")
        menu.addItem(withTitle: "喂食", action: #selector(ActionTarget.feed), keyEquivalent: "")
        menu.addItem(withTitle: "逗猫棒", action: #selector(ActionTarget.play), keyEquivalent: "")
        menu.items.forEach { $0.target = ActionTarget.shared }
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    override func draw(_ dirtyRect: NSRect) {
        let body = NSRect(x: 42, y: 72, width: 116, height: 78)
        let head = NSRect(x: 30, y: 22, width: 140, height: 96)
        let leftEar = triangle([(38, 52), (45, 5), (78, 35)])
        let rightEar = triangle([(122, 35), (155, 5), (162, 52)])

        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.34)
        shadow.shadowBlurRadius = 9
        shadow.shadowOffset = NSSize(width: 0, height: -3)
        shadow.set()
        NSColor(calibratedWhite: 0.055, alpha: 1).setFill()
        NSBezierPath(ovalIn: body).fill(); NSBezierPath(ovalIn: head).fill(); leftEar.fill(); rightEar.fill()
        NSShadow().set()

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

        let whiskers = NSBezierPath()
        whiskers.lineWidth = 1
        whiskers.move(to: NSPoint(x: 82, y: 88)); whiskers.line(to: NSPoint(x: 28, y: 82))
        whiskers.move(to: NSPoint(x: 82, y: 94)); whiskers.line(to: NSPoint(x: 24, y: 96))
        whiskers.move(to: NSPoint(x: 138, y: 88)); whiskers.line(to: NSPoint(x: 192, y: 82))
        whiskers.move(to: NSPoint(x: 138, y: 94)); whiskers.line(to: NSPoint(x: 196, y: 96))
        NSColor.white.withAlphaComponent(0.42).setStroke(); whiskers.stroke()

        if activity == .eating {
            NSColor(calibratedRed: 0.84, green: 0.55, blue: 0.25, alpha: 1).setFill()
            NSBezierPath(ovalIn: NSRect(x: 166, y: 142, width: 28, height: 18)).fill()
        }

        if Date() < feedbackUntil { drawBubble(feedback) }
    }

    private func triangle(_ points: [(CGFloat, CGFloat)]) -> NSBezierPath {
        let path = NSBezierPath()
        path.move(to: NSPoint(x: points[0].0, y: points[0].1))
        points.dropFirst().forEach { path.line(to: NSPoint(x: $0.0, y: $0.1)) }
        path.close()
        return path
    }

    private func drawBubble(_ text: String) {
        let bubble = NSRect(x: 42, y: -2, width: 136, height: 30)
        NSColor(calibratedWhite: 1, alpha: 0.94).setFill()
        NSBezierPath(roundedRect: bubble, xRadius: 12, yRadius: 12).fill()
        let pointer = NSBezierPath()
        pointer.move(to: NSPoint(x: 64, y: 28)); pointer.line(to: NSPoint(x: 58, y: 38)); pointer.line(to: NSPoint(x: 78, y: 28)); pointer.close()
        pointer.fill()
        let style = NSMutableParagraphStyle(); style.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 13), .foregroundColor: NSColor(calibratedWhite: 0.12, alpha: 1), .paragraphStyle: style]
        text.draw(in: bubble.insetBy(dx: 8, dy: 7), withAttributes: attributes)
    }
}

private final class ActionTarget: NSObject {
    static let shared = ActionTarget()
    weak var catView: CatView?
    @objc func pet() { catView?.pet() }
    @objc func feed() { catView?.feed() }
    @objc func play() { catView?.play() }
    @objc func remindWater() { catView?.remindWater() }
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
        window.isOpaque = false; window.backgroundColor = .clear; window.hasShadow = false
        window.level = .floating; window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = catView
        ActionTarget.shared.catView = catView
    }

    func show() { window.orderFrontRegardless(); catView.start() }
    func remindWater() { catView.remindWater() }
}

private final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: CatWindowController?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        controller = CatWindowController(); controller?.show()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "Cat"
        let menu = NSMenu()
        menu.addItem(withTitle: "Desktop Cat 正在陪伴", action: nil, keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "测试喝水提醒", action: #selector(testReminder), keyEquivalent: "")
        menu.addItem(withTitle: "退出", action: #selector(quit), keyEquivalent: "q")
        menu.items[2].target = self
        menu.items[3].target = self
        statusItem?.menu = menu
    }

    @objc private func testReminder() { controller?.remindWater() }
    @objc private func quit() { NSApplication.shared.terminate(nil) }
}

private let app = NSApplication.shared
private let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
