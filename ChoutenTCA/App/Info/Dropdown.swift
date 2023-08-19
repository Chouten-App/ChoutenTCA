//
//  Dropdown.swift
//  ChoutenTCA
//
//  Created by Inumaki on 07.06.23.
//

import SwiftUI

struct Dropdown: View {
    let options: [String]
    @Binding var selectedOption: Int
    
    @State var open: Bool = false
    
    @StateObject var Colors = DynamicColors.shared
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "folder.fill")
                    .font(.headline)
                
                Text("\(options[selectedOption])")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.vertical, 12)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .scaleEffect(y: open ? -1 : 1)
            }
            .foregroundColor(Color(hex: Colors.onPrimary.dark))
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: 56, alignment: .leading)
            .background {
                Color(hex: Colors.Primary.dark)
                .cornerRadius(8, corners: open ? [.topLeft, .topRight] : [.topLeft, .topRight, .bottomLeft, .bottomRight])
                .animation(.spring(response: 0.3), value: open)
            }
            .onTapGesture {
                open.toggle()
            }
            .overlay(alignment: .top) {
                ScrollView {
                    VStack {
                        ForEach(0..<options.count) { index in
                            DropdownItem(
                                Colors: Colors,
                                option: options[index],
                                selected: selectedOption == index
                            )
                            .onTapGesture {
                                selectedOption = index
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(height: CGFloat(options.count * 56 + 16) > 400 ? 400 : CGFloat(options.count * 56 + 16))
                .frame(maxHeight: 400)
                .background(
                    Color(hex: Colors.SurfaceContainer.dark)
                    .cornerRadius(4, corners: [.bottomLeft, .bottomRight])
                    .animation(.spring(response: 0.3), value: open)
                ).shadow(color: Color(hex: Colors.Scrim.dark).opacity(0.08), radius: 2, x: 0, y: 0)
                .shadow(color: Color(hex: Colors.Scrim.dark).opacity(0.16), radius: 24, x: 0, y: 0)
                .scaleEffect(y: open ? 1 : 0, anchor: .top)
                .animation(.easeInOut(duration: 0.1), value: open)
                .padding(.top, 56)
            }
        }
        .foregroundColor(Color(hex: Colors.onSurface.dark))
        .animation(.spring(response: 0.3), value: open)
    }
}

struct DropdownItem: View {
    @StateObject var Colors = DynamicColors.shared
    let option: String
    var selected = false
    
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Text(option)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .background(
                Color(hex: Colors.onSurface.dark)
                    .opacity(selected ? 0.12 : 0.0)
            )
    }
}

struct Dropdown_Previews: PreviewProvider {
    static var previews: some View {
        Dropdown(options: [], selectedOption: .constant(0))
    }
}
