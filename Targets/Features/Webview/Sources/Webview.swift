//
//  Webview.swift
//
//
//  Created by Inumaki on 20.10.23.
//

import Architecture
import ComposableArchitecture
import OSLog
import SwiftSoup
import SwiftUI
import WebKit

// func setCookiesInWebView(cookies: [Cookie], webView: WKWebView) {
// let httpCookies = convertToHTTPCookies(cookies: cookies)
// let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
//
// for cookie in httpCookies {
// cookieStore.setCookie(cookie)
// }
// }
//
// func convertToHTTPCookies(cookies: [Cookie]) -> [HTTPCookie] {
// return cookies.compactMap { cookie in
// let httpCookieProperties: [HTTPCookiePropertyKey: Any] = [
// .name: cookie.name,
// .value: cookie.value,
// .domain: cookie.domain,
// .path: cookie.path,
// .version: cookie.version,
// .expires: cookie.expiresDate ?? Date.distantFuture
// ]
//
// return HTTPCookie(properties: httpCookieProperties)
// }
// }

import Foundation

extension OSLog {
  private static var subsystem = Bundle.main.bundleIdentifier.unsafelyUnwrapped

  /// Creates a custom log category for URLRequest logging.
  static let urlRequest = OSLog(subsystem: subsystem, category: "URLRequest")

  static let webview = OSLog(subsystem: subsystem, category: "Webview")

  static let downloadManager = OSLog(subsystem: subsystem, category: "DownloadManager")
}

extension URLRequest {
  /// Logs the details of the URLRequest including the status code using OSLog.
  func log(response: HTTPURLResponse? = nil) {
    // Get the HTTP method and URL
    let method = httpMethod ?? "N/A"
    let url = url?.absoluteString ?? "N/A"

    // Create a formatted log message
    var logMessage = "URLRequest: [Method: \(method), URL: \(url)]"

    // Include the status code if available
    if let response {
      let statusCode = response.statusCode
      logMessage.append(", Status Code: \(statusCode)")
    }

    // Log the message using OSLog
    os_log("%{public}@", log: OSLog.urlRequest, type: .info, logMessage)
  }
}

// MARK: - RequestOption

public struct RequestOption: Codable, Sendable {
  public let action: String
  public let reqId: String?
  public let url: String?
  public var shouldExit: Bool?
  public let headers: [String: String]?
  public let result: String?
  public let method: String?
  public let body: String?
}

// MARK: - Result

public struct Result: Codable, Sendable {
  public let action: String
  public let result: String
}

// MARK: - WebView

@MainActor
public struct WebView: UIViewRepresentable {
//  // @ObservedObject var viewStore: ViewStore<WebviewDomain.State, WebviewDomain.Action>
//  public var viewStore: ViewStoreOf<WebviewFeature>
  public let store: StoreOf<WebviewFeature>

  var payload: String = ""
  var completionHandler: ((String) -> Void)? // Add completionHandler

  var action: String = "logic"

