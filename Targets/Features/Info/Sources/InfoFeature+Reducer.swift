//
//  File.swift
//  
//
//  Created by Inumaki on 16.10.23.
//

import Architecture
import ComposableArchitecture
import Webview
import ModuleClient
import Foundation
import SharedModels
import SwiftUI
import DataClient

extension InfoFeature: Reducer {
    public var body: some ReducerOf<Self> {
        Scope(state: \.webviewState, action: /Action.InternalAction.webview) {
            WebviewFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .setColorTheme(let theme):
                    state.colorTheme = theme
                    return .none
                case .onAppear:
                    return .merge(
                        .send(.internal(.webview(.view(.setHtmlString(newString: ""))))),
                        .send(.internal(.webview(.view(.setJsString(newString: ""))))),
                        .send(.view(.info))
                    )
                case .navigateBack:
                    return .none
                case .info:
                    print("started info")
                    state.state = .notStarted
                    state.infoLoadable = .pending
                    
                    state.infoLoadable = .loading
                    
                    // TODO: get current selected module
                    let module = moduleClient.getCurrentModule()
                    
                    if let module {
                        moduleClient.setSelectedModuleName(module)
                        
                        do {
                            let js = try moduleClient.getJs("info") ?? ""
                            
                            return .merge(
                                .send(.internal(.webview(.view(.setHtmlString(newString: AppConstants.defaultHtml))))),
                                .send(.internal(.webview(.view(.setJsString(newString: js))))),
                                .send(.internal(.webview(.view(.setRequestType(type: "info")))))
                            )
                        } catch {
                            
                            //logger.error("\(error.localizedDescription)")
                        }
                    }
                    return .none
                case .parseResult(let data):
                    if let jsonData = data.data(using: .utf8) {
                        do {
                            let decoder = JSONDecoder()
                            let data = try decoder.decode(InfoData.self, from: jsonData)
                            
                            return .send(.view(.setInfoData(data: data)))
                        } catch {
                            print("Error decoding JSON ODSFG:", error)
                            state.infoLoadable = .failed(error)
                        }
                    } else {
                        print("Invalid JSON string")
                        //state.searchLoadable = .failed()
                    }
                    return .none
                case .parseMediaResult(let data):
                    if let jsonData = data.data(using: .utf8) {
                        do {
                            let decoder = JSONDecoder()
                            let data = try decoder.decode([MediaList].self, from: jsonData)
                            
                            return .send(.view(.setMediaList(data: data)))
                        } catch {
                            print("Error decoding JSON ODSFG:", error)
                            state.infoLoadable = .failed(error)
                        }
                    } else {
                        print("Invalid JSON string")
                        //state.searchLoadable = .failed()
                    }
                    return .none
                case .setInfoData(let data):
                    state.infoLoadable = .loaded(data)
                    
                    dataClient.setInfoData(data)
                    
                    return .none
                case .setMediaList(let data):
                    let infoTemp = state.infoLoadable.value
                    if var infoTemp {
                        infoTemp.mediaList = data
                        
                        dataClient.setInfoData(infoTemp)
                        
                        withAnimation(.easeInOut) {
                            state.infoLoadable = .loaded(infoTemp)
                        }
                    }
                    return .none
                case .episodeTap(let item, let index):
                    dataClient.setVideoUrl(item.url, index)
                    return .none
                }
            case let .internal(internalAction):
                switch internalAction {
                case .webview:
                    return .none
                }
            }
        }
    }
}
