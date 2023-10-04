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
    let url: String
    @Binding var cookies: [HTTPCookie]
    var onDone: () -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS VERSION like Mac OS X) AppleWebKit/WEBKIT_VERSION (KHTML, like Gecko) Mobile/USER_AGENT_APP_NAME"
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: URL(string: url)!))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: CloudflareWebview

        init(_ parent: CloudflareWebview) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Get cookies after captcha solving
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                self.parent.cookies = cookies
            }
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            // Continue with the original request after captcha solving
            parent.onDone()
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
    @State var loadingProgress: Double = 0.0
    
    @Dependency(\.globalData) var globalData
    
    func setCookies() {
        // Get the shared URLSession's cookie storage
        let cookieStorage = HTTPCookieStorage.shared

        // Delete any existing cookies with the same name and domain
        for cookie in cookies {
            if let existingCookie = cookieStorage.cookies?.first(where: {
                $0.name == cookie.name && $0.domain == cookie.domain
            }) {
                cookieStorage.deleteCookie(existingCookie)
            }
        }
        
        // Add the new cookies to the cookie storage
        for cookie in cookies {
            cookieStorage.setCookie(cookie)
        }
        
        globalData.setCfUrl(nil)
        globalData.setShowOverlay(false)
    }
    
    var body: some View {
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        Button {
                            setCookies()
                        } label: {
                            Text("Done")
                                .foregroundColor(Color(hex: Colors.Primary.dark))
                        }
                        .padding(.horizontal)
                        
                        Text("Cloudflare detected.")
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    Text(url)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color(hex: Colors.onPrimaryContainer.dark))
                        .background {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    Color(hex: Colors.PrimaryContainer.dark)
                                )
                        }
                        .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background {
                    Color(hex: Colors.SurfaceContainer.dark)
                }
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .overlay(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(
                            Color(hex: Colors.Primary.dark)
                        )
                        .frame(width: UIScreen.main.bounds.width * loadingProgress, height: 4)
                }
                
                CloudflareWebview(
                    url: url,
                    cookies: $cookies,
                    onDone: {
                        print("Cookies acquired:", cookies)
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Color(hex: Colors.SurfaceContainer.dark)
                }
                
                ZStack {
                    Color(hex: Colors.Error.dark)
                    
                    VStack {
                        Text("WARNING")
                            .fontWeight(.bold)
                        
                        Text("Do not share credentials of any kind unless you trust the module.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .opacity(0.7)
                            .padding(.horizontal)
                    }
                    .foregroundColor(Color(hex: Colors.onError.dark))
                    .padding(.bottom, 20)
                    .padding(.top, 8)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea(.all, edges: .bottom)
        }
}

struct CloudflareWebview_Previews: PreviewProvider {
    static var previews: some View {
        CloudflareView(url: "https://nhentai.net", isShowing: .constant(true))
    }
}
