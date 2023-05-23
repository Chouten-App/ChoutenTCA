//
//  FloatyDisplay.swift
//  ModularSaikouS
//
//  Created by Inumaki on 20.04.23.
//

import SwiftUI
import ComposableArchitecture

struct FloatyAction: Equatable {
    static func == (lhs: FloatyAction, rhs: FloatyAction) -> Bool {
        return
            lhs.actionTitle == rhs.actionTitle &&
        lhs.action() == rhs.action()
    }
    
    let actionTitle: String
    let action: (() -> Void)
}

struct FloatyData: Equatable {
    var message: String
    let error: Bool
    var action: FloatyAction?
}

struct FloatyDisplay: View {
    let store: StoreOf<FloatyDomain>
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack(spacing: 0) {
                Text(viewStore.message)
                    .font(.system(size: 15))
                    .foregroundColor(
                        viewStore.error ? Color(hex: Colors.onError.dark) : Color(hex: Colors.onSurface.dark)
                    )
                    .lineLimit(8)
                    .onTapGesture {
                        UIPasteboard.general.setValue(viewStore.message, forPasteboardType: "public.plain-text")
                    }
                Spacer()
                if viewStore.action != nil {
                    Text(viewStore.action!.actionTitle)
                        .padding(8)
                        .onTapGesture(perform: viewStore.action!.action)
                        .foregroundColor(viewStore.error ? Color(hex: Colors.onErrorContainer.dark) : Color(hex: Colors.onPrimaryContainer.dark)
                        )
                }
                if viewStore.action == nil {
                    Image(systemName: "xmark")
                        .foregroundColor(viewStore.error ? Color(hex: Colors.onError.dark) : Color(hex: Colors.onSurface.dark))
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            viewStore.send(.setFloatyBool(newValue: false))
                        }
                }
            }
            .padding(16)
            .background(viewStore.error ? Color(hex: Colors.Error.dark).cornerRadius(12) : Color(hex:Colors.SurfaceContainer.dark).cornerRadius(12))
            .shadow(color: Color(hex: Colors.Scrim.dark).opacity(0.08), radius: 2, x: 0, y: 0)
            .shadow(color: Color(hex: Colors.Scrim.dark).opacity(0.16), radius: 24, x: 0, y: 0)
            .padding(.horizontal, 16)
            
        }
        
    }
}

struct FloatyDisplay_Previews: PreviewProvider {
    static var previews: some View {
        FloatyDisplay(
            store: Store(
                initialState: FloatyDomain.State(),
                reducer: FloatyDomain()
            )
        )
    }
}
