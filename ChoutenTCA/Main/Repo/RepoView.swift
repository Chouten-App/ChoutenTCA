//
//  RepoView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 16.08.23.
//

import SwiftUI
import Kingfisher

struct RepoView: View {
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        VStack {
            Text("Repositories")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 20)
            
            VStack {
                ForEach(0..<4, id: \.self) { index in
                    HStack {
                        KFImage(URL(string: "https://moodoffdp.com/wp-content/uploads/2023/06/anime-boy-pfp-128x128-1.jpg"))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 64, height: 64)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Chouten Modules")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text("- Stars: 3")
                                    .fontWeight(.semibold)
                                    .opacity(0.7)
                            }
                            
                            Text("This will be the description of the Repo with long text")
                                .lineLimit(1)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .foregroundColor(Color(hex: Colors.onSurface.dark))
        .background {
            Color(hex: Colors.Surface.dark)
                .ignoresSafeArea()
        }
    }
}

struct RepoView_Previews: PreviewProvider {
    static var previews: some View {
        RepoView()
    }
}
