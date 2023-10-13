//
//  Webview.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import SwiftUI
import WebKit
import SwiftyJSON
import ComposableArchitecture
import OSLog
import SwiftUISnackbar

func setCookiesInWebView(cookies: [Cookie], webView: WKWebView) {
    let httpCookies = convertToHTTPCookies(cookies: cookies)
    let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
    
    for cookie in httpCookies {
        cookieStore.setCookie(cookie)
    }
}

func convertToHTTPCookies(cookies: [Cookie]) -> [HTTPCookie] {
    return cookies.compactMap { cookie in
        let httpCookieProperties: [HTTPCookiePropertyKey: Any] = [
            .name: cookie.name,
            .value: cookie.value,
            .domain: cookie.domain,
            .path: cookie.path,
            .version: cookie.version,
            .expires: cookie.expiresDate ?? Date.distantFuture
        ]
        
        return HTTPCookie(properties: httpCookieProperties)
    }
}


struct RequestOption: Codable {
    let action: String;
    let reqId: String?;
    let url: String?;
    var shouldExit: Bool?;
    let headers: Dictionary<String, String>?;
    let result: String?;
    let method: String?;
    let body: String?;
}

struct Result: Codable {
    let action: String;
    let result: String;
}

struct WebView: UIViewRepresentable {
    @ObservedObject var viewStore: ViewStore<WebviewDomain.State, WebviewDomain.Action>
    
    var payload: String = ""
    var action: String = "logic"
    var completionHandler: ((String) -> Void)? // Add completionHandler
    
    @Dependency(\.globalData) var globalData
    @StateObject var store = SnackbarStore()
    
    func makeUIView(context: Context) -> WKWebView {
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
        
        let cookies = globalData.getCookies()
        
        if cookies != nil {
            setCookiesInWebView(cookies: cookies!.cookies, webView: webView)
        }
        
        webView.navigationDelegate = context.coordinator
        
        webView.loadHTMLString("<script>" + commonCode + viewStore.javaScript + "</script>", baseURL: URL(string: "http://localhost/")!)
        
        webView.loadHTMLString("<script>" + commonCode + viewStore.javaScript + "</script>", baseURL: URL(string: "http://localhost/")!)
        
        context.coordinator.webView = webView
        
        print("Webview created.")
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            javaScript: viewStore.javaScript,
            requestType: viewStore.requestType,
            nextUrl: viewStore.binding(
                get: \.nextUrl,
                send: WebviewDomain.Action.setNextUrl(newUrl:)
            ),
            viewStore: viewStore,
            completionHandler: completionHandler
        )
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let javaScript: String
        let requestType: String
        @Binding var nextUrl: String
        let viewStore: ViewStoreOf<WebviewDomain>
        var webView: WKWebView? // Store the WKWebView reference here
        var completionHandler: ((String) -> Void)? // Add completionHandler
        
        @Dependency(\.globalData) var globalData
        
        init(javaScript: String, requestType: String, nextUrl: Binding<String>, viewStore: ViewStoreOf<WebviewDomain>, completionHandler: ((String) -> Void)?) {
            self.javaScript = javaScript
            self.requestType = requestType
            self._nextUrl = nextUrl
            self.viewStore = viewStore
            self.webView = nil
            self.completionHandler = completionHandler
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("CALLED: \(message.name)")
            
            if message.name == "Native" {
                if let body = message.body as? String {
                    sendHttpRequest(data: body)
                }
            }
            else if message.name == "logHandler" {
                
                if let message = message.body as? String {
                    let data = message.data(using: .utf8)
                    let decoder = JSONDecoder()
                    do {
                        if data != nil {
                            var consoleData = try decoder.decode(ConsoleData.self, from: data!)
                            let module = globalData.getModule()
                            consoleData.moduleName = module?.name ?? ""
                            consoleData.moduleIconPath = module?.icon ?? ""
                            print("LOG: \(consoleData.msg)")
                            viewStore.send(.appendGlobalLog(item: consoleData))
                        }
                    } catch {
                        error.log(logger: OSLog.webview)
                        let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                        NotificationCenter.default
                            .post(name:           NSNotification.Name("floaty"),
                                  object: nil, userInfo: data)
                    }
                }
            }
        }
        
