//
//  WebviewDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import Foundation
import ComposableArchitecture

struct WebviewDomain: ReducerProtocol {
    struct State: Equatable {
        var htmlString: String = ""
        var javaScript: String = ""
        var requestType: String = ""
        let enableExternalScripts: Bool = false
        var nextUrl: String = ""
    }
    
    enum Action: Equatable {
        case setNextUrl(newUrl: String)
        case setHtmlString(newString: String)
        case setJsString(newString: String)
        case setRequestType(type: String)
        case setGlobalInfoData(data: InfoData)
        case setGlobalSearchResults(results: [SearchData])
    }
    
    @Dependency(\.globalData)
    var globalData
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setNextUrl(let newUrl):
            state.nextUrl = newUrl
            return .none
        case .setHtmlString(let newString):
            state.htmlString = newString
            return .none
        case .setJsString(let newString):
            state.javaScript = newString
            return .none
        case .setGlobalSearchResults(let results):
            globalData.setSearchResults(results)
            return .none
        case .setGlobalInfoData(let data):
            globalData.setInfoData(data)
            return .none
        case .setRequestType(let type):
            state.requestType = type
            return .none
        }
    }
}
