//
//  VideoControlsView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 30.05.23.
//

import SwiftUI

struct VideoControlsView: View {
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                TopBar()
                
                Spacer()
                
                BottomBar()
            }
            .padding(.horizontal, proxy.safeAreaInsets.leading)
            .padding(.vertical, 12)
            .foregroundColor(Color(hex: Colors.onSurface.dark))
            .background {
                PlayPause()
                    .foregroundColor(Color(hex: Colors.onSurface.dark))
            }
            .background {
                Color(.black)
            }
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    func TopBar() -> some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 32))
                .fontWeight(.bold)
            VStack(alignment: .leading) {
                Text("1: Episode Title")
                    .fontWeight(.bold)
                Text("Show Title")
                    .font(.subheadline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Module Name")
                    .fontWeight(.bold)
                Text("1920x1080")
                    .font(.caption)
            }
        }
    }
    
    @ViewBuilder
    func PlayPause() -> some View {
        HStack(spacing: 90) {
            SkipButton(forward: false)
            
            Image(systemName: "play.fill")
                .font(.system(size: 52))
            
            SkipButton()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            HStack {
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        TapGesture(count: 2)
                            .onEnded { _ in
                                print("skip forward")
                            }
                            .exclusively(
                                before:
                                    TapGesture(count: 1)
                                    .onEnded { _ in
                                        print("hide ui")
                                    }
                            )
                    )
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .frame(maxWidth: 200)
                    .onTapGesture {
                        print("hide ui")
                    }
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        TapGesture(count: 2)
                            .onEnded { _ in
                                print("skip forward")
                            }
                            .exclusively(
                                before:
                                    TapGesture(count: 1)
                                    .onEnded { _ in
                                        print("hide ui")
                                    }
                            )
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    func SkipButton(forward: Bool = true) -> some View {
        ZStack {
            Text("10")
                .font(.system(size: 10, weight: .bold))
                .offset(y: 2)
                .opacity(1.0)
                .animation(.spring(response: 0.3))
            
            Image(systemName: forward ? "goforward" : "gobackward")
                .font(.system(size: 32))
            
            Text("\(forward ? "+" : "-")10")
                .font(.system(size: 18, weight: .semibold))
                .offset(x: forward ? 80 : -80, y: 2)
                .opacity(1.0)
                .animation(.spring(response: 0.3))
        }
    }
    
    @ViewBuilder
    func BottomBar() -> some View {
        VStack {
            HStack {
                Text("--:--/--:--")
                
                Spacer()
                
                HStack(spacing: 20) {
                    Image(systemName: "server.rack")
                        .clipShape(Rectangle())
                    
                    Image(systemName: "rectangle.stack.fill")
                        .clipShape(Rectangle())
                    
                    Image(systemName: "gear")
                        .clipShape(Rectangle())
                    
                    Image(systemName: "forward.fill")
                        .clipShape(Rectangle())
                }
                .font(.system(size: 20))
            }
            .offset(y: 6)
            
            Seekbar(percentage: .constant(0.2), buffered: .constant(0.5), isDragging: .constant(false), total: 1.0, isMacos: .constant(false))
                .frame(maxHeight: 20)
        }
        .padding(.bottom, 12)
    }
}

struct VideoControlsView_Previews: PreviewProvider {
    static var previews: some View {
        VideoControlsView()
            .prefersHomeIndicatorAutoHidden(true)
            .supportedOrientation(.landscape)
            .previewInterfaceOrientation(.landscapeRight)
    }
}
