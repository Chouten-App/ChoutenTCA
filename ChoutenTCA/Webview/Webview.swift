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
    let reqId: String;
    let url: String?;
    var shouldExit: Bool?;
    let headers: Dictionary<String, String>?;
    let result: String?;
}

struct WebView: UIViewRepresentable {
    @ObservedObject var viewStore: ViewStore<WebviewDomain.State, WebviewDomain.Action>
    
    @Dependency(\.globalData) var globalData
    
    func makeUIView(context: Context) -> WKWebView {
        // inject JS to capture console.log output and send to iOS
        let source = """
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
        
        let commonCode = """
            let reqId = 0;
            let resolveFunctions = {};
            
            const Native = {};
            Native.sendHttpRequest = window.webkit.messageHandlers.Native.postMessage;

            window.onmessage = async function (event) {
                console.log("Test")
                const data = JSON.parse(event.data);
                let payload = {};

                try{
                    payload = JSON.parse(data.payload);
                }catch(err){
                    payload = data.payload;
                }

                if (data.action === "logic"){
                    try{
                        if(payload.action === "eplist"){
                            await getEpList(payload);
                        }else if(payload.action === "video"){
                            await getSource(payload);
                        }else{
                            await logic(payload);
                        }
                    }catch(err){
                        console.error(err);
                        sendSignal(1, err.toString());
                    }
                }else{
                    resolveFunctions[data.reqId](data.responseText);
                }
            }

            function sendRequest(url, headers) {
                return new Promise((resolve, reject) => {
                    const currentReqId = (++reqId).toString();

                    resolveFunctions[currentReqId] = resolve;

                    // @ts-ignore
                    console.log(Native.sendHttpRequest)
                    window.webkit.messageHandlers.Native.postMessage(JSON.stringify({
                        reqId: currentReqId,
                        action: "HTTPRequest",
                        url,
                        headers
                    }));
                });
            }

            function sendResult(result, last = false) {
                const currentReqId = (++reqId).toString();

                // @ts-ignore
                                    window.webkit.messageHandlers.Native.postMessage(JSON.stringify({
                    reqId: currentReqId,
                    action: "result",
                    shouldExit: last,
                    result
                }));
            }

            function sendSignal(signal, message = ""){
                const currentReqId = (++reqId).toString();

                // @ts-ignore
                                    window.webkit.messageHandlers.Native.postMessage(JSON.stringify({
                    reqId: currentReqId,
                    action: signal === 0 ? "exit" : "error",
                    result: message
                }));
            }

            function loadScript(url){
                return new Promise((resolve, reject) => {
                    const script = document.createElement('script');
                    
                    script.src = url;
                    script.onload = resolve;
                    script.onerror = reject;
            
                    document.head.appendChild(script);
                });
            }

            """
        
        let caller = """
        var data = {
            'reqId': -1,
            'action': 'logic',
            'payload': {
                query: 'something',
                'action': 'actionName'
            }
        };
        var event = new MessageEvent('message', { data: JSON.stringify(data) });
        window.dispatchEvent(event);
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
            viewStore: viewStore
        )
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let javaScript: String
        let requestType: String
        @Binding var nextUrl: String
        let viewStore: ViewStoreOf<WebviewDomain>
        @Dependency(\.globalData) var globalData
        
        init(javaScript: String, requestType: String, nextUrl: Binding<String>, viewStore: ViewStoreOf<WebviewDomain>) {
            self.javaScript = javaScript
            self.requestType = requestType
            self._nextUrl = nextUrl
            self.viewStore = viewStore
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            
            print("CALLED: \(message.name)")
            
            if message.name == "Native" {
                print(message.body)
                if let body = message.body as? String {
                    sendHttpRequest(data: body)
                }
            }
            else if message.name == "logHandler" {
                print("LOG: \(message.body)")
                if let message = message.body as? String {
                    let data = message.data(using: .utf8)
                    let decoder = JSONDecoder()
                    do {
                        if data != nil {
                            var consoleData = try decoder.decode(ConsoleData.self, from: data!)
                            let module = globalData.getModule()
                            consoleData.moduleName = module?.name ?? ""
                            consoleData.moduleIconPath = module?.icon ?? ""
                            print(consoleData)
                            viewStore.send(.appendGlobalLog(item: consoleData))
                        }
                    } catch {
                        print(error.localizedDescription)
                                let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                                NotificationCenter.default
                                    .post(name:           NSNotification.Name("floaty"),
                                          object: nil, userInfo: data)
                    }
                }
            }
        }
        
        func sendHttpRequest(data: String) {
            // Your Swift function implementation here
            // This function will be called when JavaScript calls Native.sendHttpRequest
            // Implement your networking code or any other functionality you want to perform with the received data.
            print("Received data from JavaScript:", data)
        }
        
        func get(url: URL, headers: [String: String], completionHandler: @escaping (String?, Error?) -> Void) {
            var request = URLRequest(url: url)
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completionHandler(nil, error)
                    return
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    completionHandler(responseString, nil)
                } else {
                    completionHandler(nil, NSError(domain: "", code: -1, userInfo: nil))
                }
            }

            task.resume()
        }
        
        func postMessage(message: String) {
            if let jsonData = message.data(using: .utf8) {
            do {
                let req = try JSONDecoder().decode(RequestOption.self, from: jsonData)
                
                if(req.action == "HTTPRequest" && req.url != nil && req.headers != nil){
                    get(url: URL(string: req.url!)!, headers: req.headers!) { responseString, error in
                        if let error = error {
                            print("Error:", error.localizedDescription)
                        } else if let responseString = responseString {
                            print("Response:", responseString)
                            
                            var response: Dictionary<String, String> = [
                                "reqId": req.reqId,
                                "responseText": responseString
                            ]
                            
                            webView.postWebMessage(WebMessage(JSONObject(response).toString()), Uri.parse("*"))
                        }
                    }
                    //var myWebView = this.webview;
                    /*
                    var response: Dictionary<String, String> = mapOf(
                        "reqId" to req.reqId,
                        "responseText" to responseText
                    );
                     */
                    
                    /*
                    withContext(Dispatchers.Main) {
                        myWebView.postWebMessage(WebMessage(JSONObject(response).toString()), Uri.parse("*"))
                    }
                     */
                    
                }else if(req.action == "result" && req.result != nil){
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
                print("Error decoding JSON:", error)
            }
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
