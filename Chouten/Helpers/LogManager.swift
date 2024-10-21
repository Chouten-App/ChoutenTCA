//
//  LogType.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//


import Foundation

enum LogType {
    case info
    case warning
    case error
}

struct Log {
    var type: LogType
    var title: String
    var description: String
    var line: String
    var time: Date
}

class LogManager {
    static let shared = LogManager()

    private var logs: [Log] = []

    private init() {}

    func log(_ title: String, description: String, type: LogType = .info, line: String) {
        let log = Log(type: type, title: title, description: description, line: line, time: Date.now)
        logs.append(log)
    }

    func getLogs() -> [Log] {
        return logs
    }
}
