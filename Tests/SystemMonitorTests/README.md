# SystemMonitor Test Suite

This directory contains comprehensive tests for the SystemMonitor application, covering all major components and functionality.

## Test Structure

### 📁 Test Files

- **`MockUtilities.swift`** - Mock objects, test helpers, and utilities for isolated testing
- **`SystemMetricsTests.swift`** - Tests for the core SystemMetrics class and data collection
- **`MenuBarControllerTests.swift`** - Tests for the MenuBarController and UI management
- **`ViewTests.swift`** - Tests for SwiftUI views and user interface components
- **`IntegrationTests.swift`** - End-to-end integration tests and system-wide functionality

### 🧪 Test Categories

#### 1. SystemMetrics Tests
- **Initialization**: Proper setup and configuration
- **CPU Usage**: Monitoring and validation of CPU metrics
- **Memory Usage**: Memory monitoring and consistency checks
- **Network Usage**: Network traffic monitoring and bounds checking
- **Disk Usage**: Disk space monitoring and validation
- **History Tracking**: Data history management and size limits
- **Formatting**: Data formatting and display utilities
- **Performance**: Performance under load and resource usage
- **Edge Cases**: Error handling and boundary conditions

#### 2. MenuBarController Tests
- **Initialization**: Proper setup and configuration
- **Status Bar Integration**: Menu bar item creation and management
- **Popover Management**: Popover creation, configuration, and behavior
- **Event Handling**: User interaction and event monitoring
- **System Metrics Integration**: Data binding and updates
- **Memory Management**: Proper cleanup and resource management
- **Thread Safety**: Concurrent access and thread safety
- **Performance**: Initialization and update performance

#### 3. View Tests
- **Component Initialization**: SwiftUI view creation and setup
- **Data Binding**: Integration with SystemMetrics data
- **UI Updates**: Response to data changes and updates
- **Animation**: Animation support and behavior
- **Accessibility**: Accessibility features and support
- **Performance**: View creation and rendering performance
- **Edge Cases**: Handling of extreme values and error conditions
- **Layout**: View layout and composition

#### 4. Integration Tests
- **End-to-End Flow**: Complete system functionality
- **Data Flow**: Data propagation through the system
- **Performance Integration**: System performance under load
- **Error Handling**: System-wide error handling and recovery
- **Thread Safety**: Concurrent access and thread safety
- **Resource Management**: Memory and resource management
- **Real-time Updates**: Live data updates and monitoring
- **System State**: State consistency and transitions

#### 5. Mock Utilities
- **MockSystemMetrics**: Simulated system metrics for testing
- **TestHelpers**: Utility functions and test data creation
- **TestConstants**: Common test values and timeouts
- **TestExpectations**: Async testing utilities and helpers

## Running Tests

### Quick Start
```bash
# Run all tests
./run_tests.sh

# Or run tests directly with Swift
swift test
```

### Individual Test Files
```bash
# Run specific test file
swift test --filter SystemMetricsTests
swift test --filter MenuBarControllerTests
swift test --filter ViewTests
swift test --filter IntegrationTests
```

### Test Coverage
```bash
# Generate test coverage report
swift test --enable-code-coverage
```

## Test Philosophy

### 🎯 Testing Principles
1. **Comprehensive Coverage**: Test all public APIs and critical paths
2. **Isolation**: Use mocks and stubs for isolated testing
3. **Realistic Data**: Use realistic test data and scenarios
4. **Performance**: Include performance tests for critical operations
5. **Edge Cases**: Test boundary conditions and error scenarios
6. **Integration**: Verify components work together correctly

### 🔧 Testing Strategies
- **Unit Tests**: Individual component testing with mocks
- **Integration Tests**: End-to-end functionality testing
- **Performance Tests**: Load and performance validation
- **Async Tests**: Proper handling of asynchronous operations
- **Error Tests**: Error handling and recovery validation

## Mock Data

### SystemMetrics Mock Data
```swift
// Default mock data
cpu: 25.0%
memory: 60.0% (8GB used of 16GB total)
network: 5.5 MB/s upload, 12.3 MB/s download
disk: 45.0% (500GB used of 1TB total)

// High load scenario
cpu: 85.0%
memory: 90.0%
network: 50.0 MB/s upload, 100.0 MB/s download
disk: 95.0%

// Low load scenario
cpu: 5.0%
memory: 20.0%
network: 0.1 MB/s upload, 0.5 MB/s download
disk: 10.0%
```

### Test Constants
```swift
// Timeouts
defaultTimeout: 1.0 seconds
longTimeout: 5.0 seconds
shortTimeout: 0.1 seconds

// Mock values
mockCPUUsage: 25.0%
mockMemoryUsage: 60.0%
mockNetworkUpload: 5.5 MB/s
mockNetworkDownload: 12.3 MB/s
mockDiskUsage: 45.0%
```

## Best Practices

### ✅ Do's
- Use descriptive test names that explain what is being tested
- Test both happy path and error scenarios
- Use mocks for external dependencies
- Include performance tests for critical operations
- Test edge cases and boundary conditions
- Use async testing utilities for asynchronous operations
- Clean up resources in tearDown methods

### ❌ Don'ts
- Don't test implementation details, test behavior
- Don't rely on external systems in unit tests
- Don't ignore test failures or warnings
- Don't create tests that are too complex or hard to understand
- Don't skip error handling tests
- Don't use real system resources in tests

## Troubleshooting

### Common Issues
1. **Test Timeouts**: Increase timeout values for slow operations
2. **Mock Data**: Ensure mock data is properly configured
3. **Async Operations**: Use proper async testing utilities
4. **Memory Leaks**: Check for proper cleanup in tearDown methods
5. **Thread Safety**: Test concurrent access scenarios

### Debug Tips
- Use `print()` statements for debugging test execution
- Check test output for detailed error messages
- Use Xcode's test navigator for interactive debugging
- Verify mock data is being used correctly
- Check for proper resource cleanup

## Contributing

When adding new tests:
1. Follow the existing test structure and naming conventions
2. Add appropriate mock data and test helpers
3. Include both positive and negative test cases
4. Add performance tests for new functionality
5. Update this README if adding new test categories

## Test Metrics

The test suite provides comprehensive coverage of:
- **Core Functionality**: SystemMetrics data collection and processing
- **User Interface**: SwiftUI views and user interactions
- **System Integration**: Menu bar integration and system APIs
- **Performance**: Resource usage and efficiency
- **Error Handling**: Graceful handling of errors and edge cases
- **Real-time Updates**: Live data monitoring and updates

This ensures SystemMonitor is robust, reliable, and ready for production use.
