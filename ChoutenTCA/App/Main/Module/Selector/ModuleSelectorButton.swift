//
//  ModuleSelectorButton.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import ComposableArchitecture
import Kingfisher
import SwiftUI

struct ModuleSelectorButton: View {
    let store: StoreOf<ModuleSelectorButtonDomain>
    @StateObject var Colors = DynamicColors.shared
    
    @FetchRequest(sortDescriptors: []) var userInfo: FetchedResults<UserInfo>
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
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
                
                Button {
                    viewStore.send(.loadModule)
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
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            if viewStore.module.icon != nil {
                                KFImage(URL(string: viewStore.module.icon!))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(
                                        minWidth: 40,
                                        maxWidth: 40,
                                        minHeight: 40,
                                        maxHeight: 40
                                    )
                                    .cornerRadius(12)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: Colors.Outline.dark), lineWidth: 1)
                                    }
                            } else {
                                ZStack {
                                    Color(.white).opacity(0.6)
                                        .blur(radius: 6)
                                    
                                    Image(systemName: "questionmark")
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 14)
                                        .foregroundColor(Color(hex: Colors.Primary.dark))
                                }
                                .fixedSize()
                                .cornerRadius(40)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(viewStore.module.name)
                                    .foregroundColor(
                                        Color(hex: viewStore.module.general.fgColor)
                                    )
                                    .font(.system(size: 16, weight: .bold))
                                    .lineLimit(1)
                                
                                HStack {
                                    Text(viewStore.module.general.author ?? "Unknown")
                                        .foregroundColor(Color(hex: viewStore.module.general.fgColor).opacity(0.7))
                                        .font(.system(size: 12, weight: .semibold))
                                        .lineLimit(1)
                                    Text("v\(viewStore.module.version)")
                                        .foregroundColor(Color(hex: viewStore.module.general.fgColor).opacity(0.7))
                                        .font(.system(size: 12, weight: .semibold))
                                }
                            }
                            .frame(minHeight: 52, alignment: .center)
                        }
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 52,
                    maxHeight: 52,
                    alignment: .topLeading
                )
                .buttonStyle(PlainButtonStyle())
                .background(Color(hex: viewStore.module.general.bgColor))
                .cornerRadius(viewStore.cornerRadius)
                .overlay {
                    RoundedRectangle(cornerRadius: viewStore.cornerRadius)
                        .stroke(
                            Color(.black),
                            lineWidth: viewStore.isSelected ? 2 : 0
                        )
                        .hueRotation(.degrees(30))
                }
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
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 52,
                maxHeight: 52,
                alignment: .topLeading
            )
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
