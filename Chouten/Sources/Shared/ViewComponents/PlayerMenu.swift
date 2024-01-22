//
//  SwiftUIView.swift
//  
//
//  Created by Inumaki on 18.10.23.
//

import SwiftUI

enum MenuState {
    case main
    case speed
    case quality
    case server
}

public struct PlayerMenu: View {
    @Binding var selectedQuality: String
    @Binding var selectedServer: String
    @Binding var selectedSpeed: Float
    @State var state: MenuState = .main
    var qualities: [String]
    var servers: [String]
    var speeds: [Float]
    
    @Namespace var animation
    
    public init(
        selectedQuality: Binding<String>,
        selectedServer: Binding<String>,
        selectedSpeed: Binding<Float>,
        qualities: [String],
        servers: [String],
        speeds: [Float]
    ) {
        self._selectedQuality = selectedQuality
        self._selectedServer = selectedServer
        self._selectedSpeed = selectedSpeed
        self.qualities = qualities
        self.servers = servers
        self.speeds = speeds
    }
    
    public var body: some View {
        ZStack {
            switch state {
            case .main:
                VStack(spacing: 20) {
                    HStack {
                        Text("Quality")
                            .fontWeight(.semibold)
                            .matchedGeometryEffect(id: "Quality", in: animation)
                        
                        Text(selectedQuality)
                            .font(.subheadline)
                            .opacity(0.7)
                        
                        Spacer()
                        
                        Image(systemName: "rectangle.stack.fill")
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        state = .quality
                    }
                    
                    HStack {
                        Text("Speed")
                            .fontWeight(.semibold)
                            .matchedGeometryEffect(id: "Speed", in: animation)
                        
                        Text("\(selectedSpeed, specifier: "%0.2f")x")
                            .font(.subheadline)
                            .opacity(0.7)
                        
                        Spacer()
                        
                        Image(systemName: "speedometer")
                    }
                    .onTapGesture {
                        state = .speed
                    }
                    
                    HStack {
                        Text("Server")
                            .fontWeight(.semibold)
                            .matchedGeometryEffect(id: "Server", in: animation)
                        
                        Text(selectedServer)
                            .font(.subheadline)
                            .lineLimit(1)
                            .opacity(0.7)
                        
                        Spacer()
                        
                        Image(systemName: "server.rack")
                    }
                    .onTapGesture {
                        state = .server
                    }
                }
                .padding(.horizontal)
                .frame(width: 240, alignment: .leading)
            case .quality:
                SubMenu<String>(state: $state, label: "Quality", items: qualities, selected: $selectedQuality, animation: animation)
            case .speed:
                SubMenu<Float>(state: $state, label: "Speed", items: speeds, selected: $selectedSpeed, animation: animation)
            case .server:
                SubMenu<String>(state: $state, label: "Server", items: servers, selected: $selectedServer, animation: animation)
            }
        }
        .padding()
        .frame(maxHeight: UIScreen.main.bounds.height - 120, alignment: .trailing)
        .fixedSize(horizontal: false, vertical: true)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .frame(width: 240, alignment: .leading)
        }
        .offset(x: state == .main ? 0 : 10)
        .animation(.spring(response: 0.3), value: state)
    }
}

struct SubMenu<T: Equatable>: View {
    @Binding var state: MenuState
    let label: String
    let items: [T]
    @Binding var selected: T
    let animation: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "chevron.left")
                
                Text(label)
                    .fontWeight(.semibold)
                    .matchedGeometryEffect(id: label, in: animation)
            }
            .padding(.horizontal, 26)
            .contentShape(Rectangle())
            .onTapGesture {
                state = .main
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(items.indices, id: \.self) { index in
                        let item = items[index]
                        MenuItem(label: item as? String ?? "\(item)", selected: item == selected)
                            .onTapGesture {
                                selected = item
                            }
                    }
                }
                .padding(.vertical, 16)
            }
        }
    }
}

struct MenuItem: View {
    let label: String
    var selected: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(selected ? .semibold : .regular)
            
            if selected {
                Spacer()
                
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
            }
        }
        .padding(.horizontal, selected ? 16 : 0)
        .padding(.vertical, selected ? 10 : 0)
        .frame(width: 260, alignment: .leading)
        .foregroundColor(selected ? .black : .white)
        .background {
            RoundedRectangle(cornerRadius: selected ? 12 : 0)
                .fill(selected ? .white : .clear)
        }
        .padding(.vertical, selected ? -12 : 0)
        .offset(x: selected ? 0 : 26)
        .animation(.spring(response: 0.3), value: selected)
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        RoundedRectangle(cornerRadius: 12)
            .fill(.red)
            .frame(width: 120)
        
        PlayerMenu(
            selectedQuality: .constant("Auto"),
            selectedServer: .constant("Vidstreaming (Sub)"),
            selectedSpeed: .constant(1.0),
            qualities: ["Auto", "1080p", "720p", "480p", "240p"],
            servers: ["Vidstreaming (Sub)", "Vidstreaming (Dub)", "Vizcloud (Sub)", "Vizcloud (Dub)"],
            speeds: [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
}
