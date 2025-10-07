import XCTest
@testable import SystemMonitor

final class BasicTests: XCTestCase {
    func testBasicFunctionality() {
        // Basic test to verify XCTest is working
        XCTAssertTrue(true, "Basic test should pass")
    }
    
    func testSystemMetricsExists() {
        // Test that SystemMetrics class exists and can be instantiated
        let metrics = SystemMetrics()
        XCTAssertNotNil(metrics)
    }
    
    func testNetworkStatsStructure() {
        // Test that NetworkStats structure exists
        let stats = NetworkStats(bytesIn: 1000, bytesOut: 2000)
        XCTAssertEqual(stats.bytesIn, 1000)
        XCTAssertEqual(stats.bytesOut, 2000)
    }
}

