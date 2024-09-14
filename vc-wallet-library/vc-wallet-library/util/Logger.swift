//
//  Logger.swift
//  vc-wallet-library
//
//  Created by 小林弘和 on 2024/09/14.
//

import Foundation

public class Logger {
    
    public static let shared = Logger()
    
    private init() {}
    
    func debug(_ message: String) {
        log(message, level: .debug)
    }
    
    func info(_ message: String) {
        log(message, level: .info)
    }
    
    func warn(_ message: String) {
        log(message, level: .warning)
    }
    
    func error(_ message: String) {
        log(message, level: .error)
    }
    
    
    private func log(_ message: String, level: LogLevel) {
      #if DEBUG
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .long)
        print("[\(timestamp)] [\(level.rawValue)] - \(message)")
      #endif
    }
}

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}
