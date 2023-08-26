//
//  CustomBottomSheet.swift
//  ModularSaikouS
//
//  Created by Inumaki on 18.03.23.
//

import SwiftUI
import ComposableArchitecture

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct BottomSheet: View {
    let store: StoreOf<CustomBottomSheetDomain>
    @Binding var isShowing: Bool
    var content: AnyView
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { proxy in
                content
                    .cornerRadius(
                        20,
                        corners: [.topLeft, .topRight]
                    )
                    .overlay(alignment: .top) {
                        ZStack {
                            Color.clear
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: Colors.Outline.dark))
                                .frame(
                                    maxWidth: viewStore.fromRight ? 6 : 40,
                                    maxHeight: viewStore.fromRight ? 40 : 6
                                )
                                .padding(.top, viewStore.fromRight ? 0 : 4)
                                .padding(.leading, viewStore.fromRight ? 16 : 0)
                        }
                        .frame(
                            maxWidth: viewStore.fromRight ? nil : .infinity,
                            maxHeight: 20
                        )
                        .contentShape(Rectangle())
                        
                    }
                    .frame(
                        height: max((proxy.size.height) - (viewStore.offsetY + viewStore.tempOffsetY), 20), // Minimum height of 100, adjust as needed
                        alignment: .bottom
                    )
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .animation(
                        .linear,
                        value: viewStore.offsetY
                    )
                    .clipped(antialiased: true)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea()
                    .gesture(DragGesture()
                        .onChanged { val in
                            viewStore.send(.setOffset(newY: val.translation.height))
                        }
                        .onEnded { val in
                            let height = max((proxy.size.height) - (viewStore.offsetY + viewStore.tempOffsetY), 20)
                            
                            if(height / proxy.size.height >= 0.75) {
                                // snap to top
                                viewStore.send(.setTempOffset(newY: 0))
                            } else if(height / proxy.size.height > 0.35 && height / proxy.size.height < 0.75) {
                                // snap to middle
                                viewStore.send(.setTempOffset(newY: proxy.size.height / 2 - 60))
                            } else {
                                // snap to bottom
                                viewStore.send(.setTempOffset(newY: proxy.size.height))
                            }
                            viewStore.send(.setOffset(newY: 0))
                            
                        }
                    )
                    .onAppear {
                        viewStore.send(.setTempOffset(newY: proxy.size.height))
                    }
            }
            .padding(.top, 70)
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
                    store: self.selectorStore,
                    showModules: .constant(false)
                )
            )
        )
    }
}

struct CustomBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        CustomBottomSheetPreviewBridge()
            .preferredColorScheme(.dark)
    }
}
