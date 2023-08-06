//
//  CloudflareWebview.swift
//  ChoutenTCA
//
//  Created by Inumaki on 02.06.23.
//

import SwiftUI

import SwiftUI
import WebKit
import SwiftyJSON
import ComposableArchitecture

struct ModuleCookies: Codable, Equatable {
    let moduleId: String
    let cookies: [Cookie]
}

struct Cookie: Codable, Equatable {
    let name: String
    let value: String
    let domain: String
    let path: String
    let version: Int
    let expiresDate: Date?
}

struct CloudflareWebview: UIViewRepresentable {
    let request: URLRequest
    @Binding var cookies: [HTTPCookie]
    @Binding var fetchCookies: Bool
    @Binding var resetCookies: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        
        preferences.allowsContentJavaScript = true // Enable JavaScript
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Mobile/15E148 Safari/604.1"
        
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if fetchCookies {
            let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
            
            cookieStore.getAllCookies { cookies in
                DispatchQueue.main.async {
                    self.cookies = cookies
                    self.printCookie()
                    self.fetchCookies = false
                }
            }
            
            //print(self.cookies)
        }
        if resetCookies {
            removeAllCookies()
            
            self.resetCookies = false
        }
    }
    
    func removeAllCookies() {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeCookies])
        let date = NSDate(timeIntervalSince1970: 0)
        
        WKWebsiteDataStore.default().removeData(
            ofTypes: websiteDataTypes as! Set<String>,
            modifiedSince: date as Date,
            completionHandler: {}
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @Dependency(\.globalData) var globalData
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            checkForCFClearanceCookie(webView: webView)
        }
        
        func convertToCustomCookies(httpCookies: [HTTPCookie]) -> [Cookie] {
            return httpCookies.map { httpCookie in
                return Cookie(
                    name: httpCookie.name,
                    value: httpCookie.value,
                    domain: httpCookie.domain,
                    path: httpCookie.path,
                    version: httpCookie.version,
                    expiresDate: httpCookie.expiresDate
                )
            }
        }
        
        private func checkForCFClearanceCookie(webView: WKWebView) {
            let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
            
            cookieStore.getAllCookies { cookies in
                if let cfClearanceCookie = cookies.first(where: { $0.name == "cf_clearance" }) {
                    print("FOUND")
                    print("cf_clearance cookie value: \(cfClearanceCookie.value)")
                    
                    let c = self.convertToCustomCookies(httpCookies: cookies)
                    
                    self.globalData.setCookies(ModuleCookies(moduleId: self.globalData.getModule()?.id ?? "", cookies: c))
                    
                    self.globalData.setShowOverlay(false)
                }
            }
        }
    }
    
    func printCookie() {
        if let cfClearanceCookie = cookies.first(where: { $0.name == "cf_clearance" }) {
            print("cf_clearance cookie value: \(cfClearanceCookie.value)")
        } else {
            print("cf_clearance cookie not found")
        }
    }
}

struct CloudflareView: View {
    let url: String
    @Binding var isShowing: Bool
    let store: StoreOf<CustomBottomSheetDomain> = Store(
        initialState: CustomBottomSheetDomain.State(),
        reducer: CustomBottomSheetDomain()
    )
    
    @StateObject var Colors = DynamicColors.shared
    @State private var cookies: [HTTPCookie] = []
    @State var fetchCookies: Bool = false
    @State var resetCookies: Bool = false
    
    
    var body: some View {
        BottomSheet(
            store: self.store,
            isShowing: $isShowing,
            content: AnyView(
                CloudflareWebview(
                    request: URLRequest(
                        url: URL(
                            string: url
                        )!
                    ),
                    cookies: $cookies,
                    fetchCookies: $fetchCookies,
                    resetCookies: $resetCookies
                )
                .frame(maxWidth: .infinity, maxHeight: 600)
                .overlay(alignment: .bottomTrailing) {
                    HStack {
                        Spacer()
                        
                        Text(url)
                            .fontWeight(.medium)
                            .font(.title3)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: 320, maxHeight: 40, alignment: .leading)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        Color(hex: Colors.Surface.dark)
                                    )
                            }
                            .foregroundColor(Color(hex: Colors.onSurface.dark))
                        
                        Spacer()
                    }
                    .padding(.bottom, 20)
                }
            )
        )
    }
}

struct CloudflareWebview_Previews: PreviewProvider {
    static var previews: some View {
        CloudflareView(url: "https://aniwatch.to", isShowing: .constant(true))
    }
}