        func sendHttpRequest(data: String) {
            if webView != nil {
                postMessage(message: data)
            } else {
                os_log("%{public}@", log: OSLog.webview, type: .error, "WKWebView reference is nil")
            }
        }
        
        func request(
            url: URL,
            headers: [String: String],
            method: String? = "GET",
            body: String? = nil,
            completionHandler: @escaping (String?, Error?) -> Void
        ) async throws {
            URLSession.shared.configuration.httpCookieStorage = HTTPCookieStorage.shared
            
            var request = URLRequest(url: url)
            request.httpMethod = method
            
            let webviewCookies = HTTPCookieStorage.shared.cookies(for: url)
            
            let cookieStorage = HTTPCookieStorage.shared
            for cookie in webviewCookies ?? [] {
                cookieStorage.setCookie(cookie)
            }
            
            let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookieStorage.cookies(for: url)!)
            
            request.allHTTPHeaderFields = cookieHeaders
            
            let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS VERSION like Mac OS X) AppleWebKit/WEBKIT_VERSION (KHTML, like Gecko) Mobile/USER_AGENT_APP_NAME"
            request.setValue(userAgent, forHTTPHeaderField: "user-agent")
            
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            if let body = body {
                request.httpBody = body.data(using: .utf8)
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            let responseData = response as! HTTPURLResponse
            let status = responseData.statusCode
            
            
            if let httpResponse = response as? HTTPURLResponse {
                request.log(response: httpResponse)
            }
            
            if status == 403 {
                // CF hit
                print("cf")
                self.globalData.setCfUrl(url.absoluteString)
                self.globalData.setShowOverlay(true)
                
                /*
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    Task {
                        do {
                            try await self.request(url: url, headers: headers, method: "POST", body: body, completionHandler: completionHandler)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                */
                completionHandler(nil, NSError(domain: "", code: -1, userInfo: nil))
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                completionHandler(responseString, nil)
            } else {
                completionHandler(nil, NSError(domain: "", code: -1, userInfo: nil))
            }
        }
        
        func postMessage(message: String) {
            if let jsonData = message.data(using: .utf8) {
                do {
                    let req = try JSONDecoder().decode(RequestOption.self, from: jsonData)
                    
                    if(req.action == "HTTPRequest" && req.url != nil && req.headers != nil){
                        Task {
                            do {
                                try await request(url: URL(string: req.url!)!, headers: req.headers!, method: req.method, body: req.body) { responseString, error in
                                    if let error = error {
                                        error.log(logger: OSLog.webview)
                                    } else if let responseString = responseString {
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
                    }else if(req.action == "result" && req.result != nil){
                        parseResult(body: req.result ?? "")
                        //this.callback(req.result)
                    }else if(req.action == "error"){
                        /*withContext(Dispatchers.Main) {
                         self.destroy();
                         }*/
                        
                        //throw Exception(req.result);
                    }else{
                        //throw Exception("Action not found.");
                    }
                } catch {
                    os_log("%{public}@", log: OSLog.webview, type: .error, "Error decoding JSON: \(error)")
                }
            }
        }
        
        func parseResult(body: String) {
            print("parsing")
            if let jsonData = body.data(using: .utf8) {
                do {
                    let decoder = JSONDecoder()
                    let requestOption = try decoder.decode(RequestOption.self, from: jsonData)
                    
                    //print(requestOption.result)
                    if let resultString = requestOption.result?.data(using: .utf8) {
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(Result.self, from: resultString)
                            
                            self.completionHandler?(result.result)
                        } catch {
                            print("Error decoding JSON LOOOOL:", error)
                            self.completionHandler?(requestOption.result ?? "")
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

struct Webview_Previews: PreviewProvider {
    static var previews: some View {
        WebView(
            viewStore: ViewStore(
                Store(
                    initialState: WebviewDomain.State(),
                    reducer: WebviewDomain()
                )
            )
        )
    }
}
