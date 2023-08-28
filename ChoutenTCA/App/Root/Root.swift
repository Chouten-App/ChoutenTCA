//
//  Root.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import SwiftUI
import ComposableArchitecture

struct Root: View {
    let store: StoreOf<RootDomain>
    @StateObject var Colors = DynamicColors.shared
    
    @FetchRequest(sortDescriptors: []) var info: FetchedResults<Infodata>
    @FetchRequest(sortDescriptors: []) var userInfo: FetchedResults<UserInfo>
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                ZStack {
                    Color(hex: Colors.Surface.dark)
                    
                    VStack {
                        NavigationLink(
                            destination: MainView(
                                store: Store(
                                    initialState: MainDomain.State(),
                                    reducer: MainDomain()
                                )
                            ),
                            isActive: viewStore.binding(
                                get: \.isLoadingDone,
                                send: RootDomain.Action.setLoadingDone(bool:)
                            )
                        ) {
                            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(40)
                                .padding(.horizontal, 120)
                                .frame(maxWidth: 400)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                                        //viewStore.send(.setNavigate(newValue: true))
                                        viewStore.send(.setLoadingDone(bool: true), animation: .spring(response: 0.3))
                                    }
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
            .accentColor(Color(hex: Colors.Primary.dark))
            .navigationViewStyle(.stack)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                /*
                if !info.isEmpty {
                    let data = info.first { infoData in
                        infoData.id == "classroom-of-the-elite-713"
                    }
                    if let data {
                        print(data.primaryTitle ?? "")
                    }
                }
                 */
                if !userInfo.isEmpty {
                    print(userInfo[0].selectedModuleId)
                    if userInfo[0].selectedModuleId != nil {
                        viewStore.send(.setSelectedModuleId(id: userInfo[0].selectedModuleId!))
                    }
                }
                
                viewStore.send(.onAppear)
            }
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
