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

struct CloudflareWebview: UIViewRepresentable {
    let request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        
        preferences.allowsContentJavaScript = true // Enable JavaScript
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
    }
}

struct CloudflareView: View {
    let store: StoreOf<CustomBottomSheetDomain> = Store(
        initialState: CustomBottomSheetDomain.State(),
        reducer: CustomBottomSheetDomain()
    )
    
    @StateObject var Colors = DynamicColors.shared
    
    @State var isShowing = true
    var body: some View {
        BottomSheet(
            store: self.store,
            isShowing: $isShowing,
            content: AnyView(
                CloudflareWebview(
                    request: URLRequest(
                        url: URL(
                            string: "https://allanime.to/"
                        )!
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: 700)
                .overlay(alignment: .bottomTrailing) {
                    Text("Done")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .foregroundColor(Color(hex: Colors.onPrimary.dark))
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: Colors.Primary.dark))
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 80)
                }
            )
        )
    }
}

struct CloudflareWebview_Previews: PreviewProvider {
    static var previews: some View {
        CloudflareView()
    }
}
