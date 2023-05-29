//
//  GridCardDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import Foundation
import ComposableArchitecture

struct GridCardDomain: ReducerProtocol {
    struct State: Equatable {
        var data: SearchData
        
        var currentEpisodes: String {
            get { data.currentEpisodeCount != nil ? String(data.currentEpisodeCount!) : "⁓" }
            set { data.currentEpisodeCount = Int(newValue) }
        }
        
        var totalEpisodes: String {
            get { data.totalEpisodes != nil ? String(data.totalEpisodes!) : "⁓" }
            set { data.totalEpisodes = Int(newValue) }
        }
    }
    
    enum Action: Equatable {}
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        default: 
            return .none
        }
    }
}
