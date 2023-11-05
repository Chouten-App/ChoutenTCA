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
import DataClient
import Foundation
import SharedModels

extension PlayerFeature: Reducer {
    public var body: some ReducerOf<Self> {
        Scope(state: \.webviewState, action: /Action.InternalAction.webview) {
            WebviewFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .setPiP(_):
                    return .none
                case .setSpeed(let value):
                    state.speed = value
                    return .none
                case .setServer(let value):
                    state.server = value
                    return .none
                case .setQuality(let value):
                    state.quality = value
                    return .none
                case .setShowMenu(let value):
                    state.showMenu = value
                    return .none
                case .setFullscreen(let value):
                    state.fullscreen = value
                    return .none
                case .navigateBack:
                    return .none
                case .onAppear:
                    if state.infoData == nil {
                        state.infoData = dataClient.getInfoData()
                    }
                    state.videoLoadable = .pending
                    
                    state.videoLoadable = .loading
                    
                    // TODO: get current selected module
                    do {
                        let module = try moduleClient.getModules().first
                        
                        if let module {
                            moduleClient.setSelectedModuleName(module)
                            
                            do {
                                let js = try moduleClient.getJs("media") ?? ""
                                
                                return .merge(
                                    .send(.internal(.webview(.view(.setHtmlString(newString: AppConstants.defaultHtml))))),
                                    .send(.internal(.webview(.view(.setJsString(newString: js))))),
                                    .send(.internal(.webview(.view(.setRequestType(type: "media")))))
                                )
                            } catch {
                                
                                //logger.error("\(error.localizedDescription)")
                            }
                        }
                    } catch {
                        //logger.error("\(error.localizedDescription)")
                    }
                    return .none
                case .parseResult(let data):
                    if let jsonData = data.data(using: .utf8) {
                        do {
                            let decoder = JSONDecoder()
                            let data = try decoder.decode([ServerData].self, from: jsonData)
                            
                            return .send(.view(.setServers(data: data)))
                        } catch {
                            print("Error decoding JSON ODSFG:", error)
                            state.videoLoadable = .failed(error)
                        }
                    } else {
                        print("Invalid JSON string")
                        //state.searchLoadable = .failed()
                    }
                    return .none
                case .parseVideoResult(let data):
                    if let jsonData = data.data(using: .utf8) {
                        do {
                            let decoder = JSONDecoder()
                            let data = try decoder.decode(VideoData.self, from: jsonData)
                            
                            return .send(.view(.setVideoData(data: data)))
                        } catch {
                            print("Error decoding JSON ODSFG:", error)
                            state.videoLoadable = .failed(error)
                        }
                    } else {
                        print("Invalid JSON string")
                        //state.searchLoadable = .failed()
                    }
                    return .none
                case .setServers(let data):
                    state.servers = data
                    return .none
                case .setVideoData(let data):
                    state.videoLoadable = .loaded(data)
                    return .none
                case .resetWebviewChange:
                    return .merge(
                        .send(.internal(.webview(.view(.setHtmlString(newString: ""))))),
                        .send(.internal(.webview(.view(.setJsString(newString: ""))))),
                        .send(.view(.onAppear))
                    )
                case .setQualityDict(let dict):
                    state.qualities = dict
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
