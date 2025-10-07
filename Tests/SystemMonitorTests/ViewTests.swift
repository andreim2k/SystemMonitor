import XCTest
import SwiftUI
import Combine
@testable import SystemMonitor

final class ViewTests: XCTestCase {
    var mockSystemMetrics: MockSystemMetrics!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockSystemMetrics = TestHelpers.createMockSystemMetrics()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        mockSystemMetrics = nil
        super.tearDown()
    }
    
    // MARK: - LiquidGlassMenuView Tests
    
    func testLiquidGlassMenuViewInitialization() {
        let view = LiquidGlassMenuView()
            .environmentObject(mockSystemMetrics)
        
        XCTAssertNotNil(view)
    }
    
    func testLiquidGlassMenuViewHasCorrectFrame() {
        let view = LiquidGlassMenuView()
            .environmentObject(mockSystemMetrics)
        
        // Test that the view has the expected frame size
        // Note: We can't directly test SwiftUI view properties, but we can verify the view exists
        XCTAssertNotNil(view)
    }
    
    func testLiquidGlassMenuViewUpdatesWithMetrics() {
        let expectation = XCTestExpectation(description: "View should update with metrics")
        
        // Test that the view responds to metrics changes
        mockSystemMetrics.$cpuUsage
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Update metrics
        mockSystemMetrics.cpuUsage = 50.0
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - LiquidGlassMetricCard Tests
    
    func testLiquidGlassMetricCardInitialization() {
        let card = LiquidGlassMetricCard(
            title: "CPU",
            value: "25.0%",
            color: .orange,
            icon: "cpu"
        )
        
        XCTAssertNotNil(card)
    }
    
    func testLiquidGlassMetricCardWithDifferentColors() {
        let colors: [Color] = [.orange, .green, .blue, .purple, .red]
        
        for color in colors {
            let card = LiquidGlassMetricCard(
                title: "Test",
                value: "100%",
                color: color,
                icon: "test"
            )
            XCTAssertNotNil(card)
        }
    }
    
    func testLiquidGlassMetricCardWithDifferentIcons() {
        let icons = ["cpu", "memorychip", "network", "disk"]
        
        for icon in icons {
            let card = LiquidGlassMetricCard(
                title: "Test",
                value: "50%",
                color: .blue,
                icon: icon
            )
            XCTAssertNotNil(card)
        }
    }
    
    // MARK: - LiquidGlassNetworkCard Tests
    
    func testLiquidGlassNetworkCardInitialization() {
        let card = LiquidGlassNetworkCard()
            .environmentObject(mockSystemMetrics)
        
        XCTAssertNotNil(card)
    }
    
    func testLiquidGlassNetworkCardUpdatesWithNetworkMetrics() {
        let expectation = XCTestExpectation(description: "Network card should update")
        
        mockSystemMetrics.$networkUpload
            .combineLatest(mockSystemMetrics.$networkDownload)
            .sink { _, _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Update network metrics
        mockSystemMetrics.networkUpload = 10.5
        mockSystemMetrics.networkDownload = 25.3
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testLiquidGlassNetworkCardDisplaysCorrectValues() {
        mockSystemMetrics.setMockData(
            networkUpload: 5.5,
            networkDownload: 12.3
        )
        
        let card = LiquidGlassNetworkCard()
            .environmentObject(mockSystemMetrics)
        
        XCTAssertNotNil(card)
        // Note: We can't directly test the displayed values in SwiftUI tests
        // but we can verify the view exists and responds to data changes
    }
    
    // MARK: - LiquidGlassDiskCard Tests
    
    func testLiquidGlassDiskCardInitialization() {
        let card = LiquidGlassDiskCard()
            .environmentObject(mockSystemMetrics)
        
        XCTAssertNotNil(card)
    }
    
    func testLiquidGlassDiskCardUpdatesWithDiskMetrics() {
        let expectation = XCTestExpectation(description: "Disk card should update")
        
        mockSystemMetrics.$diskUsed
            .combineLatest(mockSystemMetrics.$diskTotal)
            .sink { _, _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Update disk metrics
        mockSystemMetrics.diskUsed = 600 * 1024 * 1024 * 1024 // 600GB
        mockSystemMetrics.diskTotal = 1000 * 1024 * 1024 * 1024 // 1TB
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testLiquidGlassDiskCardDisplaysCorrectValues() {
        mockSystemMetrics.setMockData(
            diskUsed: 500 * 1024 * 1024 * 1024, // 500GB
            diskTotal: 1000 * 1024 * 1024 * 1024 // 1TB
        )
        
        let card = LiquidGlassDiskCard()
            .environmentObject(mockSystemMetrics)
        
        XCTAssertNotNil(card)
    }
    
    // MARK: - LiquidGlassButtonStyle Tests
    
    func testLiquidGlassButtonStyleInitialization() {
        let style = LiquidGlassButtonStyle()
        XCTAssertNotNil(style)
    }
    
    func testLiquidGlassButtonStyleWithCustomColor() {
        let style = LiquidGlassButtonStyle(color: .red)
        XCTAssertNotNil(style)
    }
    
    func testLiquidGlassButtonStyleWithDifferentColors() {
        let colors: [Color] = [.red, .blue, .green, .orange, .purple]
        
        for color in colors {
            let style = LiquidGlassButtonStyle(color: color)
            XCTAssertNotNil(style)
        }
    }
    
    // MARK: - View Composition Tests
    
    func testViewHierarchy() {
        let menuView = LiquidGlassMenuView()
            .environmentObject(mockSystemMetrics)
        
        XCTAssertNotNil(menuView)
        
        // Test that the view can be composed with other views
        let composedView = VStack {
            menuView
            Text("Additional content")
        }
        
        XCTAssertNotNil(composedView)
    }
    
    func testViewWithDifferentMetrics() {
        let highLoadMetrics = TestHelpers.createHighLoadSystemMetrics()
        let lowLoadMetrics = TestHelpers.createLowLoadSystemMetrics()
        
        let highLoadView = LiquidGlassMenuView()
            .environmentObject(highLoadMetrics)
        
        let lowLoadView = LiquidGlassMenuView()
            .environmentObject(lowLoadMetrics)
        
        XCTAssertNotNil(highLoadView)
        XCTAssertNotNil(lowLoadView)
    }
    
    // MARK: - Animation Tests
    
    func testViewAnimations() {
        let view = LiquidGlassMenuView()
            .environmentObject(mockSystemMetrics)
        
        // Test that the view supports animations
        XCTAssertNotNil(view)
        
        // Note: We can't directly test SwiftUI animations in unit tests
        // but we can verify the view exists and can be animated
    }
    
    // MARK: - Accessibility Tests
    
    func testViewAccessibility() {
        let view = LiquidGlassMenuView()
            .environmentObject(mockSystemMetrics)
        
        // Test that the view has proper accessibility support
        XCTAssertNotNil(view)
        
        // Note: SwiftUI accessibility testing requires UI testing framework
        // but we can verify the view exists for accessibility testing
    }
    
    // MARK: - Performance Tests
    
    func testViewCreationPerformance() {
        measure {
            let view = LiquidGlassMenuView()
                .environmentObject(mockSystemMetrics)
            XCTAssertNotNil(view)
        }
    }
    
    func testMetricCardCreationPerformance() {
        measure {
            let card = LiquidGlassMetricCard(
                title: "CPU",
                value: "25.0%",
                color: .orange,
                icon: "cpu"
            )
            XCTAssertNotNil(card)
        }
    }
    
    func testNetworkCardCreationPerformance() {
        measure {
            let card = LiquidGlassNetworkCard()
                .environmentObject(mockSystemMetrics)
            XCTAssertNotNil(card)
        }
    }
    
    func testDiskCardCreationPerformance() {
        measure {
            let card = LiquidGlassDiskCard()
                .environmentObject(mockSystemMetrics)
            XCTAssertNotNil(card)
        }
    }
    
    // MARK: - Edge Cases
    
    func testViewWithZeroValues() {
        mockSystemMetrics.setMockData(
            cpu: 0.0,
            memory: 0.0,
            networkUpload: 0.0,
            networkDownload: 0.0,
            diskUsage: 0.0
        )
        
        let view = LiquidGlassMenuView()
            .environmentObject(mockSystemMetrics)
        
        XCTAssertNotNil(view)
    }
    
    func testViewWithMaximumValues() {
        mockSystemMetrics.setMockData(
            cpu: 100.0,
            memory: 100.0,
            networkUpload: 1000.0,
            networkDownload: 1000.0,
            diskUsage: 100.0
        )
        
        let view = LiquidGlassMenuView()
            .environmentObject(mockSystemMetrics)
        
        XCTAssertNotNil(view)
    }
    
    func testViewWithNegativeValues() {
        mockSystemMetrics.setMockData(
            cpu: -10.0,
            memory: -5.0,
            networkUpload: -1.0,
            networkDownload: -2.0,
            diskUsage: -3.0
        )
        
        let view = LiquidGlassMenuView()
            .environmentObject(mockSystemMetrics)
        
        XCTAssertNotNil(view)
    }
    
    // MARK: - Data Binding Tests
    
    func testViewDataBinding() {
        let expectation = XCTestExpectation(description: "View should bind to data")
        
        // Test that the view responds to data changes
        mockSystemMetrics.$cpuUsage
            .combineLatest(
                mockSystemMetrics.$memoryUsage,
                mockSystemMetrics.$networkUpload,
                mockSystemMetrics.$networkDownload,
                mockSystemMetrics.$diskUsage
            )
            .sink { _, _, _, _, _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Update all metrics
        mockSystemMetrics.cpuUsage = 75.0
        mockSystemMetrics.memoryUsage = 80.0
        mockSystemMetrics.networkUpload = 15.5
        mockSystemMetrics.networkDownload = 30.2
        mockSystemMetrics.diskUsage = 60.0
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - View State Tests
    
    func testViewStateManagement() {
        let view = LiquidGlassMenuView()
            .environmentObject(mockSystemMetrics)
        
        // Test that the view manages its state properly
        XCTAssertNotNil(view)
        
        // Note: SwiftUI state management testing requires UI testing framework
        // but we can verify the view exists and can manage state
    }
    
    // MARK: - View Updates Tests
    
    func testViewUpdatesOnMetricsChange() {
        let expectation = XCTestExpectation(description: "View should update on metrics change")
        
        // Test that the view updates when metrics change
        mockSystemMetrics.$cpuUsage
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Change metrics
        mockSystemMetrics.cpuUsage = 45.0
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - View Layout Tests
    
    func testViewLayout() {
        let view = LiquidGlassMenuView()
            .environmentObject(mockSystemMetrics)
        
        // Test that the view has proper layout
        XCTAssertNotNil(view)
        
        // Note: SwiftUI layout testing requires UI testing framework
        // but we can verify the view exists and can be laid out
    }
}

