//
//  MainDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 22.05.23.
//

import Foundation
import ComposableArchitecture

struct MainDomain: ReducerProtocol {
    struct State: Equatable {
        var isShowingBottomSheet: Bool = false
        var showModuleButton: Bool = true
        
        var isIncognito: Bool = false
        var isDownloadedOnly: Bool = false
        
        var navbarState = NavbarDomain.State()
        var searchState = SearchDomain.State()
        var moreState = MoreDomain.State()
        var floatyState = FloatyDomain.State()
        var bottomSheetState = CustomBottomSheetDomain.State()
        var moduleSelectorState = ModuleSelectorDomain.State()
    }
    
    enum Action: Equatable {
        case setBottomSheet(newValue: Bool)
        case setModuleButton(newValue: Bool)
        case setTab(NavbarDomain.Action)
        case search(SearchDomain.Action)
        case more(MoreDomain.Action)
        case floaty(FloatyDomain.Action)
        case sheet(CustomBottomSheetDomain.Action)
        case selector(ModuleSelectorDomain.Action)
        
        case onAppear
        case setIncognito(newValue: Bool)
        case setDownloadedOnly(newValue: Bool)
    }
    
    @Dependency(\.globalData)
    var globalData
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.navbarState, action: /Action.setTab) {
            NavbarDomain()
        }
        
        Scope(state: \.searchState, action: /Action.search) {
            SearchDomain()
        }
        
        Scope(state: \.moreState, action: /Action.more) {
            MoreDomain()
        }
        
        Scope(state: \.floatyState, action: /Action.floaty) {
            FloatyDomain()
        }
        
        Scope(state: \.bottomSheetState, action: /Action.sheet) {
            CustomBottomSheetDomain()
        }
        
        Scope(state: \.moduleSelectorState, action: /Action.selector) {
            ModuleSelectorDomain()
        }
        
        Reduce { state, action in
            switch action {
            case .setBottomSheet(let newValue):
                state.isShowingBottomSheet = newValue
                return .none
            case .setModuleButton(let newValue):
                state.showModuleButton = newValue
                return .none
            case .setTab(let action):
                switch action {
                case .setTab(let newTab):
                    state.navbarState.tab = newTab
                    if state.navbarState.tab == 3 {
                        return .send(.setModuleButton(newValue: false))
                    } else {
                        return .send(.setModuleButton(newValue: true))
                    }
                }
            case .search:
                return .none
            case .more:
                return .none
            case .floaty:
                return .none
            case .sheet:
                return .none
            case .selector:
                return .none
                
            case .setIncognito(let newValue):
                state.isIncognito = newValue
                return .none
            case .setDownloadedOnly(let newValue):
                state.isDownloadedOnly = newValue
                return .none
            case .onAppear:
                state.isIncognito = globalData.getIncognito()
                state.isDownloadedOnly = globalData.getIncognito()
                
                return .merge(
                    .run { send in
                        let incognitoStream = globalData.observeIncognito()
                        for await value in incognitoStream {
                            await send(.setIncognito(newValue: value), animation: .easeOut(duration: 0.3))
                        }
                    },
                    .run { send in
                        let downloadedOnly = globalData.observeDownloadedOnly()
                        for await value in downloadedOnly {
                            await send(.setDownloadedOnly(newValue: value), animation: .easeOut(duration: 0.3))
                        }
                    }
                )
            }
        }._printChanges()
    }
}