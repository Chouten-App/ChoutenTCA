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
            
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    HStack {
                        KFImage(URL(string: "https://i.pinimg.com/564x/b3/30/e8/b330e844ef0a94faf523df4101428c28.jpg"))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 52, height: 52)
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Chouten Modules")
                                    .fontWeight(.bold)
                                
                                Text("- Stars: 3")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .opacity(0.7)
                            }
                            
                            Text("This will be the description of the Repo with long text")
                                .font(.caption)
                                .lineLimit(1)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                    .padding(12)
                    .background {
                        Color(hex: Colors.SurfaceContainer.dark)
                            .cornerRadius(12)
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
