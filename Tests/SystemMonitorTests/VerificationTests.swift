import Foundation
@testable import SystemMonitor

// Simple verification tests that don't require XCTest
// These can be run as a standalone Swift script

func runVerificationTests() {
    print("🧪 SystemMonitor Verification Tests")
    print("==================================")
    
    var passedTests = 0
    var totalTests = 0
    
    func assert(_ condition: Bool, _ message: String) {
        totalTests += 1
        if condition {
            print("✅ \(message)")
            passedTests += 1
        } else {
            print("❌ \(message)")
        }
    }
    
    // Test 1: SystemMetrics initialization
    do {
        let metrics = SystemMetrics()
        assert(metrics != nil, "SystemMetrics should initialize successfully")
        assert(metrics.cpuUsage >= 0.0, "CPU usage should be non-negative")
        assert(metrics.memoryUsage >= 0.0, "Memory usage should be non-negative")
        assert(metrics.diskUsage >= 0.0, "Disk usage should be non-negative")
    }
    
    // Test 2: NetworkStats structure
    do {
        let stats = NetworkStats(bytesIn: 1000, bytesOut: 2000)
        assert(stats.bytesIn == 1000, "NetworkStats bytesIn should be correct")
        assert(stats.bytesOut == 2000, "NetworkStats bytesOut should be correct")
    }
    
    // Test 3: Formatting functions
    do {
        let metrics = SystemMetrics()
        let formattedBytes = metrics.formatBytes(1024 * 1024) // 1 MB
        assert(!formattedBytes.isEmpty, "formatBytes should return non-empty string")
        
        let formattedPercentage = metrics.formatPercentage(25.5)
        assert(formattedPercentage == "25.5%", "formatPercentage should format correctly")
        
        let formattedBytesPerSecond = metrics.formatBytesPerSecond(1024 * 1024)
        assert(!formattedBytesPerSecond.isEmpty, "formatBytesPerSecond should return non-empty string")
    }
    
    // Test 4: History arrays initialization
    do {
        let metrics = SystemMetrics()
        assert(metrics.cpuHistory.isEmpty, "CPU history should be empty initially")
        assert(metrics.memoryHistory.isEmpty, "Memory history should be empty initially")
        assert(metrics.networkUploadHistory.isEmpty, "Network upload history should be empty initially")
        assert(metrics.networkDownloadHistory.isEmpty, "Network download history should be empty initially")
    }
    
    // Test 5: Value ranges
    do {
        let metrics = SystemMetrics()
        assert(metrics.cpuUsage <= 100.0, "CPU usage should not exceed 100%")
        assert(metrics.memoryUsage <= 100.0, "Memory usage should not exceed 100%")
        assert(metrics.diskUsage <= 100.0, "Disk usage should not exceed 100%")
        assert(metrics.networkUpload >= 0.0, "Network upload should be non-negative")
        assert(metrics.networkDownload >= 0.0, "Network download should be non-negative")
    }
    
    // Test 6: Memory consistency
    do {
        let metrics = SystemMetrics()
        assert(metrics.memoryUsed >= 0, "Memory used should be non-negative")
        assert(metrics.memoryTotal > 0, "Total memory should be positive")
        assert(metrics.memoryUsed <= metrics.memoryTotal, "Used memory should not exceed total")
    }
    
    // Test 7: Disk consistency
    do {
        let metrics = SystemMetrics()
        assert(metrics.diskUsed >= 0, "Disk used should be non-negative")
        assert(metrics.diskTotal > 0, "Total disk space should be positive")
        assert(metrics.diskUsed <= metrics.diskTotal, "Used disk space should not exceed total")
    }
    
    print("")
    print("📊 Test Results: \(passedTests)/\(totalTests) tests passed")
    
    if passedTests == totalTests {
        print("🎉 All verification tests passed!")
        exit(0)
    } else {
        print("❌ Some tests failed. Please review the output above.")
        exit(1)
    }
}

// Run the tests
runVerificationTests()
