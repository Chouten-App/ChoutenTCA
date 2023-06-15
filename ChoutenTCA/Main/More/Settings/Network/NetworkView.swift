//
//  NetworkView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 06.06.23.
//

import SwiftUI

struct NetworkView: View {
    @StateObject var Colors = DynamicColors.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 12) {
                Text("Nothing to change yet")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 120)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .foregroundColor(Color(hex: Colors.onSurface.dark))
            .background {
                Color(hex: Colors.Surface.dark)
            }
            .overlay(alignment: .top) {
                HStack {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 18)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    
                    Text("Network")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 20)
                .padding(.top, proxy.safeAreaInsets.top)
                .padding(.vertical, 8)
                .frame(maxWidth: proxy.size.width, alignment: .leading)
                .foregroundColor(Color(hex: Colors.onSurface.dark))
                .background {
                    //Color(hex: Colors.SurfaceContainer.dark)
                }
            }
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct NetworkView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkView()
    }
}
