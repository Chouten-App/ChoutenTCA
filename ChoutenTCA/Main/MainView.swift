//
//  MainView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 22.05.23.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct MainView: View {
    let store: StoreOf<MainDomain>
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                TabView(
                    selection: viewStore.binding(
                        get: \.navbarState.tab,
                        send: { MainDomain.Action.setTab(.setTab(newTab: $0)) }
                    )
                ) {
                    Text("Home")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background {
                            Color(hex: Colors.Surface.dark)
                        }
                        .ignoresSafeArea()
                        .tag(0)
                    
                    SearchView(
                        store: self.store.scope(
                            state: \.searchState,
                            action: MainDomain.Action.search
                        )
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        Color(hex: Colors.Surface.dark)
                    }
                    .ignoresSafeArea()
                    .tag(1)
                    
                    Text("History")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background {
                            Color(hex: Colors.Surface.dark)
                        }
                        .ignoresSafeArea()
                        .tag(2)
                    
                    MoreView(
                        store: self.store.scope(
                            state: \.moreState,
                            action: MainDomain.Action.more
                        )
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        Color(hex: Colors.Surface.dark)
                    }
                    .ignoresSafeArea()
                    .tag(3)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("floaty")), perform: { value in
                print("hm")
                if value.userInfo != nil {
                    if value.userInfo!["data"] != nil {
                        let floatyData = value.userInfo!["data"] as! FloatyData
                        viewStore.send(.floaty(.setFloatyData(message: floatyData.message, error: floatyData.error, action: floatyData.action)))
                        viewStore.send(.floaty(.setFloatyBool(newValue: true)))
                    }
                }
            })
            // module button
            .overlay(alignment: .bottomTrailing) {
                ModuleButton(
                    isShowing: viewStore.binding(
                        get: \.isShowingBottomSheet,
                        send: MainDomain.Action.setBottomSheet(newValue:)
                    ),
                    showButton: viewStore.binding(
                        get: \.showModuleButton,
                        send: MainDomain.Action.setModuleButton(newValue:)
                    )
                )
            }
            // module selector
            .overlay(alignment: .bottom) {
                BottomSheet(
                    store: self.store.scope(
                        state: \.bottomSheetState,
                        action: MainDomain.Action.sheet
                    ),
                    isShowing: viewStore.binding(
                        get: \.isShowingBottomSheet,
                        send: MainDomain.Action.setBottomSheet(newValue:)
                    ),
                    content: AnyView(
                        ModuleSelector(
                            store: self.store.scope(
                                state: \.moduleSelectorState,
                                action: MainDomain.Action.selector
                            )
                        )
                    )
                )
                .padding(.bottom, 100)
            }
            // Navbar
            .overlay(alignment: .bottom) {
                Navbar(
                    store: self.store.scope(
                        state: \.navbarState,
                        action: MainDomain.Action.setTab
                    )
                )
            }
            .popup(isPresented: viewStore.binding(
                get: \.floatyState.showFloaty,
                send: { MainDomain.Action.floaty(.setFloatyBool(newValue: $0)) }
            )) {
                FloatyDisplay(
                    store: self.store.scope(
                        state: \.floatyState,
                        action: MainDomain.Action.floaty
                    )
                )
            } customize: {
                $0
                    .type(.floater())
                    .position(.bottom)
                    .animation(.spring())
                    .closeOnTapOutside(false)
                    .closeOnTap(false)
                    .autohideIn(4.0)
            }
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(
            store: Store(
                initialState: MainDomain.State(),
                reducer: MainDomain()
            )
        )
        .preferredColorScheme(.dark)
    }
}
