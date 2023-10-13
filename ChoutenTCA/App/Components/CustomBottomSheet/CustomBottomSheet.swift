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
    
    
    // TEMP
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    let minimum: CGFloat = 50
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { proxy -> AnyView in
                let height = proxy.frame(in: .global).height
                
                return AnyView(
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
                        .offset(y: height - minimum)
                        .offset(y: offset)
                        .gesture(
                            DragGesture()
                                .updating($gestureOffset) { value, out, _ in
                                    out = value.translation.height
                                    
                                    onChange()
                                }
                                .onEnded { value in
                                    let maxHeight = height - minimum
                                    
                                    withAnimation {
                                        if -offset > minimum && -offset < maxHeight / 2 {
                                            // MID
                                            offset = -(maxHeight / 3)
                                        } else if -offset > maxHeight / 2 {
                                            offset = -maxHeight
                                        } else {
                                            offset = 0
                                        }
                                    }
                                    
                                    lastOffset = offset
                                }
                        )
                )
            }
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height - 64, alignment: .bottom)
            .clipped()
            .ignoresSafeArea(.all, edges: .bottom)
            .padding(.bottom, 64)
        }
    }
    
    func onChange() {
        DispatchQueue.main.async {
            if offset < 32 {
                self.offset = gestureOffset + lastOffset
            }
        }
    }
}

struct CustomBottomSheetPreviewBridge: View {
    let store: StoreOf<CustomBottomSheetDomain> = Store(
        initialState: CustomBottomSheetDomain.State(),
        reducer: CustomBottomSheetDomain()
    )
    
    let selectorStore: StoreOf<ModuleSelectorDomain> = Store(
        initialState: ModuleSelectorDomain.State(
            loadingStatus: .success,
            availableModules: [
                Module(
                    id: "whatever",
                    type: "Video",
                    subtypes: ["video"],
                    icon: "https://i.pinimg.com/564x/e4/53/43/e4534382eccd75bed2c298065cbb2d46.jpg",
                    name: "Module Name",
                    version: "1.0.0",
                    formatVersion: 2,
                    updateUrl: "",
                    general: GeneralMetadata(
                        author: "Inumaki",
                        description: "This is a description of the Module",
                        lang: ["en"],
                        baseURL: "",
                        bgColor: "",
                        fgColor: ""
                    )
                )
            ]
        ),
        reducer: ModuleSelectorDomain()
    )
    
    @State var isShowing = true
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.red)
                .frame(width: 200, height: 320)
            
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
}

struct CustomBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        CustomBottomSheetPreviewBridge()
            .preferredColorScheme(.dark)
    }
}
