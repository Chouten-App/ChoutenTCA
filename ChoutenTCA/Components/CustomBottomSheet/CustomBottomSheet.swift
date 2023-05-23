//
//  CustomBottomSheet.swift
//  ModularSaikouS
//
//  Created by Inumaki on 18.03.23.
//

import SwiftUI
import ComposableArchitecture

struct BottomSheet: View {
    let store: StoreOf<CustomBottomSheetDomain>
    @Binding var isShowing: Bool
    var content: AnyView
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { proxy in
                if viewStore.fromLeft {
                    ZStack(alignment: Alignment.leading) {
                        if (isShowing) {
                            Color(hex: Colors.Scrim.dark)
                                .opacity(0.4)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    isShowing.toggle()
                                }
                                .gesture(DragGesture()
                                    .onChanged({ val in
                                        if(val.translation.width <= 0) {
                                            viewStore.send(.setOffset(newY: val.translation.width))
                                        }
                                    })
                                        .onEnded({ val in
                                            if val.translation.width < -200 {
                                                isShowing = false
                                            }
                                            viewStore.send(.setOffset(newY: 0))
                                        })
                                )
                            content
                                .offset(x: viewStore.offsetY)
                                .animation(.spring(response: 0.3), value: viewStore.offsetY)
                                .transition(.move(edge: .leading))
                                .background(
                                    Color(.clear)
                                )
                                .overlay(alignment: .trailing) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(hex: Colors.Outline.dark))
                                            .frame(maxWidth: 4, maxHeight: 32)
                                            .offset(x: viewStore.offsetY)
                                            .animation(.spring(response: 0.3), value: viewStore.offsetY)
                                            .padding(.trailing, 16)
                                    }
                                    .frame(maxHeight: .infinity)
                                    .contentShape(Rectangle())
                                    .gesture(DragGesture()
                                        .onChanged({ val in
                                            if(val.translation.width <= 0) {
                                                viewStore.send(.setOffset(newY: val.translation.width))
                                            }
                                        })
                                            .onEnded({ val in
                                                if val.translation.width < -200 {
                                                    isShowing = false
                                                }
                                                viewStore.send(.setOffset(newY: 0))
                                            })
                                    )
                                }
                                .cornerRadius(20, corners: [.bottomRight, .topRight])
                                .clipped(antialiased: true)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea()
                    .animation(.spring(response: 0.3), value: isShowing)
                } else {
                    ZStack(alignment: viewStore.fromRight ? Alignment.trailing : viewStore.alignment) {
                        if (isShowing) {
                            Color(hex: Colors.Scrim.dark)
                                .opacity(0.4)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    isShowing.toggle()
                                }
                                .gesture(DragGesture()
                                    .onChanged({ val in
                                        if(val.translation.height >= 0) {
                                            viewStore.send(.setOffset(newY: val.translation.height))
                                        }
                                    })
                                        .onEnded({ val in
                                            if val.translation.height > 200 {
                                                isShowing = false
                                            }
                                            viewStore.send(.setOffset(newY: 0))
                                        })
                                )
                            content
                                .offset(x: viewStore.fromRight ? viewStore.offsetY : 0,y: viewStore.fromRight ? 0 : viewStore.offsetY)
                                .animation(.spring(response: 0.3), value: viewStore.offsetY)
                                .transition(.move(edge: viewStore.fromRight ? .trailing : .bottom))
                                .background(
                                    Color(.clear)
                                )
                                .overlay(alignment: viewStore.fromRight ? .leading : .top) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(hex: Colors.Outline.dark))
                                            .frame(maxWidth: viewStore.fromRight ? 4 : 32, maxHeight: viewStore.fromRight ? 32 : 4)
                                            .offset(x: viewStore.fromRight ? viewStore.offsetY : 0,y: viewStore.fromRight ? 0 : viewStore.offsetY)
                                            .animation(.spring(response: 0.3), value: viewStore.offsetY)
                                            .padding(.top, viewStore.fromRight ? 0 : 16)
                                            .padding(.leading, viewStore.fromRight ? 16 : 0)
                                    }
                                    .frame(maxWidth: viewStore.fromRight ? nil : .infinity, maxHeight: viewStore.fromRight ? .infinity : nil)
                                    .contentShape(Rectangle())
                                    .gesture(DragGesture()
                                        .onChanged({ val in
                                            if (viewStore.fromRight ? val.translation.width : val.translation.height) >= 0 {
                                                viewStore.send(.setOffset(newY: viewStore.fromRight ? val.translation.width : val.translation.height))
                                            }
                                        })
                                            .onEnded({ val in
                                                if (viewStore.fromRight ? val.translation.width : val.translation.height) > 200 {
                                                    isShowing = false
                                                }
                                                viewStore.send(.setOffset(newY: 0))
                                            })
                                    )
                                }
                                .cornerRadius(20, corners: viewStore.fromRight ? [.topLeft, .bottomLeft] : [.topLeft, .topRight])
                                .clipped(antialiased: true)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea()
                    .animation(.spring(response: 0.3), value: isShowing)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
    }
}

struct CustomBottomSheetPreviewBridge: View {
    let store: StoreOf<CustomBottomSheetDomain> = Store(
        initialState: CustomBottomSheetDomain.State(),
        reducer: CustomBottomSheetDomain()
    )
    
    let selectorStore: StoreOf<ModuleSelectorDomain> = Store(
        initialState: ModuleSelectorDomain.State(),
        reducer: ModuleSelectorDomain()
    )
    
    @State var isShowing = true
    var body: some View {
        BottomSheet(
            store: self.store,
            isShowing: $isShowing,
            content: AnyView(
                ModuleSelector(
                    store: self.selectorStore
                )
            )
        )
    }
}

struct CustomBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        CustomBottomSheetPreviewBridge()
    }
}
