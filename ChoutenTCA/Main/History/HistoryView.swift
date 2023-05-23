//
//  HistoryView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import SwiftUI

struct HistoryView: View {
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("History")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
            
            Text("Continue watching")
                .fontWeight(.semibold)
                .padding(.top, 12)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<6) { index in
                        VStack {
                            Image("poster")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 180, height: 90)
                                .cornerRadius(12)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: Colors.Scrim.dark).opacity(0.4))
                                }
                                .overlay(alignment: .bottomLeading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color(hex: Colors.Primary.dark))
                                        .frame(maxWidth: 60, maxHeight: 4)
                                        .offset(x: 8, y: -8)
                                }
                            
                            Text("Kimetsu no Yaiba")
                                .padding(.leading, 12)
                                .frame(maxWidth: 180, alignment: .leading)
                            
                            Text("Episode 1")
                                .font(.caption)
                                .opacity(0.7)
                                .padding(.leading, 12)
                                .frame(maxWidth: 180, alignment: .leading)
                        }
                        .padding(.bottom, 12)
                        .background {
                            Color(hex: Colors.SurfaceContainer.dark)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 80)
        .foregroundColor(Color(hex: Colors.onSurface.dark))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(hex: Colors.Surface.dark))
        .ignoresSafeArea()
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
