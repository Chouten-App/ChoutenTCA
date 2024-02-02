//
//  File.swift
//  
//
//  Created by Inumaki on 14.12.23.
//

import ComposableArchitecture
import SwiftUI
import Architecture

extension HomeFeature: Reducer {
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case _:
                    return .none
                }
            }
        }
    }
}