  public func makeUIView(context: Context) -> WKWebView {
    // inject JS to capture console.log output and send to iOS
    let source = AppConstants.jsLogCode

    let commonCode = AppConstants.commonCode

    let caller = """
    var data = {
        'reqId': -1,
        'action': 'logic',
        'payload': {
            'query': '\(payload)',
            'action': '\(action)'
        }
    };
    try {
        window.onmessage({data: JSON.stringify(data)});
    } catch (error) {
        console.log(error)
    }
    """

    let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    let callerInject = WKUserScript(source: caller, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

    let userContentController = WKUserContentController()
    userContentController.addUserScript(script)
    userContentController.addUserScript(callerInject)

    userContentController.add(context.coordinator, name: "Native")
    userContentController.add(context.coordinator, name: "logHandler")

    let configuration = WKWebViewConfiguration()
    configuration.userContentController = userContentController

    let preferences = WKWebpagePreferences()

    preferences.allowsContentJavaScript = true // Enable JavaScript
    configuration.defaultWebpagePreferences = preferences

    let webView = WKWebView(frame: .zero, configuration: configuration)

    // let cookies = globalData.getCookies()
    //
    // if cookies != nil {
    // setCookiesInWebView(cookies: cookies!.cookies, webView: webView)
    // }
    webView.navigationDelegate = context.coordinator

    print(commonCode)

    webView.loadHTMLString("<script>" + commonCode + store.javaScript + "</script>", baseURL: URL(string: "http://localhost/").unsafelyUnwrapped)

    context.coordinator.webView = webView

    print("Webview created.")
    return webView
  }

  public func updateUIView(_: WKWebView, context _: Context) {}

  public func makeCoordinator() -> Coordinator {
    Coordinator(
      javaScript: store.javaScript,
      requestType: store.requestType,
      store: store,
      completionHandler: completionHandler
    )
  }

  public class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    let javaScript: String
    let requestType: String
    let store: StoreOf<WebviewFeature>
    var webView: WKWebView? // Store the WKWebView reference here
    var completionHandler: ((String) -> Void)? // Add completionHandler

    // @Dependency(\.globalData) var globalData

    public init(javaScript: String, requestType: String, store: StoreOf<WebviewFeature>, completionHandler: ((String) -> Void)?) {
      self.javaScript = javaScript
      self.requestType = requestType
      self.store = store
      self.webView = nil
      self.completionHandler = completionHandler
    }

    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
      if message.name == "Native" {
        if let body = message.body as? String {
          sendHttpRequest(data: body)
        }
      } else if message.name == "logHandler" {
        if let message = message.body as? String {
          // let data = message.data(using: .utf8)
          // let decoder = JSONDecoder()

          os_log("%{public}@", log: OSLog.webview, type: .error, message)

          // do {
          // if data != nil {
          // var consoleData = try decoder.decode(ConsoleData.self, from: data!)
          // let module = globalData.getModule()
          // consoleData.moduleName = module?.name ?? ""
          // consoleData.moduleIconPath = module?.icon ?? ""
          // print("LOG: \(consoleData.msg)")
          // viewStore.send(.appendGlobalLog(item: consoleData))
          // }
          // } catch {
          // error.log(logger: OSLog.webview)
          // let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
          // NotificationCenter.default
          // .post(name:           NSNotification.Name("floaty"),
          // object: nil, userInfo: data)
          // }
        }
      }
    }

    public func sendHttpRequest(data: String) {
      if webView != nil {
        postMessage(message: data)
      } else {
        os_log("%{public}@", log: OSLog.webview, type: .error, "WKWebView reference is nil")
      }
    }

    public func request(
      url: URL,
      headers: [String: String],
      method: String? = "GET",
      body: String? = nil,
      completionHandler: @escaping (String?, Error?) -> Void
    ) async throws {
      URLSession.shared.configuration.httpCookieStorage = HTTPCookieStorage.shared
      URLSession.shared.configuration.httpShouldSetCookies = true
      URLSession.shared.configuration.httpShouldUsePipelining = true

      var request = URLRequest(url: url)
      request.httpMethod = method

      let webviewCookies = HTTPCookieStorage.shared.cookies(for: url)

      let cookieStorage = HTTPCookieStorage.shared
      for cookie in webviewCookies ?? [] {
        cookieStorage.setCookie(cookie)
      }

      let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookieStorage.cookies(for: url).unsafelyUnwrapped)

      request.allHTTPHeaderFields = cookieHeaders

