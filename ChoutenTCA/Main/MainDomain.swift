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
        var navbarState = NavbarDomain.State()
        var searchState = SearchDomain.State()
        var moreState = MoreDomain.State()
        var floatyState = FloatyDomain.State()
    }
    
    enum Action: Equatable {
        case setTab(NavbarDomain.Action)
        case search(SearchDomain.Action)
        case more(MoreDomain.Action)
        case floaty(FloatyDomain.Action)
    }
    
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
        
        Reduce { state, action in
            switch action {
            case .setTab(let action):
                switch action {
                case .setTab(let newTab):
                    state.navbarState.tab = newTab
                }
                return .none
            case .search:
                return .none
            case .more:
                return .none
            case .floaty:
                return .none
            }
        }
    }
}
