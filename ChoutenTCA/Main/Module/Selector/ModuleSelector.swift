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
    @StateObject var Colors = DynamicColors.shared
    @FocusState var isFocused: Bool
    @FocusState var isNameFocused: Bool
    @FocusState var isKeyboardVisible: Bool
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .center) {
                Text("Module Selector")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.top, 40)
                    .padding(.bottom, 4)
                
                Text("Select one of the modules below to provide this app with data:")
                    .font(.system(size: 16, weight: .bold))
                    .opacity(0.7)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                
                VStack {
                    VStack {
                        if !viewStore.importPressed {
                            HStack {
                                ZStack {
                                    Image(systemName: "arrow.down")
                                        .font(.system(size: 16, weight: .heavy))
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 14)
                                        .foregroundColor(
                                            Color(hex:Colors.onPrimaryContainer.dark)
                                        )
                                }
                                .fixedSize()
                                .cornerRadius(40)
                                
                                VStack(alignment: .leading) {
                                    Text("Import \(viewStore.isModule ? "Module" : "Theme")")
                                        .foregroundColor(Color(hex:Colors.onPrimaryContainer.dark))
                                        .font(.system(size: 16, weight: .bold))
                                        .lineLimit(1)
                                    
                                    HStack {
                                        Text("Import \(viewStore.isModule ? "Module" : "Theme") from URL")
                                            .foregroundColor(Color(hex:Colors.onPrimaryContainer.dark).opacity(0.7))
                                            .font(.system(size: 12, weight: .semibold))
                                            .lineLimit(1)
                                        
                                    }
                                }
                                .frame(minHeight: 120)
                            }
                            .padding(.leading, 20)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                            .onTapGesture {
                                viewStore.send(.setImportedPressed(newValue: true))
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    ZStack {
                                        Image(systemName: "arrow.down")
                                            .font(.system(size: 16, weight: .heavy))
                                            .padding(.trailing, 6)
                                            .foregroundColor(Color(hex:Colors.onPrimaryContainer.dark))
                                    }
                                    .fixedSize()
                                    .cornerRadius(40)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Import \(viewStore.isModule ? "Module" : "Theme")")
                                            .foregroundColor(Color(hex:Colors.onPrimaryContainer.dark))
                                            .font(.system(size: 20, weight: .bold))
                                            .lineLimit(1)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 20)
                                .onTapGesture {
                                    viewStore.send(.setImportedPressed(newValue: false))
                                }
                                
                                Text("Import \(viewStore.isModule ? "Module" : "Theme") or a Repo from a URL. Please make sure you trust the URL.")
                                    .foregroundColor(Color(hex:Colors.onPrimaryContainer.dark).opacity(0.7))
                                    .font(.system(size: 12, weight: .semibold))
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 20)
                                
                                // Segemented Button
                                HStack {
                                    HStack(spacing: 8) {
                                        Spacer()
                                        if viewStore.isModule {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14))
                                        }
                                        Text("Module")
                                            .font(.system(size: 14))
                                        Spacer()
                                    }
                                    .foregroundColor(
                                        viewStore.isModule ? Color(hex:Colors.onSecondaryContainer.dark)
                                        : Color(hex:Colors.onSurface.dark)
                                        
                                    )
                                    .frame(height: 40)
                                    .background {
                                        viewStore.isModule ? Color(hex:Colors.SecondaryContainer.dark) : Color(hex:Colors.SurfaceContainer.dark)
                                    }
                                    .overlay(alignment: .trailing) {
                                        Rectangle()
                                            .fill(Color(hex:Colors.Outline.dark))
                                            .frame(width: 1, height: 40)
                                    }
                                    .onTapGesture {
                                        viewStore.send(.setIsModule(newValue: true))
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Spacer()
                                        if !viewStore.isModule {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14))
                                        }
                                        Text("Theme")
                                            .font(.system(size: 14))
                                        Spacer()
                                    }
                                    .foregroundColor(
                                        !viewStore.isModule ? Color(hex:Colors.onSecondaryContainer.dark) : Color(hex:Colors.onSurface.dark)
                                    )
                                    .frame(height: 40)
                                    .background {
                                        !viewStore.isModule ? Color(hex:Colors.SecondaryContainer.dark) : Color(hex:Colors.SurfaceContainer.dark)
                                    }
                                    .overlay(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color(hex:Colors.Outline.dark))
                                            .frame(width: 1, height: 40)
                                    }
                                    .onTapGesture {
                                        viewStore.send(.setIsModule(newValue: false))
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                                .cornerRadius(40)
                                .overlay {
                                    Capsule()
                                        .stroke(Color(hex:Colors.Outline.dark), lineWidth: 1)
                                }
                                .padding(.bottom, 20)
                                
                                TextField("", text: viewStore.binding(
                                    get: \.fileUrl,
                                    send: ModuleSelectorDomain.Action.setFileUrl(newUrl:)
                                ))
                                .disableAutocorrection(true)
                                .focused($isFocused)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(lineWidth: 1)
                                        .fill(isFocused ? Color(hex:Colors.Primary.dark) : Color(hex:Colors.Outline.dark)
                                        )
                                }
                                .overlay(alignment: .leading) {
                                    Text("Import from URL")
                                        .padding(.horizontal, isFocused ? 4 : 0)
                                        .foregroundColor(
                                            isFocused ? Color(hex:Colors.Primary.dark) : Color(hex:Colors.onSurfaceVariant.dark)
                                        )
                                        .font(isFocused ? .caption : .subheadline)
                                        .background {
                                            Color(hex:Colors.SurfaceContainer.dark)
                                        }
                                        .offset(y: isFocused ? -22 : 0)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            isFocused = true
                                        }
                                        .animation(.easeInOut, value: isFocused)
                                }
                                .padding(.bottom, 20)
                                
                                HStack {
                                    TextField("\(!viewStore.fileUrl.isEmpty ? (URL(string: viewStore.fileUrl)?.lastPathComponent ?? "") : "")", text: viewStore.binding(
                                        get: \.filename,
                                        send: ModuleSelectorDomain.Action.setFilename(newName:)
                                    ))
                                    .disableAutocorrection(true)
                                    .focused($isNameFocused)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(lineWidth: 1)
                                            .fill(isNameFocused ? Color(hex:Colors.Primary.dark) : Color(hex:Colors.Outline.dark)
                                            )
                                    }
                                    .overlay(alignment: .leading) {
                                        Text("Filename")
                                            .padding(.horizontal, isNameFocused ? 4 : 0)
                                            .foregroundColor(
                                                isNameFocused ? Color(hex:Colors.Primary.dark) : Color(hex:Colors.onSurfaceVariant.dark)
                                            )
                                            .font(isNameFocused ? .caption : .subheadline)
                                            .background {
                                                Color(hex:Colors.SurfaceContainer.dark)
                                            }
                                            .offset(y: isNameFocused ? -22 : 0)
                                            .padding(.horizontal, 16)
                                            .onTapGesture {
                                                isNameFocused = true
                                            }
                                            .animation(.easeInOut, value: isNameFocused)
                                    }
                                    
                                }
                                .padding(.bottom, 24)
                                
                                HStack {
                                    Spacer()
                                    
                                    Text("Cancel")
                                        .font(.system(size: 14))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .foregroundColor(
                                            Color(hex:Colors.Primary.dark)
                                        )
                                        .background {
                                            Capsule()
                                                .fill(.clear)
                                        }
                                        .onTapGesture {
                                            viewStore.send(.setImportedPressed(newValue: false))
                                        }
                                    
                                    Button {
                                        
                                    } label: {
                                        Text("Import")
                                            .font(.system(size: 14, weight: .semibold))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .foregroundColor(
                                                Color(hex:Colors.onPrimary.dark)
                                            )
                                            .background {
                                                Capsule()
                                                    .fill(
                                                        Color(hex:Colors.Primary.dark)
                                                    )
                                            }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                    .background(.clear)
                    .cornerRadius(12)
                    .frame(height: viewStore.importPressed ? 354 : viewStore.buttonHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [7]))
                    )
                    .animation(.easeInOut, value: viewStore.importPressed)
                    
                    ForEach(
                        Array(
                            zip(
                                viewStore.availableModules.indices, viewStore.availableModules
                            )
                        ),
                        id: \.0) { index, module in
                            ModuleSelectorButton(
                                store: Store(
                                    initialState: ModuleSelectorButtonDomain.State(module: module),
                                    reducer: ModuleSelectorButtonDomain()
                                )
                            )
                    }
                }
                .padding(.bottom, 15)
                
                Divider()
                    .foregroundColor(
                        Color(hex:Colors.OutlineVariant.dark)
                    )
            }
            .foregroundColor(Color(hex: Colors.onPrimaryContainer.dark))
            .padding(.horizontal, 16)
            .padding(.bottom, isKeyboardVisible ? 300 : 20)
            .frame(maxWidth: UIScreen.main.bounds.width > 600 ? 400 : .infinity, maxHeight: UIScreen.main.bounds.width > 600 ? .infinity : nil, alignment: .top)
            .background {
                Color(hex: Colors.SurfaceContainer.dark)
            }
            .onReceive(keyboardPublisher) { newIsKeyboardVisible in
                isKeyboardVisible = newIsKeyboardVisible
            }
            .onAppear {
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
            )
        )
    }
}
