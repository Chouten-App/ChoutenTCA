//
//  Seekbar.swift
//  ChoutenTCA
//
//  Created by Inumaki on 30.05.23.
//

import SwiftUI

struct Seekbar: View {
    @Binding var percentage: Double // or some value binded
    @Binding var buffered: Double
    @Binding var isDragging: Bool
    var total: Double
    @Binding var isMacos: Bool
    @State var barHeight: CGFloat = 6
    
    @StateObject var Colors = DynamicColors.shared
    
    
    var body: some View {
        GeometryReader { geometry in
            // TODO: - there might be a need for horizontal and vertical alignments
            ZStack(alignment: .bottomLeading) {
                
                Capsule()
                    .foregroundColor(.white.opacity(0.4)).frame(height: barHeight, alignment: .bottom).cornerRadius(12)
                
                Capsule()
                    .foregroundColor(.white.opacity(0.4))
                    .frame(
                        maxWidth: geometry.size.width
                    )
                    .frame(height: barHeight, alignment: .bottom)
                    .offset(
                        x: -geometry.size.width + (
                            geometry.size.width
                            * CGFloat(self.buffered / total)
                            )
                        )
                
                Capsule()
                    .foregroundColor(Color(hex: Colors.Primary.dark))
                    .frame(
                        maxWidth: geometry.size.width
                    )
                    .frame(height: barHeight, alignment: .bottom)
                    .offset(
                        x: -geometry.size.width + (
                            geometry.size.width
                            * CGFloat(self.percentage / total)
                            )
                        )
            }
            .frame(height: barHeight)
            .cornerRadius(400)
            .frame(maxHeight: .infinity, alignment: .center)
            .clipped(antialiased: true)
            .overlay {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                                self.isDragging = false
                                self.barHeight = isMacos ? 12 : 6
                            }
                            .onChanged{ value in
                                self.isDragging = true
                                self.barHeight = isMacos ? 18 : 10
                                // TODO: - maybe use other logic here
                                self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                            }
                    )
            }
            .animation(.spring(response: 0.3), value: self.isDragging)
        
        }
    }
}

struct Seekbar_Previews: PreviewProvider {
    static var previews: some View {
        Seekbar(percentage: .constant(0.2), buffered: .constant(0.5), isDragging: .constant(false), total: 1.0, isMacos: .constant(false))
            .preferredColorScheme(.dark)
    }
}
