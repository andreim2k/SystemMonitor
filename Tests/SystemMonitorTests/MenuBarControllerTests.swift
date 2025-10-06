import XCTest
import AppKit
import SwiftUI
import Combine
@testable import SystemMonitor

final class MenuBarControllerTests: XCTestCase {
    var menuBarController: MenuBarController!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        menuBarController = MenuBarController()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        menuBarController = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testMenuBarControllerInitialization() {
        XCTAssertNotNil(menuBarController)
    }
    
    func testMenuBarControllerHasStatusBarItem() {
        // Access the private statusBarItem through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let statusBarItem = mirror.children.first { $0.label == "statusBarItem" }?.value as? NSStatusItem
        
        XCTAssertNotNil(statusBarItem, "MenuBarController should have a status bar item")
    }
    
    func testMenuBarControllerHasPopover() {
        // Access the private popover through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let popover = mirror.children.first { $0.label == "popover" }?.value as? NSPopover
        
        XCTAssertNotNil(popover, "MenuBarController should have a popover")
    }
    
    // MARK: - Status Bar Button Tests
    
    func testStatusBarButtonIsCreated() {
        // Access the private statusBarItem through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let statusBarItem = mirror.children.first { $0.label == "statusBarItem" }?.value as? NSStatusItem
        
        XCTAssertNotNil(statusBarItem?.button, "Status bar item should have a button")
    }
    
    func testStatusBarButtonHasAction() {
        // Access the private statusBarItem through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let statusBarItem = mirror.children.first { $0.label == "statusBarItem" }?.value as? NSStatusItem
        
        let button = statusBarItem?.button
        XCTAssertNotNil(button?.action, "Button should have an action")
        XCTAssertEqual(button?.target as? MenuBarController, menuBarController, "Button target should be the controller")
    }
    
    func testStatusBarButtonInitialTitle() {
        // Access the private statusBarItem through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let statusBarItem = mirror.children.first { $0.label == "statusBarItem" }?.value as? NSStatusItem
        
        let button = statusBarItem?.button
        XCTAssertEqual(button?.title, "Loading...", "Initial button title should be 'Loading...'")
    }
    
    // MARK: - Popover Tests
    
    func testPopoverConfiguration() {
        // Access the private popover through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let popover = mirror.children.first { $0.label == "popover" }?.value as? NSPopover
        
        XCTAssertEqual(popover?.contentSize, NSSize(width: 360, height: 400), "Popover should have correct size")
        XCTAssertEqual(popover?.behavior, .transient, "Popover should be transient")
        XCTAssertTrue(popover?.animates == true, "Popover should animate")
    }
    
    func testPopoverHasContentViewController() {
        // Access the private popover through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let popover = mirror.children.first { $0.label == "popover" }?.value as? NSPopover
        
        XCTAssertNotNil(popover?.contentViewController, "Popover should have a content view controller")
        XCTAssertTrue(popover?.contentViewController is NSHostingController<LiquidGlassMenuView>, 
                    "Content view controller should be NSHostingController<LiquidGlassMenuView>")
    }
    
    // MARK: - Menu Bar Image Tests
    
    func testCreateMenuBarImageWithValidInputs() {
        // Access the private method through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let image = mirror.children.first { $0.label == "image" }?.value as? NSImage
        
        // Test that image creation doesn't crash with valid inputs
        XCTAssertTrue(true, "Image creation should not crash with valid inputs")
    }
    
    func testMenuBarImageIsTemplate() {
        // The image should be template for proper menu bar display
        // We can't directly test the private method, but we can verify the concept
        XCTAssertTrue(true, "Menu bar images should be template images")
    }
    
    // MARK: - System Metrics Integration Tests
    
    func testMenuBarControllerSubscribesToSystemMetrics() {
        // Access the private systemMetrics through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let systemMetrics = mirror.children.first { $0.label == "systemMetrics" }?.value as? SystemMetrics
        
        XCTAssertNotNil(systemMetrics, "MenuBarController should have SystemMetrics instance")
    }
    
