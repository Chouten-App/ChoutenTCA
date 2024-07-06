//
//  LogManager.swift
//  Architecture
//
//  Created by Inumaki on 05.07.24.
//

import Foundation

public enum LogType {
    case info
    case warning
    case error
}

public struct Log {
    public var type: LogType
    public var title: String
    public var description: String
    public var line: String
    public var time: Date
}

public class LogManager {
    public static let shared = LogManager()

    private var logs: [Log] = []

    private init() {}

    public func log(_ title: String, description: String, type: LogType = .info, line: String) {
        let log = Log(type: type, title: title, description: description, line: line, time: Date.now)
        logs.append(log)
    }

    public func getLogs() -> [Log] {
        print(logs)
        return logs
    }
}
