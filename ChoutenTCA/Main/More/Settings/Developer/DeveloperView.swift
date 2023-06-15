//
//  DeveloperView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 06.06.23.
//

import SwiftUI
import ComposableArchitecture

struct DeveloperView: View {
    @StateObject var Colors = DynamicColors.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 12) {
                NavigationLink(
                    destination: LogsView(
                        store: Store(
                            initialState: LogsDomain.State(),
                            reducer: LogsDomain()
                        )
                    )
                ) {
                    SettingsComponent(
                        title: "Logs",
                        description: "A Logs View for Module devs",
                        icon: {
                            Image(systemName: "chevron.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 16)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 120)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
                    
                    Text("Developer")
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

struct DeveloperView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperView()
    }
}
