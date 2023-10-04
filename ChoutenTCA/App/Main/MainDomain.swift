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
        var iosStyle: Bool = true
        
        var cfUrl: String? = nil
        var cookies: ModuleCookies? = nil
        var showOverlay: Bool = false
        
        var navbarState = NavbarDomain.State()
        var searchState = SearchDomain.State()
        var moreState = MoreDomain.State()
        var floatyState = FloatyDomain.State()
        var bottomSheetState = CustomBottomSheetDomain.State()
        var moduleSelectorState = ModuleSelectorDomain.State()
        var moduleButtonState = ModuleButtonDomain.State()
        var homeState = HomeDomain.State()
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
        case moduleButton(ModuleButtonDomain.Action)
        case home(HomeDomain.Action)
        
        case onAppear
        case setIncognito(newValue: Bool)
        case setDownloadedOnly(newValue: Bool)
        case setCookies(newValue: ModuleCookies?)
        case setCfUrl(newValue: String?)
        case setShowOverlay(newBool: Bool)
        case setAvailableModules(TaskResult<[Module]>)
    }
    
    @Dependency(\.globalData)
    var globalData
    @Dependency(\.moduleManager)
    var moduleManager
    
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
        
        Scope(state: \.moduleButtonState, action: /Action.moduleButton) {
            ModuleButtonDomain()
        }
        
        Scope(state: \.homeState, action: /Action.home) {
            HomeDomain()
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
            case .moduleButton:
                return .none
            case .home:
                return .none
                
            case .setIncognito(let newValue):
                state.isIncognito = newValue
                return .none
            case .setDownloadedOnly(let newValue):
                state.isDownloadedOnly = newValue
                return .none
            case .setCookies(let newValue):
                state.cookies = newValue
                return .none
            case .setShowOverlay(let newBool):
                state.showOverlay = newBool
                return .none
            case .setCfUrl(let newValue):
                state.cfUrl = newValue
                return .none
            case .onAppear:
                state.isIncognito = globalData.getIncognito()
                state.isDownloadedOnly = globalData.getIncognito()
                
                return .merge(
                    .run { send in
                        let incognitoStream = globalData.observeIncognito()
                        for await value in incognitoStream {
                            await send(.setIncognito(newValue: value), animation: .easeOut(duration: 0.2))
                        }
                    },
                    .run { send in
                        let cfStream = globalData.observeCfUrl()
                        for await value in cfStream {
                            await send(.setCfUrl(newValue: value))
                        }
                    },
                    .run { send in
                        let downloadedOnly = globalData.observeDownloadedOnly()
                        for await value in downloadedOnly {
                            await send(.setDownloadedOnly(newValue: value), animation: .easeOut(duration: 0.2))
                        }
                    },
                    .run { send in
                        let cookies = globalData.observeCookies()
                        for await value in cookies {
                            await send(.setCookies(newValue: value), animation: .easeOut(duration: 0.2))
                        }
                    },
                    .run { send in
                        let showOverlay = globalData.observeShowOverlay()
                        for await value in showOverlay {
                            await send(.setShowOverlay(newBool: value), animation: .easeOut(duration: 0.2))
                        }
                    },
                    .task {
                        await .setAvailableModules(
                            TaskResult {
                                let modules = try moduleManager.getModules()
                                let _ = try moduleManager.validateModules()
                                return modules
                            }
                        )
                    }
                )
            case .setAvailableModules(.success(let modules)):
                globalData.setAvailableModules(modules)
                return .none
            case .setAvailableModules(.failure(let error)):
                print(error)
                let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                NotificationCenter.default
                    .post(name:           NSNotification.Name("floaty"),
                          object: nil, userInfo: data)
                return .none
            }
        }
    }
}
