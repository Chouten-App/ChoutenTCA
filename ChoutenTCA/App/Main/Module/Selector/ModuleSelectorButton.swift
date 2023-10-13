//
//  ModuleSelectorButton.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct ModuleSelectorButton: View {
    let store: StoreOf<ModuleSelectorButtonDomain>
    @StateObject var Colors = DynamicColors.shared
    @Dependency(\.globalData) var globalData
    
    @FetchRequest(sortDescriptors: []) var userInfo: FetchedResults<UserInfo>
    @Environment(\.managedObjectContext) var moc
    
    @State var showPopover = false
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                /*
                Color(hex: Colors.Error.dark)
                    .cornerRadius(viewStore.cornerRadius)
                            
                // Delete Button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        viewStore.send(.deleteModule)
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(
                                Color(hex: Colors.onError.dark)
                            )
                            .frame(width: 90, height: 50)
                    }
                }
                */
                Button {
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
                } label: {
                    HStack(alignment: .center) {
                        if viewStore.module.icon != nil {
                            KFImage(URL(string: viewStore.module.icon!))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(
                                    minWidth: viewStore.showDetails ? 52 : 40,
                                    maxWidth: viewStore.showDetails ? 52 : 40,
                                    minHeight: viewStore.showDetails ? 52 : 40,
                                    maxHeight: viewStore.showDetails ? 52 : 40
                                )
                                .cornerRadius(12)
                        } else {
                            ZStack {
                                Color(.white).opacity(0.6)
                                    .blur(radius: 6)
                                
                                Image(systemName: "questionmark")
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 14)
                                    .foregroundColor(
                                        Color(hex:
                                                Colors.getColor(
                                                    for: "Primary",
                                                    colorScheme: globalData.getColorScheme()
                                                )
                                             )
                                    )
                            }
                            .fixedSize()
                            .cornerRadius(40)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(viewStore.module.name)
                                .font(.system(size: viewStore.showDetails ? 20 : 16, weight: .bold))
                                .lineLimit(1)
                            
                            HStack {
                                Text(viewStore.module.general.author)
                                    .opacity(0.7)
                                    .font(.system(size: 12, weight: .semibold))
                                    .lineLimit(1)
                                Text("v\(viewStore.module.version)")
                                        .opacity(0.7)
                                        .font(.system(size: 12, weight: .semibold))
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            // open popup
                            showPopover = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .padding(12)
                                .foregroundColor(
                                    Color(hex:
                                            Colors.getColor(
                                                for: "onPrimary",
                                                colorScheme: globalData.getColorScheme()
                                            )
                                         )
                                )
                                .background {
                                    Circle()
                                        .fill(
                                            Color(hex:
                                                    Colors.getColor(
                                                        for: "Primary",
                                                        colorScheme: globalData.getColorScheme()
                                                    )
                                                 )
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
                    Color(hex:
                            Colors.getColor(
                                for: "onSurface",
                                colorScheme: globalData.getColorScheme()
                            )
                         )
                )
                /*
                .background(
                    /*
                    Color(hex:
                            Colors.getColor(
                                for: "SurfaceContainer",
                                colorScheme: globalData.getColorScheme()
                            )
                         )
                     */
                )
                 */
                .cornerRadius(viewStore.cornerRadius)
                .offset(x: viewStore.offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            viewStore.send(.onChanged(value: value))
                        }
                        .onEnded { value in
                            viewStore.send(.onEnded(value: value))
                        }
                )
            }
            .frame(
                maxWidth: .infinity,
                alignment: .topLeading
            )
        }
        .popover(isPresented: $showPopover) {
            Text("CONFIG")
        }
    }
}

struct ModuleSelectorButton_Previews: PreviewProvider {
    static var previews: some View {
        ModuleSelectorButton(
            store: Store(
                initialState: ModuleSelectorButtonDomain.State(),
                reducer: ModuleSelectorButtonDomain()
            )
        )
    }
}
