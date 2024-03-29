//
//  MainView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 22.05.23.
//

import SwiftUI
import ComposableArchitecture
import PopupView
import Kingfisher

struct MainView: View {
    let store: StoreOf<MainDomain>
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    // incognito banner
                    ZStack(alignment: .bottom) {
                        Color(hex: Colors.Tertiary.dark)
                        
                        Text("Downloaded Only")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                Color(hex: Colors.onTertiary.dark)
                            )
                            .padding(.vertical, 8)
                            .padding(.top, proxy.safeAreaInsets.top)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxHeight: viewStore.isDownloadedOnly ? nil : 0.0)
                    .animation(.spring(response: 0.3), value: viewStore.isDownloadedOnly)
                    .zIndex(viewStore.isDownloadedOnly && !viewStore.isIncognito ? 10 : 0)
                    
                    // incognito banner
                    ZStack(alignment: .bottom) {
                        Color(hex: Colors.Primary.dark)
                        
                        Text("Incognito")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                Color(hex: Colors.onPrimary.dark)
                            )
                            .padding(.vertical, viewStore.isIncognito ? 8 : 0)
                            .padding(.top, viewStore.isDownloadedOnly ? 0 : proxy.safeAreaInsets.top)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxHeight: viewStore.isIncognito ? nil : 0.0)
                    .animation(.spring(response: 0.3), value: viewStore.isIncognito)
                    
                    TabView(
                        selection: viewStore.binding(
                            get: \.navbarState.tab,
                            send: { MainDomain.Action.setTab(.setTab(newTab: $0)) }
                        )
                    ) {
                        HomeView(
                            store: self.store.scope(
                                state: \.homeState,
                                action: MainDomain.Action.home
                            )
                        )
                        .tag(0)
                        
                        if viewStore.iosStyle {
                            SearchViewiOS(
                                store: self.store.scope(
                                    state: \.searchState,
                                    action: MainDomain.Action.search
                                )
                            )
                            .tag(1)
                        } else {
                            SearchView(
                                store: self.store.scope(
                                    state: \.searchState,
                                    action: MainDomain.Action.search
                                )
                            )
                            .tag(1)
                        }
                        
                        RepoView()
                            .tag(2)
                        
                        if viewStore.iosStyle {
                            MoreViewiOS(
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
                        } else {
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
                    .padding(.leading, UIScreen.main.bounds.width > 600 ? 80 : 0)
                }
                .foregroundColor(Color(hex: Colors.onSurface.dark))
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
                                ),
                                showModules: viewStore.binding(
                                    get: \.isShowingBottomSheet,
                                    send: MainDomain.Action.setBottomSheet(newValue:)
                                )
                            )
                        )
                    )
                }
                 
                /*
                .overlay(alignment: .bottom) {
                    
                    CloudflareView(
                        url: "https://aniwatch.to",
                        isShowing: viewStore.binding(
                            get: \.showOverlay,
                            send: MainDomain.Action.setShowOverlay(newBool:)
                        )
                    )
                    .padding(.bottom, 80)
                     
                }
                 */
                // Navbar
                .overlay(alignment: viewStore.navbarState.screenWidth > 600 ? .leading : .bottom) {
                    if viewStore.iosStyle {
                        NavbariOS(
                            store: self.store.scope(
                                state: \.navbarState,
                                action: MainDomain.Action.setTab
                            )
                        )
                    } else {
                        Navbar(
                            store: self.store.scope(
                                state: \.navbarState,
                                action: MainDomain.Action.setTab
                            )
                        )
                    }
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
                        .dragToDismiss(true)
                }
                .ignoresSafeArea()
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
            
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
