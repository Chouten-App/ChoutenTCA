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
            VStack(alignment: .leading) {
                Text(globalData.getModule()?.name ?? "No Module")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.vertical)
                
                ScrollView {
                    VStack {
                        ForEach(0..<viewStore.availableModules.count, id: \.self) { index in
                            ModuleSelectorButton(
                                store: Store(
                                    initialState: ModuleSelectorButtonDomain.State(module: viewStore.availableModules[index]),
                                    reducer: ModuleSelectorButtonDomain()
                                )
                            )
                        }
                    }
                    .padding(.bottom)
                }
            }
            .foregroundColor(Color(hex: Colors.onPrimaryContainer.dark))
            .padding(.horizontal, 16)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding(.bottom, 88)
            .background(.regularMaterial)
            .onAppear {
                print("APPEARING")
                viewStore.send(.setAvailableModules)
            }
        }
    }
}

struct ModuleSelector_Previews: PreviewProvider {
    static var previews: some View {
        ModuleSelector(
            store: Store(
                initialState: ModuleSelectorDomain.State(),
                reducer: ModuleSelectorDomain()
            ),
            showModules: .constant(false)
        )
    }
}
