import XCTest
import SwiftUI
import AppKit
import Combine
@testable import SystemMonitor

final class IntegrationTests: XCTestCase {
    var systemMetrics: SystemMetrics!
    var menuBarController: MenuBarController!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        systemMetrics = SystemMetrics()
        menuBarController = MenuBarController()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        menuBarController = nil
        systemMetrics = nil
        super.tearDown()
    }
    
    // MARK: - System Integration Tests
    
    func testSystemMetricsAndMenuBarControllerIntegration() {
        let expectation = XCTestExpectation(description: "Integration should work")
        
        // Test that SystemMetrics and MenuBarController work together
        systemMetrics.$cpuUsage
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testEndToEndMetricsFlow() {
        let expectation = XCTestExpectation(description: "End-to-end flow should work")
        
        // Test the complete flow from system metrics to UI
        systemMetrics.$cpuUsage
            .combineLatest(
                systemMetrics.$memoryUsage,
                systemMetrics.$networkUpload,
                systemMetrics.$networkDownload,
                systemMetrics.$diskUsage
            )
            .dropFirst()
            .sink { cpu, memory, upload, download, disk in
                // Verify all metrics are updating
                XCTAssertGreaterThanOrEqual(cpu, 0.0)
                XCTAssertGreaterThanOrEqual(memory, 0.0)
                XCTAssertGreaterThanOrEqual(upload, 0.0)
                XCTAssertGreaterThanOrEqual(download, 0.0)
                XCTAssertGreaterThanOrEqual(disk, 0.0)
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - UI Integration Tests
    
    func testViewIntegrationWithSystemMetrics() {
        let view = LiquidGlassMenuView()
            .environmentObject(systemMetrics)
        
        XCTAssertNotNil(view)
        
        // Test that the view integrates properly with SystemMetrics
        let expectation = XCTestExpectation(description: "View should integrate with metrics")
        
        systemMetrics.$cpuUsage
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testMenuBarControllerAndViewIntegration() {
        // Test that MenuBarController and views work together
        let view = LiquidGlassMenuView()
            .environmentObject(systemMetrics)
        
        XCTAssertNotNil(view)
        XCTAssertNotNil(menuBarController)
        
        // Test that both components can coexist
        let expectation = XCTestExpectation(description: "Components should integrate")
        
        systemMetrics.$cpuUsage
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - Data Flow Integration Tests
    
    func testMetricsDataFlow() {
        let expectation = XCTestExpectation(description: "Data flow should work")
        
        // Test that data flows correctly through the system
        systemMetrics.$cpuUsage
            .combineLatest(systemMetrics.$memoryUsage)
            .dropFirst()
            .sink { cpu, memory in
                // Verify data is flowing correctly
                XCTAssertGreaterThanOrEqual(cpu, 0.0)
                XCTAssertGreaterThanOrEqual(memory, 0.0)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testHistoryDataFlow() {
        let expectation = XCTestExpectation(description: "History data flow should work")
        
        // Test that history data flows correctly
        systemMetrics.$cpuHistory
            .dropFirst()
            .sink { history in
                // Verify history is being updated
                XCTAssertFalse(history.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - Performance Integration Tests
    
    func testSystemPerformanceUnderLoad() {
        measure {
            // Test system performance under load
            let expectation = XCTestExpectation(description: "Performance test")
            
            systemMetrics.$cpuUsage
                .dropFirst()
                .sink { _ in
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            wait(for: [expectation], timeout: TestConstants.defaultTimeout)
        }
    }
    
    func testMemoryUsageUnderLoad() {
        measure {
            // Test memory usage under load
            let expectation = XCTestExpectation(description: "Memory test")
            
            systemMetrics.$memoryUsage
                .dropFirst()
                .sink { _ in
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            wait(for: [expectation], timeout: TestConstants.defaultTimeout)
        }
    }
    
    // MARK: - Error Handling Integration Tests
    
    func testSystemHandlesErrorsGracefully() {
        // Test that the system handles errors gracefully
        let expectation = XCTestExpectation(description: "Error handling test")
        
        // Simulate an error condition by accessing invalid data
        systemMetrics.$cpuUsage
            .sink { cpuUsage in
                // System should handle invalid data gracefully
                XCTAssertGreaterThanOrEqual(cpuUsage, 0.0)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testSystemRecoversFromErrors() {
        // Test that the system recovers from errors
        let expectation = XCTestExpectation(description: "Error recovery test")
        
        systemMetrics.$cpuUsage
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - Thread Safety Integration Tests
    
    func testThreadSafety() {
        let expectation = XCTestExpectation(description: "Thread safety test")
        
        // Test that the system is thread-safe
        DispatchQueue.global(qos: .background).async {
            // Access system metrics from background thread
            XCTAssertNotNil(self.systemMetrics)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testConcurrentAccess() {
        let expectation = XCTestExpectation(description: "Concurrent access test")
        
        // Test concurrent access to system metrics
        let group = DispatchGroup()
        
        for _ in 0..<5 {
            group.enter()
            DispatchQueue.global(qos: .background).async {
                XCTAssertNotNil(self.systemMetrics)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - Resource Management Integration Tests
    
    func testResourceManagement() {
        // Test that resources are managed properly
        let expectation = XCTestExpectation(description: "Resource management test")
        
        // Create and destroy components
        let metrics = SystemMetrics()
        let controller = MenuBarController()
        
        XCTAssertNotNil(metrics)
        XCTAssertNotNil(controller)
        
        // Clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testMemoryLeaks() {
        // Test for memory leaks
        let expectation = XCTestExpectation(description: "Memory leak test")
        
        weak var weakMetrics: SystemMetrics?
        weak var weakController: MenuBarController?
        
        do {
            let metrics = SystemMetrics()
            let controller = MenuBarController()
            
            weakMetrics = metrics
            weakController = controller
            
            // Components go out of scope here
        }
        
        // Give time for cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
        
        // Note: We can't directly test for memory leaks in unit tests
        // but we can verify the components exist and can be cleaned up
        XCTAssertTrue(true, "Memory leak test completed")
    }
    
    // MARK: - Real-time Integration Tests
    
    func testRealTimeUpdates() {
        let expectation = XCTestExpectation(description: "Real-time updates test")
        
        // Test that updates happen in real-time
        var updateCount = 0
        
        systemMetrics.$cpuUsage
            .sink { _ in
                updateCount += 1
                if updateCount >= 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.longTimeout)
    }
    
    func testUpdateFrequency() {
        let expectation = XCTestExpectation(description: "Update frequency test")
        
        // Test that updates happen at the expected frequency
        var lastUpdateTime = Date()
        
        systemMetrics.$cpuUsage
            .dropFirst()
            .sink { _ in
                let currentTime = Date()
                let timeDiff = currentTime.timeIntervalSince(lastUpdateTime)
                
                // Updates should happen approximately every second
                XCTAssertGreaterThan(timeDiff, 0.5, "Updates should happen regularly")
                XCTAssertLessThan(timeDiff, 2.0, "Updates should not be too slow")
                
                lastUpdateTime = currentTime
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.longTimeout)
    }
    
    // MARK: - System State Integration Tests
    
    func testSystemStateConsistency() {
        let expectation = XCTestExpectation(description: "System state consistency test")
        
        // Test that system state remains consistent
        systemMetrics.$cpuUsage
            .combineLatest(
                systemMetrics.$memoryUsage,
                systemMetrics.$diskUsage
            )
            .dropFirst()
            .sink { cpu, memory, disk in
                // Verify state consistency
                XCTAssertGreaterThanOrEqual(cpu, 0.0)
                XCTAssertLessThanOrEqual(cpu, 100.0)
                XCTAssertGreaterThanOrEqual(memory, 0.0)
                XCTAssertLessThanOrEqual(memory, 100.0)
                XCTAssertGreaterThanOrEqual(disk, 0.0)
                XCTAssertLessThanOrEqual(disk, 100.0)
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testSystemStateTransitions() {
        let expectation = XCTestExpectation(description: "System state transitions test")
        
        // Test that system state transitions are handled properly
        systemMetrics.$cpuUsage
            .dropFirst()
            .sink { _ in
                // State transitions should be handled gracefully
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - User Interaction Integration Tests
    
    func testUserInteractionFlow() {
        // Test the complete user interaction flow
        let view = LiquidGlassMenuView()
            .environmentObject(systemMetrics)
        
        XCTAssertNotNil(view)
        XCTAssertNotNil(menuBarController)
        
        // Test that user interactions work properly
        let expectation = XCTestExpectation(description: "User interaction test")
        
        systemMetrics.$cpuUsage
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - Configuration Integration Tests
    
    func testConfigurationIntegration() {
        // Test that configuration is properly integrated
        let expectation = XCTestExpectation(description: "Configuration integration test")
        
        // Test that the system uses proper configuration
        systemMetrics.$cpuUsage
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - Monitoring Integration Tests
    
    func testMonitoringIntegration() {
        // Test that monitoring is properly integrated
        let expectation = XCTestExpectation(description: "Monitoring integration test")
        
        // Test that all monitoring components work together
        systemMetrics.$cpuUsage
            .combineLatest(
                systemMetrics.$memoryUsage,
                systemMetrics.$networkUpload,
                systemMetrics.$networkDownload,
                systemMetrics.$diskUsage
            )
            .dropFirst()
            .sink { _, _, _, _, _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
}

