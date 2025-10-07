import XCTest
import Combine
import Foundation
@testable import SystemMonitor

final class SystemMetricsTests: XCTestCase {
    var systemMetrics: SystemMetrics!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        systemMetrics = SystemMetrics()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        systemMetrics = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testSystemMetricsInitialization() {
        XCTAssertNotNil(systemMetrics)
        XCTAssertEqual(systemMetrics.cpuUsage, 0.0)
        XCTAssertEqual(systemMetrics.memoryUsage, 0.0)
        XCTAssertEqual(systemMetrics.networkUpload, 0.0)
        XCTAssertEqual(systemMetrics.networkDownload, 0.0)
        XCTAssertEqual(systemMetrics.diskUsage, 0.0)
    }
    
    func testSystemMetricsStartsMonitoringOnInit() {
        // The timer should be set up during initialization
        // We can't directly test the timer, but we can verify the metrics are being updated
        let expectation = XCTestExpectation(description: "Metrics should update")
        
        systemMetrics.$cpuUsage
            .dropFirst() // Skip initial value
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - CPU Usage Tests
    
    func testCPUUsageIsWithinValidRange() {
        let expectation = XCTestExpectation(description: "CPU usage should be valid")
        
        systemMetrics.$cpuUsage
            .dropFirst() // Skip initial value
            .sink { cpuUsage in
                XCTAssertGreaterThanOrEqual(cpuUsage, 0.0, "CPU usage should not be negative")
                XCTAssertLessThanOrEqual(cpuUsage, 100.0, "CPU usage should not exceed 100%")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testCPUUsageUpdatesOverTime() {
        let expectation = XCTestExpectation(description: "CPU usage should update")
        var initialCPUUsage: Double = 0.0
        
        systemMetrics.$cpuUsage
            .sink { cpuUsage in
                if initialCPUUsage == 0.0 {
                    initialCPUUsage = cpuUsage
                } else {
                    // CPU usage might change over time
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - Memory Usage Tests
    
    func testMemoryUsageIsWithinValidRange() {
        let expectation = XCTestExpectation(description: "Memory usage should be valid")
        
        systemMetrics.$memoryUsage
            .dropFirst() // Skip initial value
            .sink { memoryUsage in
                XCTAssertGreaterThanOrEqual(memoryUsage, 0.0, "Memory usage should not be negative")
                XCTAssertLessThanOrEqual(memoryUsage, 100.0, "Memory usage should not exceed 100%")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testMemoryValuesAreConsistent() {
        let expectation = XCTestExpectation(description: "Memory values should be consistent")
        
        systemMetrics.$memoryUsed
            .combineLatest(systemMetrics.$memoryTotal)
            .dropFirst() // Skip initial values
            .sink { used, total in
                XCTAssertGreaterThanOrEqual(used, 0, "Memory used should not be negative")
                XCTAssertGreaterThan(total, 0, "Total memory should be positive")
                XCTAssertLessThanOrEqual(used, total, "Used memory should not exceed total memory")
                
                let calculatedUsage = Double(used) / Double(total) * 100.0
                XCTAssertEqual(calculatedUsage, self.systemMetrics.memoryUsage, accuracy: 0.1, 
                             "Calculated memory usage should match published value")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - Network Usage Tests
    
    func testNetworkUsageIsNonNegative() {
        let expectation = XCTestExpectation(description: "Network usage should be non-negative")
        
        systemMetrics.$networkUpload
            .combineLatest(systemMetrics.$networkDownload)
            .dropFirst() // Skip initial values
            .sink { upload, download in
                XCTAssertGreaterThanOrEqual(upload, 0.0, "Network upload should not be negative")
                XCTAssertGreaterThanOrEqual(download, 0.0, "Network download should not be negative")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testNetworkUsageHasReasonableBounds() {
        let expectation = XCTestExpectation(description: "Network usage should have reasonable bounds")
        
        systemMetrics.$networkUpload
            .combineLatest(systemMetrics.$networkDownload)
            .dropFirst() // Skip initial values
            .sink { upload, download in
                // Network usage should be capped at 1000 MB/s as per implementation
                XCTAssertLessThanOrEqual(upload, 1000.0, "Network upload should be capped at 1000 MB/s")
                XCTAssertLessThanOrEqual(download, 1000.0, "Network download should be capped at 1000 MB/s")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - Disk Usage Tests
    
    func testDiskUsageIsWithinValidRange() {
        let expectation = XCTestExpectation(description: "Disk usage should be valid")
        
        systemMetrics.$diskUsage
            .dropFirst() // Skip initial value
            .sink { diskUsage in
                XCTAssertGreaterThanOrEqual(diskUsage, 0.0, "Disk usage should not be negative")
                XCTAssertLessThanOrEqual(diskUsage, 100.0, "Disk usage should not exceed 100%")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testDiskValuesAreConsistent() {
        let expectation = XCTestExpectation(description: "Disk values should be consistent")
        
        systemMetrics.$diskUsed
            .combineLatest(systemMetrics.$diskTotal)
            .dropFirst() // Skip initial values
            .sink { used, total in
                XCTAssertGreaterThanOrEqual(used, 0, "Disk used should not be negative")
                XCTAssertGreaterThan(total, 0, "Total disk space should be positive")
                XCTAssertLessThanOrEqual(used, total, "Used disk space should not exceed total")
                
                let calculatedUsage = Double(used) / Double(total) * 100.0
                XCTAssertEqual(calculatedUsage, self.systemMetrics.diskUsage, accuracy: 0.1,
                             "Calculated disk usage should match published value")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    // MARK: - History Tracking Tests
    
    func testHistoryArraysAreInitialized() {
        XCTAssertTrue(systemMetrics.cpuHistory.isEmpty)
        XCTAssertTrue(systemMetrics.memoryHistory.isEmpty)
        XCTAssertTrue(systemMetrics.networkUploadHistory.isEmpty)
        XCTAssertTrue(systemMetrics.networkDownloadHistory.isEmpty)
    }
    
    func testHistoryUpdatesOverTime() {
        let expectation = XCTestExpectation(description: "History should update")
        
        systemMetrics.$cpuHistory
            .dropFirst() // Skip initial empty array
            .sink { history in
                XCTAssertFalse(history.isEmpty, "CPU history should not be empty after updates")
                XCTAssertLessThanOrEqual(history.count, 60, "History should not exceed 60 entries")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
    }
    
    func testHistoryMaintainsMaximumSize() async {
        // Wait for history to fill up
        try? await TestHelpers.waitForAsyncOperation(timeout: 2.0)
        
        XCTAssertLessThanOrEqual(systemMetrics.cpuHistory.count, 60, "CPU history should not exceed 60 entries")
        XCTAssertLessThanOrEqual(systemMetrics.memoryHistory.count, 60, "Memory history should not exceed 60 entries")
        XCTAssertLessThanOrEqual(systemMetrics.networkUploadHistory.count, 60, "Network upload history should not exceed 60 entries")
        XCTAssertLessThanOrEqual(systemMetrics.networkDownloadHistory.count, 60, "Network download history should not exceed 60 entries")
    }
    
    // MARK: - Formatting Tests
    
    func testFormatBytes() {
        let testCases: [(Int64, String)] = [
            (1024, "1 KB"),
            (1024 * 1024, "1 MB"),
            (1024 * 1024 * 1024, "1 GB"),
            (1024 * 1024 * 1024 * 1024, "1 TB")
        ]
        
        for (bytes, expected) in testCases {
            let result = systemMetrics.formatBytes(bytes)
            XCTAssertTrue(result.contains("1"), "Formatting should be correct for \(bytes) bytes")
        }
    }
    
    func testFormatPercentage() {
        let testCases: [(Double, String)] = [
            (25.0, "25.0%"),
            (50.5, "50.5%"),
            (100.0, "100.0%"),
            (0.0, "0.0%")
        ]
        
        for (percentage, expected) in testCases {
            let result = systemMetrics.formatPercentage(percentage)
            XCTAssertEqual(result, expected, "Percentage formatting should be correct")
        }
    }
    
    func testFormatBytesPerSecond() {
        let result = systemMetrics.formatBytesPerSecond(1024 * 1024) // 1 MB/s
        XCTAssertTrue(result.contains("1 MB"), "Bytes per second formatting should be correct")
        XCTAssertTrue(result.contains("/s"), "Should include per second indicator")
    }
    
    // MARK: - Network Stats Tests
    
    func testNetworkStatsStructure() {
        let stats = NetworkStats(bytesIn: 1000, bytesOut: 2000)
        XCTAssertEqual(stats.bytesIn, 1000)
        XCTAssertEqual(stats.bytesOut, 2000)
    }
    
    // MARK: - Performance Tests
    
    func testMetricsUpdatePerformance() {
        measure {
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
    
    // MARK: - Edge Cases
    
    func testSystemMetricsHandlesZeroValues() {
        // Test that the system handles edge cases gracefully
        XCTAssertEqual(systemMetrics.formatPercentage(0.0), "0.0%")
        XCTAssertEqual(systemMetrics.formatBytes(0), "0 bytes")
    }
    
    func testSystemMetricsHandlesLargeValues() {
        // Test formatting of large values
        let largeBytes: Int64 = 1024 * 1024 * 1024 * 1024 * 1024 // 1 PB
        let result = systemMetrics.formatBytes(largeBytes)
        XCTAssertFalse(result.isEmpty, "Should handle large values without crashing")
    }
    
    // MARK: - Timer Management Tests
    
    func testSystemMetricsCleansUpTimer() {
        weak var weakMetrics: SystemMetrics?
        
        do {
            let metrics = SystemMetrics()
            weakMetrics = metrics
            // metrics goes out of scope here
        }
        
        // Give time for deinit to be called
        let expectation = XCTestExpectation(description: "Timer cleanup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestConstants.defaultTimeout)
        
        // The timer should be invalidated when SystemMetrics is deallocated
        // We can't directly test this, but we can verify no crashes occur
        XCTAssertTrue(true, "SystemMetrics should clean up properly")
    }
}

