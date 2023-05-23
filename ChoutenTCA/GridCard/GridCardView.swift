//
//  GridCardView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct GridCardView: View {
    let store: Store<GridCardDomain.State, GridCardDomain.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                KFImage(URL(string: viewStore.data.image))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 180)
                    .cornerRadius(12)
                
                Text(viewStore.data.title.english ?? viewStore.data.title.romaji)
                    .frame(width: 120)
                    .lineLimit(1)
                
                HStack {
                    Spacer()
                    
                    Text("\(viewStore.currentEpisodes) / \(viewStore.totalEpisodes)")
                        .font(.caption)
                }
                .frame(width: 120)
            }
        }
    }
}

struct GridCardView_Previews: PreviewProvider {
    static var previews: some View {
        GridCardView(
            store: Store(
                initialState: GridCardDomain.State(
                    data: SearchResult.sample.results[0]
                ),
                reducer: GridCardDomain.reducer,
                environment: GridCardDomain.Environment()
            )
        )
    }
}
