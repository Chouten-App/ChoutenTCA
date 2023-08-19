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
    let store: StoreOf<GridCardDomain>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                KFImage(URL(string: viewStore.data.img))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 180)
                    .cornerRadius(12)
                
                Text(viewStore.data.title)
                    .frame(width: 120)
                    .lineLimit(1)
                
                HStack {
                    Spacer()
                    
                    Text("\(viewStore.data.currentCount ?? 0) / \(viewStore.data.totalCount ?? 0)")
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
                    data: SearchData(url: "", img: "https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/b98659-sH5z5RfMuyMr.png", title: "Classroom of the Elite", indicatorText: "Sub", currentCount: 12, totalCount: 12)
                ),
                reducer: GridCardDomain()
            )
        )
    }
}