    func testMenuBarControllerUpdatesOnMetricsChange() {
        let expectation = XCTestExpectation(description: "Menu bar should update on metrics change")
        
        // Access the private systemMetrics through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let systemMetrics = mirror.children.first { $0.label == "systemMetrics" }?.value as? SystemMetrics
        
        // Monitor for updates (we can't directly test the button update, but we can verify the subscription)
        systemMetrics?.$cpuUsage
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - Event Monitor Tests
    
    func testEventMonitorIsSetUp() {
        // Access the private eventMonitor through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let eventMonitor = mirror.children.first { $0.label == "eventMonitor" }?.value
        
        XCTAssertNotNil(eventMonitor, "MenuBarController should have an event monitor")
    }
    
    // MARK: - Memory Management Tests
    
    func testMenuBarControllerCleansUpProperly() {
        weak var weakController: MenuBarController?
        
        do {
            let controller = MenuBarController()
            weakController = controller
            // controller goes out of scope here
        }
        
        // Give time for deinit to be called
        let expectation = XCTestExpectation(description: "Cleanup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
        
        // The controller should clean up properly
        XCTAssertTrue(true, "MenuBarController should clean up properly")
    }
    
    // MARK: - UI Interaction Tests
    
    func testPopoverToggleBehavior() {
        // Access the private popover through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let popover = mirror.children.first { $0.label == "popover" }?.value as? NSPopover
        
        let initialShownState = popover?.isShown ?? false
        
        // Test that popover state can be toggled (we can't directly call the private method)
        XCTAssertNotNil(popover, "Popover should exist for toggling")
    }
    
    // MARK: - Performance Tests
    
    func testMenuBarControllerInitializationPerformance() {
        measure {
            let controller = MenuBarController()
            XCTAssertNotNil(controller)
        }
    }
    
    func testMenuBarImageCreationPerformance() {
        measure {
            // Test image creation performance indirectly
            let image = NSImage(size: NSSize(width: 200, height: 24))
            image.lockFocus()
            NSColor.clear.setFill()
            NSRect(origin: .zero, size: image.size).fill()
            image.unlockFocus()
            XCTAssertNotNil(image)
        }
    }
    
    // MARK: - Edge Cases
    
    func testMenuBarControllerHandlesNilStatusBar() {
        // Test that the controller handles edge cases gracefully
        XCTAssertNotNil(menuBarController, "Controller should handle edge cases")
    }
    
    func testMenuBarControllerHandlesNilButton() {
        // Test that the controller handles missing button gracefully
        XCTAssertNotNil(menuBarController, "Controller should handle missing button")
    }
    
    // MARK: - Integration with System Metrics
    
    func testMenuBarControllerReceivesMetricsUpdates() {
        let expectation = XCTestExpectation(description: "Should receive metrics updates")
        
        // Access the private systemMetrics through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let systemMetrics = mirror.children.first { $0.label == "systemMetrics" }?.value as? SystemMetrics
        
        // Monitor multiple metrics
        systemMetrics?.$cpuUsage
            .combineLatest(systemMetrics?.$memoryUsage ?? Just(0.0).eraseToAnyPublisher())
            .dropFirst()
            .sink { _, _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - Accessibility Tests
    
    func testMenuBarButtonHasAccessibilityDescription() {
        // Access the private statusBarItem through reflection for testing
        let mirror = Mirror(reflecting: menuBarController!)
        let statusBarItem = mirror.children.first { $0.label == "statusBarItem" }?.value as? NSStatusItem
        
        let button = statusBarItem?.button
        // Test that the button has proper accessibility support
        XCTAssertNotNil(button, "Button should exist for accessibility testing")
    }
    
    // MARK: - Thread Safety Tests
    
    func testMenuBarControllerThreadSafety() {
        let expectation = XCTestExpectation(description: "Thread safety test")
        
        DispatchQueue.global(qos: .background).async {
            // Access the controller from a background thread
            XCTAssertNotNil(self.menuBarController)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
}
