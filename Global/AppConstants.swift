//
//  Constants.swift
//  ChoutenTCA
//
//  Created by Inumaki on 08.10.23.
//

import Foundation

struct AppConstants {
    static var commonCode: String = ""
    static let jsLogCode = """
        function captureLog(msg) {
            const date = new Date();
            window.webkit.messageHandlers.logHandler.postMessage(
                JSON.stringify({
                    time: `${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`,
                    msg: msg,
                    type: "log",
                    moduleName: "Zoro",
                    moduleIconPath: "",
                })
            );
        }
        window.console.log = captureLog;
        function captureError(msg) {
            const date = new Date();
            window.webkit.messageHandlers.logHandler.postMessage(
                JSON.stringify({
                    time: `${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`,
                    msg: msg.split("-----")[0],
                    type: "error",
                    moduleName: "Zoro",
                    moduleIconPath: "",
                    lines: msg.split("-----")[1]
                })
            );
        }
        window.console.error = captureError;
        """
}
