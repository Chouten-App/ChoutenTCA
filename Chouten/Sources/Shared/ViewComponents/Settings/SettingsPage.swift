//
//  SwiftUIView.swift
//  
//
//  Created by Inumaki on 04.11.23.
//

import SwiftUI

public struct SettingsPage<Content>: View where Content: View {
    let title: String
    let content: () -> Content
    
    @Environment(\.presentationMode) var presentationMode
    
    public init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 12) {
                content()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 120)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.background)
            .overlay(alignment: .top) {
                HStack {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12)
                        .offset(x: -1)
                        .padding(6)
                        .contentShape(Rectangle())
                        .foregroundColor(.indigo)
                        .background {
                            Circle()
                                .fill(
                                    .regularMaterial
                                )
                        }
                        .onTapGesture {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    
                    Spacer()
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Spacer()
                        .frame(maxWidth: 20)
                }
                .padding(.horizontal, 12)
                .padding(.top, proxy.safeAreaInsets.top)
                .padding(.vertical, 8)
                .frame(maxWidth: proxy.size.width, alignment: .leading)
            }
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    SettingsPage("Settings") {
        Text("TEXT")
    }
}
