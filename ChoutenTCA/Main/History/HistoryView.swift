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
            
            Text("Continue watching")
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<6) { index in
                        
                    }
                }
            }
        }
        .padding(.horizontal, 20)
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
