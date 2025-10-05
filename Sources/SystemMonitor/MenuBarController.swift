import SwiftUI
import AppKit
import Combine

class MenuBarController: NSObject, ObservableObject {
    private var statusBarItem: NSStatusItem!
    private var popover: NSPopover!
    private let systemMetrics = SystemMetrics()
    private var cancellables = Set<AnyCancellable>()
    private var eventMonitor: Any?

    override init() {
        super.init()

        setupPopover()
        setupMenuBar()

        // Listen for metrics updates to refresh menu bar
        systemMetrics.$cpuUsage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusBarButton()
            }
            .store(in: &cancellables)
    }

    deinit {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }

    private func setupPopover() {
        let contentView = LiquidGlassMenuView()
            .environmentObject(systemMetrics)

        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 460)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: contentView)

        // Add event monitor to close popover when clicking outside
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if self?.popover.isShown == true {
                self?.popover.performClose(nil)
            }
        }
    }

    private func setupMenuBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem.button {
            button.title = "Loading..."
            button.action = #selector(togglePopover)
            button.target = self
        }

        updateStatusBarButton()
    }

    private func updateStatusBarButton() {
        guard let button = statusBarItem.button else { return }

        // Create menu bar image with metrics
        let image = createMenuBarImage(
            cpu: Int(systemMetrics.cpuUsage),
            networkUp: Int(systemMetrics.networkUpload),
            networkDown: Int(systemMetrics.networkDownload),
            diskFreeGB: Int((systemMetrics.diskTotal - systemMetrics.diskUsed) / (1024*1024*1024))
        )

        button.image = image
        button.title = ""
    }

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            if let button = statusBarItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

                // Ensure the popover becomes key and visible
                DispatchQueue.main.async {
                    self.popover.contentViewController?.view.window?.makeKey()
                }
            }
        }
    }

    // MARK: - Menu Bar Image Creation
    private func createMenuBarImage(cpu: Int, networkUp: Int, networkDown: Int, diskFreeGB: Int) -> NSImage {
        let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        let textColor = NSColor.controlTextColor
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]

        let cpuText = "\(cpu)%"
        let netUpText = "\(networkUp)"
        let netDownText = "\(networkDown)"
        let diskFreeText = "\(diskFreeGB)GB"

        let iconSize: CGFloat = 16
        let spacing: CGFloat = 5
        let groupSpacing: CGFloat = 12

        // Calculate width for each metric group
        let cpuWidth = iconSize + spacing + cpuText.size(withAttributes: textAttributes).width
        let netText = "↑\(netUpText)/↓\(netDownText)"
        let netWidth = iconSize + spacing + netText.size(withAttributes: textAttributes).width
        let diskWidth = iconSize + spacing + diskFreeText.size(withAttributes: textAttributes).width

        let totalWidth = cpuWidth + groupSpacing + netWidth + groupSpacing + diskWidth

        let imageSize = NSSize(width: totalWidth, height: 24)
        let image = NSImage(size: imageSize)

        image.lockFocus()
        defer { image.unlockFocus() }

        NSColor.clear.setFill()
        NSRect(origin: .zero, size: imageSize).fill()

        var xOffset: CGFloat = 0

        // CPU icon and text
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        if let cpuIcon = NSImage(systemSymbolName: "cpu.fill", accessibilityDescription: "CPU")?.withSymbolConfiguration(config) {
            let iconRect = NSRect(x: xOffset, y: (imageSize.height - cpuIcon.size.height) / 2, width: cpuIcon.size.width, height: cpuIcon.size.height)
            cpuIcon.draw(in: iconRect)
        }
        xOffset += iconSize + spacing
        let cpuTextY = (imageSize.height - cpuText.size(withAttributes: textAttributes).height) / 2
        cpuText.draw(at: NSPoint(x: xOffset, y: cpuTextY), withAttributes: textAttributes)
        xOffset += cpuText.size(withAttributes: textAttributes).width + groupSpacing

        // Network icon and text
        if let netIcon = NSImage(systemSymbolName: "arrow.up.arrow.down.circle.fill", accessibilityDescription: "Network")?.withSymbolConfiguration(config) {
            let iconRect = NSRect(x: xOffset, y: (imageSize.height - netIcon.size.height) / 2, width: netIcon.size.width, height: netIcon.size.height)
            netIcon.draw(in: iconRect)
        }
        xOffset += iconSize + spacing
        let netTextY = (imageSize.height - netText.size(withAttributes: textAttributes).height) / 2
        netText.draw(at: NSPoint(x: xOffset, y: netTextY), withAttributes: textAttributes)
        xOffset += netText.size(withAttributes: textAttributes).width + groupSpacing

        // Disk icon and text
        if let diskIcon = NSImage(systemSymbolName: "internaldrive.fill", accessibilityDescription: "Disk")?.withSymbolConfiguration(config) {
            let iconRect = NSRect(x: xOffset, y: (imageSize.height - diskIcon.size.height) / 2, width: diskIcon.size.width, height: diskIcon.size.height)
            diskIcon.draw(in: iconRect)
        }
        xOffset += iconSize + spacing
        let diskTextY = (imageSize.height - diskFreeText.size(withAttributes: textAttributes).height) / 2
        diskFreeText.draw(at: NSPoint(x: xOffset, y: diskTextY), withAttributes: textAttributes)

        image.isTemplate = true
        return image
    }
}
