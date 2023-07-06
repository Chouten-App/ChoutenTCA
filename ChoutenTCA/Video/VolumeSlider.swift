//
//  VolumeSlider.swift
//  ChoutenTCA
//
//  Created by Inumaki on 03.06.23.
//

import SwiftUI

struct VolumeSlider: View {
    @Binding var percentage: Float
    @Binding var isDragging: Bool
    var total: Double
    @State var barWidth: CGFloat = 6
    @State var i_percentage: Float = 1.0
    
    @StateObject var Colors = DynamicColors.shared
    
    
    var body: some View {
        GeometryReader { geometry in
            // TODO: - there might be a need for horizontal and vertical alignments
            ZStack(alignment: .bottomLeading) {
                
                Capsule()
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: barWidth, alignment: .bottom)
                    .cornerRadius(12)
                
                Capsule()
                    .foregroundColor(Color(hex: Colors.Primary.dark))
                    .frame(
                        maxHeight: geometry.size.height
                    )
                    .frame(width: barWidth, alignment: .bottom)
                    .offset(
                        y: geometry.size.height - (
                            geometry.size.height
                            * CGFloat(self.i_percentage / Float(total))
                            )
                        )
            }
            .frame(width: barWidth)
            .cornerRadius(400)
            .frame(maxWidth: .infinity, alignment: .center)
            .clipped(antialiased: true)
            .overlay {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                self.percentage = Float(
                                    min(
                                        max(0, (-value.location.y + geometry.size.height) / geometry.size.height * total
                                           ), total
                                    )
                                )
                                self.i_percentage = self.percentage
                                self.isDragging = false
                                self.barWidth = 6
                            }
                            .onChanged{ value in
                                print(value.location.y)
                                self.isDragging = true
                                self.barWidth = 10
                                // TODO: - maybe use other logic here
                                self.i_percentage = Float(
                                    min(
                                        max(0, (-value.location.y + geometry.size.height) / geometry.size.height * total
                                           ), total
                                    )
                                )
                            }
                    )
            }
            .animation(.spring(response: 0.3), value: self.isDragging)
        
        }
    }
}

struct VolumeSlider_Previews: PreviewProvider {
    static var previews: some View {
        VolumeSlider(percentage: .constant(0.5), isDragging: .constant(false), total: 1.0)
    }
}
