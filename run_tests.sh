#!/bin/bash

# SystemMonitor Test Runner
# This script runs all tests for the SystemMonitor project

set -e

echo "🧪 SystemMonitor Test Suite"
echo "=========================="

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo "❌ Error: Package.swift not found. Please run this script from the SystemMonitor root directory."
    exit 1
fi

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Error: Swift is not installed or not in PATH."
    exit 1
fi

echo "📦 Building SystemMonitor..."
swift build

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please fix build errors before running tests."
    exit 1
fi

echo "✅ Build successful!"

echo ""
echo "🧪 Running tests..."
swift test

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
    echo ""
    echo "📊 Test Summary:"
    echo "   - SystemMetrics Tests: Core functionality and data validation"
    echo "   - MenuBarController Tests: UI controller and menu bar integration"
    echo "   - View Tests: SwiftUI components and user interface"
    echo "   - Integration Tests: End-to-end system functionality"
    echo "   - Mock Utilities: Test helpers and utilities"
    echo ""
    echo "🎉 SystemMonitor is ready for production!"
else
    echo ""
    echo "❌ Some tests failed. Please review the output above."
    exit 1
fi
