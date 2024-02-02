//
//  File.swift
//
//
//  Created by Inumaki on 14.10.23.
//

import Architecture
import ComposableArchitecture
import SwiftUI
import SharedModels
import ModuleClient
import Webview
import Info

private enum Cancellables: Hashable {
    case fetchingItemsDebounce
}

extension SearchFeature: Reducer {
    public var body: some ReducerOf<Self> {
        Scope(state: /State.self, action: /Action.view) {
            BindingReducer()
        }
        
        Scope(state: \.webviewState, action: /Action.InternalAction.webview) {
            WebviewFeature()
        }
        
        Scope(state: \.info, action: /Action.InternalAction.info) {
            InfoFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .backButtonPressed:
                    return .none
                case .setScrollPosition(let value):
                    state.scrollPosition = value
                    return .none
                case .setItemOpacity(let value):
                    state.itemOpacity = value
                    return .none
                case .setSearchData(let data):
                    state.searchResults = data
                    state.state = .success
                    state.searchLoadable = .loaded(data)
                    return .none
                case .appendSearchData(let data):
                    let temp = state.searchLoadable.value
                    if let temp {
                        print("adding to results")
                        state.searchLoadable = .loaded(temp + data)
                    } else {
                        state.searchLoadable = .loaded(data)
                    }
                    return .merge(
                        .send(.internal(.webview(.view(.setHtmlString(newString: ""))))),
                        .send(.internal(.webview(.view(.setJsString(newString: "")))))
                    )
                case .resetWebview:
                    return .merge(
                        .send(.internal(.webview(.view(.setHtmlString(newString: ""))))),
                        .send(.internal(.webview(.view(.setJsString(newString: ""))))),
                        .send(.view(.search))
                    )
                case .setSearchFocused(let val):
                    state.searchFocused = val
                    return .none
                case .increasePageNumber:
                    state.isFetching = true
                    state.page += 1
                    return .none
                case .search:
                    if state.searchLoadable.isNotLoaded {
                        state.state = .notStarted
                        state.searchLoadable = .pending
                        state.searchResults = []
                    }
                    
                    let query = state.query
                    
                    if query.isEmpty {
                        state.isFetching = false
                        return .none
                    }
                    
                    
                    state.htmlString = ""
                    if state.searchLoadable.isNotLoaded {
                        state.state = .loading
                        state.searchLoadable = .loading
                    }
                    
                    // TODO: get current selected module
                    let module = moduleClient.getCurrentModule()
                    
                    if let module {
                        moduleClient.setSelectedModuleName(module)
                        
                        do {
                            let js = try moduleClient.getJs("search") ?? ""
                            state.jsString = js
                            
                            state.htmlString = AppConstants.defaultHtml
                            
                            state.lastQuery = query
                            
                            return .merge(
                                .send(.internal(.webview(.view(.setHtmlString(newString: AppConstants.defaultHtml))))),
                                .send(.internal(.webview(.view(.setJsString(newString: js))))),
                                .send(.internal(.webview(.view(.setRequestType(type: "search")))))
                            )
                        } catch  {
                            state.isFetching = false
                            logger.error("\(error.localizedDescription)")
                        }
                    }
                    return .none
                case .removeQuery(let at):
                    return .none
                case .setLoadingStatus(let status):
                    state.state = status
                    return .none
                case .setInfo(let url):
                    print("setting info")
                    state.info = InfoFeature.State(url: url)
                    state.infoVisible = true
                    return .none
                case .setInfoVisible(let value):
                    state.infoVisible = value
                    return .none
                case .setDragState(let value):
                    state.dragState = value
                    return .none
                case .binding(\.$query):
                    return .none
                    /*
                    let searchQuery = state.query
                    
                    guard !searchQuery.isEmpty else {
                        state.state = .notStarted
                        return .cancel(id: Cancellables.fetchingItemsDebounce)
                    }
                    
                    state.state = .loading
                    
                    return .run { send in
                        await send(.view(.search), animation: .easeInOut)
                    }
                    .debounce(id: Cancellables.fetchingItemsDebounce, for: 0.5, scheduler: DispatchQueue.main)
                     */
                case .binding:
                    return .none
                case .setLoadable(let new_state):
                    state.searchLoadable = new_state
                    return .none
                case .parseResult(let data):
                    print(data)
                    
                    if let jsonData = data.data(using: .utf8) {
                        do {
                            let decoder = JSONDecoder()
                            let searchResult = try decoder.decode([SearchData].self, from: jsonData)
                            
                            print("Decoded search result:", searchResult)
                            //globalData.setSearchResults(searchResult)
                            if searchResult.count == 0 {
                                state.wasLastPage = true
                                state.isFetching = false
                                return .none
                            }
                            return .send(.view(.appendSearchData(searchResult)))
                        } catch {
                            print("Error decoding JSON ODSFG:", error)
                            state.isFetching = false
                            state.searchLoadable = .failed(error)
                        }
                    } else {
                        print("Invalid JSON string")
                        state.isFetching = false
                        //state.searchLoadable = .failed()
                    }
                    return .none
                case .setHeaderOpacity(let value):
                    state.headerOpacity = value
                    return .none
                }
            case let .internal(internalAction):
                switch internalAction {
                case .webview:
                    return .none
                case .info(.view(.navigateBack)):
                    state.infoVisible = false
                    return .none
                case .info:
                    return .none
                }
            }
        }
    }
}
