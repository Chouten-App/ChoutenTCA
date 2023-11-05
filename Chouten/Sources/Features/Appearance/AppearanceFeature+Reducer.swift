//
//  File.swift
//  
//
//  Created by Inumaki on 04.11.23.
//

import Foundation
import Architecture

extension AppearanceFeature: Reducer {
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .setColorScheme(let to):
                    switch to {
                    case .light:
                        state.colorScheme = 0
                    case .dark:
                        state.colorScheme = 1
                    case .system:
                        state.colorScheme = 2
                    }
                    return .none
                }
            }
        }
    }
}
