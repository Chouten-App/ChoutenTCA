//
//  SwiftUIView.swift
//
//
//  Created by Inumaki on 19.10.23.
//

import SwiftUI
import Architecture
import ComposableArchitecture
import ModuleClient
import Kingfisher
import SharedModels

extension ModuleSheetFeature.View: View {
    public var body: some View {
        WithViewStore(store, observe: \.`self`) { viewStore in
            GeometryReader { proxy -> AnyView in
                let height = proxy.frame(in: .global).height
                
                return AnyView(
                    VStack {
                        // Title bar
                        HStack {
                            let module = ModuleClient.selectedModule
                            
                            if let module {
                                Text(module.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            } else {
                                Text("No Module Selected")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(.regularMaterial)
                        
                        ScrollView {
                            VStack {
                                ModuleList(type: "Video", viewStore.availableModules, viewStore: viewStore)
                                
                                ModuleList(type: "Book", viewStore.availableModules, viewStore: viewStore)
                                
                                ModuleList(type: "Text", viewStore.availableModules, viewStore: viewStore)
                            }
                        }
                        .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(.regularMaterial)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .overlay(alignment: .top) {
                        ZStack {
                            Color.clear
                            
                            RoundedRectangle(cornerRadius: 4)
                                .frame(
                                    maxWidth: 40,
                                    maxHeight: 6
                                )
                                .padding(.top, 4)
                                .padding(.leading, 0)
                        }
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: 20
                        )
                        .contentShape(Rectangle())
                    }
                    .offset(y: height - minimum)
                    .offset(y: viewStore.offset)
                //.animation(.easeInOut, value: viewStore.animate)
                    .gesture(
                        DragGesture()
                            .updating($gestureOffset) { value, out, _ in
                                out = value.translation.height
                                
                                let ret = onChange(offset: viewStore.offset, lastOffset: viewStore.tempOffset)
                                if let ret {
                                    viewStore.send(.view(.setOffset(value: ret)))
                                }
                            }
                            .onEnded { value in
                                //viewStore.send(.setAnimate(true))
                                let maxHeight = height - minimum
                                
                                if -viewStore.offset > minimum && -viewStore.offset < maxHeight / 2 {
                                    // MID
                                    viewStore.send(.view(.setOffset(value:  -(maxHeight / 3))), animation: .easeInOut)
                                } else if -viewStore.offset > maxHeight / 2 {
                                    viewStore.send(.view(.setOffset(value:  -maxHeight)), animation: .easeInOut)
                                } else {
                                    viewStore.send(.view(.setOffset(value:  0)), animation: .easeInOut)
                                }
                                
                                //viewStore.send(.setAnimate(false))
                                
                                viewStore.send(.view(.setTempOffset(value: viewStore.offset)))
                            }
                    )
                )
            }
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height - 64, alignment: .bottom)
            .clipped()
            .ignoresSafeArea(.all, edges: .bottom)
            .onAppear {
                viewStore.send(.view(.onAppear))
            }
        }
    }
}

extension ModuleSheetFeature.View {
    @MainActor
    func ModuleList(type: String, _ availableModules: [Module], viewStore: ViewStoreOf<ModuleSheetFeature>) -> some View {
        VStack {
            let filteredModules = availableModules.filter({ $0.type == type })
            Text(type)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            
            if filteredModules.count > 0 {
                VStack {
                    ForEach(0..<filteredModules.count, id: \.self) { index in
                        let module = filteredModules[index]
                        
                        ModuleButton(module: module, viewStore: viewStore)
                        
                        /*
                         ModuleSelectorButton(
                         store: Store(
                         initialState: ModuleSelectorButtonDomain.State(module: filteredModules[index]),
                         reducer: ModuleSelectorButtonDomain()
                         )
                         )
                         */
                    }
                }
                .padding(.bottom)
                .padding(.horizontal, 8)
            } else {
                VStack(spacing: 20) {
                    Text("(ㅠ﹏ㅠ)")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("No \(type) Modules are installed...")
                        .font(.subheadline)
                        .opacity(0.7)
                }
                .padding(.vertical, 30)
            }
        }
    }
    
    @MainActor
    func ModuleButton(module: Module, viewStore: ViewStoreOf<ModuleSheetFeature>) -> some View {
        Button {
            viewStore.send(.view(.setModule(module: module)))
            /*
             viewStore.send(.loadModule)
             viewStore.send(.resetData)
             if userInfo.count > 0 {
             userInfo[0].selectedModuleId = viewStore.module.id
             try! moc.save()
             print("saved")
             } else {
             let info = UserInfo(context: moc)
             info.selectedModuleId = viewStore.module.id
             try! moc.save()
             print("saved2")
             }
             */
        } label: {
            HStack(alignment: .center) {
                if module.icon != nil {
                    KFImage(URL(string: module.icon!))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .cornerRadius(12)
                } else {
                    ZStack {
                        Color(.white).opacity(0.6)
                            .blur(radius: 6)
                        
                        Image(systemName: "questionmark")
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .foregroundColor(.indigo)
                    }
                    .fixedSize()
                    .cornerRadius(40)
                }
                
                VStack(alignment: .leading) {
                    Text(module.name)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    HStack {
                        Text(module.general.author)
                            .opacity(0.7)
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                        Text("v\(module.version)")
                            .opacity(0.7)
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    // open popup
                    //showPopover = true
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(12)
                        .foregroundColor(
                            .white
                        )
                        .background {
                            Circle()
                                .fill(
                                    .indigo
                                )
                        }
                }
                
            }
            .padding(12)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .topLeading
        )
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(
            .indigo
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        ModuleSheetFeature.View(
            store: .init(
                initialState: .init(),
                reducer: { ModuleSheetFeature() }
            )
        )
        
        Rectangle()
            .fill(.regularMaterial)
            .frame(height: 80)
            .background(.regularMaterial)
            .ignoresSafeArea()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
