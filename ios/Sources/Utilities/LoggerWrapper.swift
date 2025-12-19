//
//  LoggerWrapper.swift
//  MyApp
//
//  Debug-aware logging wrapper using os.Logger.
//

import Foundation
import os

/// Debug-aware logger that conditionally logs based on build configuration
struct DebugLogger {
    private let logger: Logger
    private let category: String

    init(subsystem: String, category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.category = category
    }

    func info(_ message: String) {
        #if DEBUG
        logger.info("\(message)")
        #endif
    }

    func debug(_ message: String) {
        #if DEBUG
        logger.debug("\(message)")
        #endif
    }

    func warning(_ message: String) {
        // Always log warnings
        logger.warning("\(message)")
    }

    func error(_ message: String) {
        // Always log errors
        logger.error("\(message)")
    }
}

/// Property wrapper for easy logger initialization
@propertyWrapper
struct LoggerWrapper {
    let wrappedValue: DebugLogger

    init(category: String) {
        self.wrappedValue = DebugLogger(
            subsystem: Bundle.main.bundleIdentifier ?? "com.myapp",
            category: category
        )
    }
}

/// Global debug print function that only prints in DEBUG builds
func debugPrint(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}
