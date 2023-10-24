//
//  File.swift
//  
//
//  Created by Inumaki on 16.10.23.
//

import Architecture
import ComposableArchitecture
import Webview

extension InfoFeature: Reducer {
    public var body: some ReducerOf<Self> {
        Scope(state: \.webviewState, action: /Action.InternalAction.webview) {
            WebviewFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .setTextColor(let color):
                    state.textColor = color
                    return .none
                case .setBackgroundColor(let color):
                    state.backgroundColor = color
                    return .send(
                        .view(
                            .setTextColor(
                                color: color.complementaryColor()
                            )
                        )
                    )
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
