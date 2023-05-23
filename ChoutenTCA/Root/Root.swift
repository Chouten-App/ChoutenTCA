//
//  Root.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import SwiftUI
import ComposableArchitecture
import NavigationTransitions

struct Root: View {
    let store: StoreOf<RootDomain>
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                ZStack {
                    Color(hex: Colors.Surface.dark)
                    
                    NavigationLink(destination: MainView(
                        store: Store(
                            initialState: MainDomain.State(),
                            reducer: MainDomain()
                        )
                    ), isActive: viewStore.binding(
                        get: \.navigate,
                        send: RootDomain.Action.setNavigate(newValue:)
                    )) {
                        VStack {
                            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(40)
                                .padding(.horizontal, 120)
                                .frame(maxWidth: 400)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        viewStore.send(.setNavigate(newValue: true))
                                    }
                                }
                            
                            Text("CHOUTEN")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(
                                    Color(hex: Colors.onSurface.dark)
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
            .accentColor(Color(hex: Colors.Primary.dark))
            .navigationViewStyle(.stack)
            .navigationTransition(.fade(.in))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
        
    }
}

struct Root_Previews: PreviewProvider {
    static var previews: some View {
        Root(
            store: Store(
                initialState: RootDomain.State(),
                reducer: RootDomain()
            )
        )
    }
}
