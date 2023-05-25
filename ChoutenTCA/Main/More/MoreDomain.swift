//
//  MoreDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import SwiftUI
import ComposableArchitecture

struct MoreDomain: ReducerProtocol {
    struct State: Equatable {
        var downloadedOnly: Bool = false
        var incognito: Bool = false
        let versionString: String = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "x.x").\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "x")"
        let buymeacoffeeString = "https://www.buymeacoffee.com/inumaki"
        let kofiString = "https://ko-fi.com/inumakicoding"
    }
    
    enum Action: Equatable {
        case setIncognito(newValue: Bool)
        case setDownloadedOnly(newValue: Bool)
        case openUrl(url: String)
        case onAppear
    }
    
    @Dependency(\.globalData) var globalData
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .setIncognito(let newValue):
                state.incognito = newValue
                globalData.setIncognito(newValue)
                return .none
            case .setDownloadedOnly(let newValue):
                state.downloadedOnly = newValue
                globalData.setDownloadedOnly(newValue)
                return .none
            case .openUrl(let url):
                if let url = URL(string: url) {
                    UIApplication.shared.open(url)
                }
                return .none
            case .onAppear:
                state.incognito = globalData.getIncognito()
                state.downloadedOnly = globalData.getDownloadedOnly()
                return .none
            }
        }
        ._printChanges()
    }
}
