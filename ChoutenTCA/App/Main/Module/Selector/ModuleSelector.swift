//
//  ModuleSelector.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import SwiftUI
import ComposableArchitecture
import UIKit
import Combine

protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}

struct ModuleSelector: View, KeyboardReadable {
    let store: StoreOf<ModuleSelectorDomain>
    @Binding var showModules: Bool
    @StateObject var Colors = DynamicColors.shared
    @FocusState var isFocused: Bool
    @FocusState var isNameFocused: Bool
    @State private var isKeyboardVisible: Bool = false
    
    @Dependency(\.globalData) var globalData
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                Text(globalData.getModule()?.name ?? "No Module")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .padding(.horizontal, 16)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial)
                
                ScrollView {
                    ModuleList(type: "Video", viewStore.availableModules)
                    
                    ModuleList(type: "Book", viewStore.availableModules)
                    
                    ModuleList(type: "Text", viewStore.availableModules)
                    
                }
                .padding(.top, 20)
            }
            .foregroundColor(Color(hex: Colors.onPrimaryContainer.dark))
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .background(.regularMaterial)
            .onAppear {
                print("APPEARING")
                viewStore.send(.setAvailableModules)
            }
        }
    }
    
    @ViewBuilder
    func ModuleList(type: String, _ availableModules: [Module]) -> some View {
        VStack {
            let filteredModules = availableModules.filter({ $0.type == type })
            Text(type)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            if filteredModules.count > 0 {
                VStack {
                    ForEach(0..<filteredModules.count, id: \.self) { index in
                        ModuleSelectorButton(
                            store: Store(
                                initialState: ModuleSelectorButtonDomain.State(module: filteredModules[index]),
                                reducer: ModuleSelectorButtonDomain()
                            )
                        )
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
}

struct ModuleSelector_Previews: PreviewProvider {
    static var previews: some View {
        ModuleSelector(
            store: Store(
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
            ),
            showModules: .constant(false)
        )
    }
}