      let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS VERSION like Mac OS X) AppleWebKit/WEBKIT_VERSION (KHTML, like Gecko) Mobile/USER_AGENT_APP_NAME"
      request.setValue(userAgent, forHTTPHeaderField: "user-agent")

      for (key, value) in headers {
        request.setValue(value, forHTTPHeaderField: key)
      }

      if let body {
        request.httpBody = body.data(using: .utf8)
      }

      let (data, response) = try await URLSession.shared.data(for: request)

      let responseData = unsafeDowncast(response, to: HTTPURLResponse.self)
      let status = responseData.statusCode

      if let httpResponse = response as? HTTPURLResponse {
        request.log(response: httpResponse)
      }

      if status == 403 {
        // CF hit
        print("cf")
        // self.globalData.setCfUrl(url.absoluteString)
        // self.globalData.setShowOverlay(true)
        // DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
        // Task {
        // do {
        // try await self.request(url: url, headers: headers, method: "POST", body: body, completionHandler: completionHandler)
        // } catch {
        // print(error.localizedDescription)
        // }
        // }
        // }
        completionHandler(nil, NSError(domain: "", code: -1, userInfo: nil))
      }

      if status == 200, let mimeType = response.mimeType, mimeType == "text/html" {
        if let htmlString = String(data: data, encoding: .utf8) {
          do {
            let doc: Document = try SwiftSoup.parse(htmlString)
            if let metaRefresh = try doc.select("meta[http-equiv=refresh]").first(),
               let content = try? metaRefresh.attr("content"),
               let urlRange = content.range(of: "url=") {
              let redirectURL = String(content[urlRange.upperBound...])

              if let redirect = URL(string: redirectURL) {
                // Handle the redirect by making another request
                try await self.request(url: redirect, headers: headers, completionHandler: completionHandler)
                return
              }
            }
          } catch {
            print("Error parsing HTML: \(error)")
            completionHandler(nil, error)
            return
          }
        }
      }

      if let responseString = String(data: data, encoding: .utf8) {
        completionHandler(responseString, nil)
      } else {
        completionHandler(nil, NSError(domain: "", code: -1, userInfo: nil))
      }
    }

    public func postMessage(message: String) {
      if let jsonData = message.data(using: .utf8) {
        do {
          let req = try JSONDecoder().decode(RequestOption.self, from: jsonData)

          if req.action == "HTTPRequest", req.url != nil, req.headers != nil {
            Task {
              do {
                try await request(
                  url: req.url.flatMap { .init(string: $0) }.unsafelyUnwrapped,
                  headers: req.headers.unsafelyUnwrapped,
                  method: req.method,
                  body: req.body
                ) { responseString, error in
                  if let error {
                    // error.log(logger: OSLog.webview)
                  } else if let responseString {
                    let resp = [
                      "reqId": req.reqId,
                      "responseText": responseString
                    ]
                    do {
                      let jsonData = try JSONSerialization.data(withJSONObject: resp, options: [])

                      if let jsonString = String(data: jsonData, encoding: .utf8) {
                        if let webView = self.webView {
                          DispatchQueue.main.async {
                            webView.evaluateJavaScript(
                              """
                              window.onmessage({data: JSON.stringify(\(jsonString))});
                              """
                            )
                          }
                        }
                      } else {
                        os_log("%{public}@", log: OSLog.webview, type: .error, "Error converting JSON data to string")
                      }
                    } catch {
                      os_log("%{public}@", log: OSLog.webview, type: .error, "Error converting dictionary to JSON: \(error)")
                    }
                  }
                }
              } catch {
                print(error.localizedDescription)
              }
            }
          } else if req.action == "result", req.result != nil {
            parseResult(body: req.result ?? "")
            // this.callback(req.result)
          } else if req.action == "error" {
            /// withContext(Dispatchers.Main) {
            // self.destroy();
            // }

            // throw Exception(req.result);
          } else {
            // throw Exception("Action not found.");
          }
        } catch {
          os_log("%{public}@", log: OSLog.webview, type: .error, "Error decoding JSON: \(error)")
        }
      }
    }

    public func parseResult(body: String) {
      if let jsonData = body.data(using: .utf8) {
        do {
          let decoder = JSONDecoder()
          let requestOption = try decoder.decode(RequestOption.self, from: jsonData)

          // print(requestOption.result)
          if let resultString = requestOption.result?.data(using: .utf8) {
            do {
              let decoder = JSONDecoder()
              let result = try decoder.decode(Result.self, from: resultString)

              completionHandler?(result.result)
            } catch {
              print("Error decoding JSON LOOOOL:", error)
              completionHandler?(requestOption.result ?? "")
            }
          }
        } catch {
          print("Error decoding JSON HMMMM:", error)
        }
      } else {
        print("Invalid JSON string")
      }
    }
  }
}
