//
//  Relay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 25.01.24.
//

import Architecture
import JavaScriptCore
import Nuke
import OSLog
import SharedModels
import SwiftUI
import ViewComponents
import WebKit

extension JSContext {
    public func callAsyncFunction(_ key: String) async throws -> JSValue {
        try await withCheckedThrowingContinuation { continuation in
            let onFulfilled: @convention(block) (JSValue) -> Void = { value in
                continuation.resume(returning: value)
            }

            let onRejected: @convention(block) (JSValue) -> Void = { reason in
                let error = NSError(domain: key, code: 0, userInfo: [NSLocalizedDescriptionKey: "\(reason)"])
                continuation.resume(throwing: error)
            }

            let promiseArgs = [unsafeBitCast(onFulfilled, to: JSValue.self), unsafeBitCast(onRejected, to: JSValue.self)]
            self.evaluateScript(key).invokeMethod("then", withArguments: promiseArgs)
//            guard let result = self.evaluateScript(key)?.invokeMethod("then", withArguments: promiseArgs) else {
//                continuation.resume(throwing: NSError(
//                    domain: "JSContextErrorDomain",
//                    code: -1,
//                    userInfo: [NSLocalizedDescriptionKey: "Failed to evaluate script or invoke method."]
//                ))
//                return
//            }
//
//            // Ensure to resume continuation only once
//            continuation.resume(returning: result)
        }
    }
}

extension JSValue {
    static func fromRequestResponse(_ response: Response, in context: JSContext) -> JSValue? {
        // swiftlint:disable force_unwrapping
        let jsValue = JSValue(newObjectIn: context)!
        // swiftlint:enable force_unwrapping

        // Create an instance of the Response class
        jsValue.setValue(response.statusCode, forProperty: "statusCode")
        jsValue.setValue(response.headers, forProperty: "headers")
        jsValue.setValue(response.contentType, forProperty: "contentType")
        jsValue.setValue(response.body, forProperty: "body")

        return jsValue
    }
}

public class Response: Codable {
    public let statusCode: Int
    public let headers: [String: String]
    public let contentType: String
    public let body: String

    public init(statusCode: Int, headers: [String: String], contentType: String, body: String) {
        self.statusCode = statusCode
        self.headers = headers
        self.contentType = contentType
        self.body = body
    }
}

public enum ModuleType {
    case video
    case book
    case text
}

// swiftlint:disable type_body_length
class Relay: ObservableObject {
    let logger = Logger(subsystem: "com.inumaki.Chouten", category: "RelayClient")
    static let shared = Relay()

    var type: ModuleType = .video

    // swiftlint:disable redundant_type_annotation
    var context: JSContext = JSContext()
    // swiftlint:enable redundant_type_annotation

    var cookies: String?

    private init() {
        print("Creating Relay instance")

        registerInContext(context)

        context.exceptionHandler = { _, exception in
            // Handle JavaScript exceptions
            print(exception?.toString() ?? "Unknown error.")
        }
    }

    func checkModuleType() {
        let typeCheckScript = """
        function checkContent() {
            if(typeof instance.sources === 'function' && typeof instance.streams === 'function') { return "video" }
            else if(typeof instance.pages === 'function') { return "book" }
        }
        """
        context.evaluateScript(typeCheckScript)

        let contentType = context.evaluateScript("checkContent()")?.toString()
        let isBook = context.evaluateScript("typeof instance.pages === 'function'")?.toBool()

        switch contentType {
        case "video":
            type = .video
        case "book":
            type = .book
        default:
            type = .video
        }
    }

    func registerInContext(_ context: JSContext) {
        let consoleLog: @convention(block) (String, String, Int, Int) -> Void = { message, url, line, column in
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: date)

            LogManager.shared.log("Log", description: message, line: "\(line):\(column)")

            print("LOG: \(message)")
            print("Time: \(dateString)")
            print("File: \(url)")
            print("Line: \(line)")
            print("Column: \(column)")
        }

        // Define the consoleError block to include error details
        let consoleError: @convention(block) (String, String, Int, Int) -> Void = { message, url, line, column in
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: date)

            LogManager.shared.log("Log", description: message, type: .error, line: "\(line):\(column)")

            DispatchQueue.main.async {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                let window = windowScene?.windows.first

                if let view = window?.rootViewController?.view {
                    view.showErrorDisplay(message: "Relay", description: message, type: .error)
                }
            }

