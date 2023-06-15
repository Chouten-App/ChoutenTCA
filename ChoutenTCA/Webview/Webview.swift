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

struct WebView: UIViewRepresentable {
    @ObservedObject var viewStore: ViewStore<WebviewDomain.State, WebviewDomain.Action>
    
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
        let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        let divCreationString = """
            let choutenDivElement = document.createElement('div');
            choutenDivElement.setAttribute('id', 'chouten');
            document.body.prepend(choutenDivElement);
            """
        
        let divCreation = WKUserScript(source: divCreationString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(divCreation)
        userContentController.addUserScript(script)
        
        let jsInject = WKUserScript(source: viewStore.javaScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        userContentController.addUserScript(jsInject)
        
        let scriptHandlerString = """
            window.webkit.messageHandlers.callbackHandler.postMessage(document.getElementById('chouten').innerText);
            """
        
        let scriptHandler = WKUserScript(source: scriptHandlerString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(scriptHandler)
        
        
        
        let handlerName = "callbackHandler"
        userContentController.add(context.coordinator, name: handlerName)
        userContentController.add(context.coordinator, name: "logHandler")

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let preferences = WKWebpagePreferences()
        
        preferences.allowsContentJavaScript = true // Enable JavaScript
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        webView.navigationDelegate = context.coordinator
        webView.loadHTMLString(viewStore.htmlString, baseURL: URL(string: "http://localhost/")!)
        
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
            if message.name == "callbackHandler" {
                print("WEBKIT: \(message.body)")
                if let message = message.body as? String {
                    let data = message.data(using: .utf8)
                    let decoder = JSONDecoder()
                    print("test")
                    print(requestType)
                    if requestType == "home" {
                        do {
                            let homeComponents = try decoder.decode(DecodableResult<[HomeComponent]>.self, from: data!)
                            
                            viewStore.send(.setGlobalHomeData(data: homeComponents.result))
                            viewStore.send(.setGlobalNextUrl(url: homeComponents.nextUrl))
                        } catch {
                            print(error.localizedDescription)
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name:           NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                    } else if requestType == "search" {
                        do {
                            let searchResults = try decoder.decode([SearchData].self, from: data!)
                            print(searchResults)
                            viewStore.send(.setGlobalSearchResults(results: searchResults))
                        } catch {
                            print(error.localizedDescription)
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name:           NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                    } else if requestType == "info" {
                        do {
                            let info = try decoder.decode(DecodableResult<InfoData>.self, from: data!)
                            print(info.result)
                            viewStore.send(.setGlobalInfoData(data: info.result))
                            viewStore.send(.setGlobalNextUrl(url: info.nextUrl))
                            return
                        } catch {
                            print(error.localizedDescription)
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name:           NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                        do {
                            let info = try decoder.decode(DecodableResult<String>.self, from: data!)
                            viewStore.send(.setGlobalNextUrl(url: info.nextUrl))
                            return
                        } catch {
                            print(error.localizedDescription)
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name:           NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                        do {
                            let info = try decoder.decode(MediaList.self, from: data!)
                            viewStore.send(.setMediaList(list: [info]))
                            return
                        } catch {
                            print(error.localizedDescription)
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name:           NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                    } else if requestType == "media" {
                        do {
                            let info = try decoder.decode(DecodableResult<[ServerData]>.self, from: data!)
                            
                            print("\n\n\n\nINFO: \(info)\n\n\n\n")
                            
                            viewStore.send(.setGlobalServers(list: info.result))
                            viewStore.send(.setGlobalNextUrl(url: info.nextUrl))
                            
                            return
                        } catch {
                            print(error.localizedDescription)
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name:           NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                        do {
                            let info = try decoder.decode(DecodableResult<VideoData>.self, from: data!)
                            viewStore.send(.setGlobalVideoData(data: info.result))
                            viewStore.send(.setGlobalNextUrl(url: info.nextUrl))
                            return
                        } catch {
                            print(error.localizedDescription)
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name:           NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                        /*
                        do {
                            let info = try decoder.decode(DecodableResult<[String]>.self, from: data!)
                            mediaConsumeBookData = info.result
                            nextUrl = info.nextUrl ?? ""
                        } catch {
                            print(error.localizedDescription)
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name:           NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                         */
                        do {
                            let info = try decoder.decode(DecodableResult<String>.self, from: data!)
                            viewStore.send(.setGlobalNextUrl(url: info.nextUrl))
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
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
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