            print("ERROR: \(message)")
            print("Time: \(dateString)")
            print("File: \(url)")
            print("Line: \(line)")
            print("Column: \(column)")
        }

        context.setObject(consoleLog, forKeyedSubscript: "consoleLog" as NSString)
        context.setObject(consoleError, forKeyedSubscript: "consoleError" as NSString)
        context.evaluateScript("""
            function getStackDetails() {
                var error = new Error();
                var stack = error.stack.split("\\n")[2];
                var match = stack.match(/(\\w+\\.js):(\\d+):(\\d+)/);
                if (match) {
                    return {
                        url: match[1],
                        line: parseInt(match[2], 10),
                        column: parseInt(match[3], 10)
                    };
                } else {
                    return {
                        url: "",
                        line: 0,
                        column: 0
                    };
                }
            }

            console.log = function(message) {
                var details = getStackDetails();
                consoleLog(message, details.url, details.line, details.column);
            };

            console.error = function(message) {
                var details = getStackDetails();
                consoleError(message, details.url, details.line, details.column);
            };
        """)

        let sendRequest: @convention(block) (String, String, [String: String], String?) -> JSValue = { url, method, headers, body in
            self.sendRequest(url: url, method: method, headers: headers, body: body)
        }

        context.setObject(sendRequest, forKeyedSubscript: "request" as NSString)

        let callWebview: @convention(block) (String) -> JSValue = { url in
            self.callWebviewJS(url: url)
        }

        context.setObject(callWebview, forKeyedSubscript: "callWebview" as NSString)
    }

    func callWebviewJS(url: String) -> JSValue {
        // swiftlint:disable force_unwrapping
        let context = JSContext.current()!

        let promise = JSValue(newPromiseIn: context) { resolve, reject in
            self.callWebviewInternal(url: url) { value, error in
                if let error = error {
                    reject?.call(withArguments: [error.localizedDescription])
                } else if let response = value {
                    // Convert response to JSValue
                    let jsResponse = self.convertToJSValue(response, in: context, with: url)
                    resolve?.call(withArguments: [jsResponse])
                } else {
                    reject?.call(withArguments: ["Unexpected response format"])
                }
            }
        }

        return promise!
        // swiftlint:enable force_unwrapping
    }

    func convertCookiesToString(cookies: [String: Any]) -> String {
        var cookiesString = ""

        for (key, value) in cookies {
            if let cookieDict = value as? [String: Any],
               let cookieValue = cookieDict["Value"] as? String {
                if !cookiesString.isEmpty {
                    cookiesString += "; "
                }
                cookiesString += "\(key)=\(cookieValue)"
            }
        }

        return cookiesString
    }

    // Function to encapsulate the concatenated cookies string into a dictionary
    func convertCookiesToJSHeaders(cookies: [String: Any]) -> [String: String] {
        let cookiesString = convertCookiesToString(cookies: cookies)
        self.cookies = cookiesString
        return ["Cookie": cookiesString]
    }

    // Helper function to convert [String: Any] with string values to JSValue
    private func convertToJSValue(_ dictionary: [String: Any], in context: JSContext, with url: String) -> JSValue {
        let jsObject = JSValue(newObjectIn: context)

        let converted = convertCookiesToJSHeaders(cookies: dictionary)

        if let hostUrl = URL(string: url) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(converted.first?.value, forKey: "Cookies-\(hostUrl.getDomain() ?? "")")
        }
        for (key, value) in converted {
            jsObject?.setObject(value, forKeyedSubscript: key as NSString)
        }

        // swiftlint:disable force_unwrapping
        return jsObject!
        // swiftlint:enable force_unwrapping
    }

    func callWebviewInternal(url: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        DispatchQueue.main.async {
//            DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + 4) {
//                completion(["HM": "HM"], nil)
//            }
            let scenes = UIApplication.shared.connectedScenes
            guard let windowScene = scenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let navController = window.rootViewController as? UINavigationController else {
//                DispatchQueue.global(qos: .background).async {
//                    completion(nil, NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to find the root view controller"]))
//                }
                return
            }

            let vc = CloudflareWebview(url: url) { value, error in
                DispatchQueue.global(qos: .background).async {
                    completion(value, error)
                    DispatchQueue.main.async {
                        navController.dismiss(animated: true)
                    }
                }
            }

            let popoverController = vc.popoverPresentationController
            popoverController?.sourceView = navController.view
            popoverController?.sourceRect = navController.view.bounds
            popoverController?.permittedArrowDirections = .any

            navController.present(vc, animated: true, completion: nil)
        }
    }

    func sendRequest(url: String, method: String, headers: [String: String] = [:], body: String? = nil) -> JSValue {
        logger.info("""
        ------------
        🌐 URL Request 🌐
        ------------
        Method: \(method)
        URL: \(url)
        Headers: \(headers)
        Body: \(body)
        """)
        // swiftlint:disable force_unwrapping
        let context = JSContext.current()!
        // swiftlint:enable force_unwrapping

        let promiseFunction: @convention(block) (JSValue, JSValue) -> Void = { resolve, reject in
            // Assuming self.sendRequest is a function that performs the network request and calls the completion handler with RequestResponse and an optional Error
            self.sendRequest(url: url, method: method, headers: headers, body: body) { (response: Response?, error: Error?) in
                if let error = error {
                    print("Rejected the promise. Reason: \(error.localizedDescription)")
                    reject.call(withArguments: [error.localizedDescription])
                } else if let response = response {
                    /*
                    self.logger.info("""
                    ------------
                    🌐 URL Response 🌐
                    ------------
                    Status Code: \(response.statusCode)
                    Content-Type: \(response.contentType)
                    Headers: \(response.headers)
                    Response Body: \(response.body)
                    """)
                     */
                    let jsResponse = JSValue.fromRequestResponse(response, in: context)
                    resolve.call(withArguments: [jsResponse as Any])
                }
            }
        }

        let promise = context.objectForKeyedSubscript("Promise").construct(withArguments: [JSValue(object: promiseFunction, in: context) as Any])
        // swiftlint:disable force_unwrapping
        return promise!
        // swiftlint:enable force_unwrapping
    }

    func sendRequest(url: String, method: String, headers: [String: String] = [:], body: String? = nil, completion: @escaping (Response?, RelayError?) -> Void) {
        guard let requestUrl = URL(string: url) else {
            completion(nil, .invalidURL)
            return
        }

        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["User-Agent": AppConstants.userAgent]
        let session = URLSession(configuration: config)

        var request = URLRequest(url: requestUrl)
        request.httpMethod = method

        if method.lowercased() == "post" {
            request.httpBody = body?.data(using: .utf8)
        }

        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }

        if let cookies = UserDefaults.standard.string(forKey: "Cookies-\(requestUrl.getDomain() ?? "")") {
            request.addValue(cookies, forHTTPHeaderField: "Cookie")
        }

        request.addValue(AppConstants.userAgent, forHTTPHeaderField: "User-Agent")

        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // swiftlint:disable force_unwrapping
                print("session error: \(String(describing: error?.localizedDescription))")
                completion(nil, .sessionError(error: error!))
                // swiftlint:enable force_unwrapping
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else { // , 200..<300 ~= httpResponse.statusCode else {
                print("http request failed")
                completion(nil, .httpRequestFailed)
                return
            }

            if let responseData = String(data: data, encoding: .utf8) {
                completion(
                    Response(
                        statusCode: httpResponse.statusCode,
                        headers: [:],
                        contentType: httpResponse.mimeType ?? "",
                        body: responseData
                    ),
                    nil
                )
            } else {
                print("invalid response data")
                completion(nil, .invalidResponseData)
            }
        }.resume()
    }

    func createModuleInstance() {
        // Access the TestModule class from the context
        context.evaluateScript("const instance = new source.default();")

        checkModuleType()
    }

    func resetModule() {
        context = JSContext()

        registerInContext(context)

        context.exceptionHandler = { _, exception in
            // Handle JavaScript exceptions
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            
            if let view = window?.rootViewController?.view {
                view.showErrorDisplay(message: exception?.toString() ?? "")
            }

            print(exception?.toString() ?? "Unknown error.")
        }
    }

    func callAsyncFunction(_ js: String) async throws -> JSValue {
        try await context.callAsyncFunction(js)
    }

    @discardableResult
    func evaluateScript(_ js: String) -> JSValue? {
        context.evaluateScript(js)
    }

    func getDiscover() async -> [DiscoverSection] {
        do {
            let value = try await context.callAsyncFunction("instance.discover()")

            if let listingsArray = value.toArray() as? [[String: Any]] {
                var discoverSections = [DiscoverSection]()

                for listingDict in listingsArray {
                    guard let title = listingDict["title"] as? String,
                          let type = listingDict["type"] as? Int,
                          let dataList = listingDict["data"] as? [[String: Any]] else {
                        continue
                    }

                    var discoverDataList = [DiscoverData]()

                    for dataItem in dataList {
                        if let url = dataItem["url"] as? String,
                           let titles = dataItem["titles"] as? [String: String],
                           let image = dataItem["poster"] as? String,
                           let subtitle = dataItem["description"] as? String,
                           let indicator = dataItem["indicator"] as? String,
                           let primaryTitle = titles["primary"] {

                            let titlesValue = Titles(primary: primaryTitle, secondary: titles["secondary"])
                            let iconText = dataItem["iconText"] as? String
                            let current = dataItem["current"] as? Int
                            let total = dataItem["total"] as? Int

                            let discoverData = DiscoverData(
                                url: url,
                                titles: titlesValue,
                                description: subtitle,
                                poster: image,
                                label: Label(text: iconText ?? "", color: ""),
                                indicator: indicator,
                                current: current,
                                total: total
                            )
                            discoverDataList.append(discoverData)
                        }
                    }

                    let discoverSection = DiscoverSection(title: title, type: type, list: discoverDataList)
                    discoverSections.append(discoverSection)
                }

                return discoverSections
            } else {
                print("Failed to get 'listings' array from JavaScript response.")
            }
        } catch {
            let scenes = await UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = await windowScene?.windows.first

            if let view = await window?.rootViewController?.view {
                await view.showErrorDisplay(message: "Discover", description: error.localizedDescription, type: .error)
            }
            print(error.localizedDescription)
        }
        return []
    }

    func getInfo(url: String) async throws -> InfoData? {
        let response = context.evaluateScript("instance.info('\(url)')")
        let value = try await response?.value()

        if let value {
            if let info = InfoData(jsValue: value) {
                return info
            } else {
                throw "Failed to create Info instance from JSValue."
            }
        }
        return nil
    }
}
// swiftlint:enable type_body_length
