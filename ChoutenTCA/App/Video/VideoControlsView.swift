//
//  VideoControlsView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 30.05.23.
//

import SwiftUI
import ComposableArchitecture
import AVKit

struct VideoControlsView: View {
    @Binding var videoData: VideoData?
    @Binding var servers: [ServerData]
    let index: Int
    @StateObject var playerVM: PlayerViewModel
    @StateObject var Colors = DynamicColors.shared
    
    @State var showUI: Bool = true
    @State var isDragging: Bool = false
    @State var animateBackward: Bool = false
    @State var animateForward: Bool = false
    @State private var buttonOffset: Double = -156
    @State private var textWidth: Double = 0
    
    @Dependency(\.globalData) var globalData
    @Environment(\.presentationMode) var presentationMode
    
    private func formatDecimalNumber(_ value: Double) -> String {
        if value == Double(Int(value)) {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                TopBar()
                    .offset(y: showUI ? 0 : -80)
                
                MiddleBar()
                
                BottomBar()
                    .offset(y: showUI ? 0 : 80)
            }
            .padding(.horizontal, 60)
            .padding(.vertical, 20)
            .foregroundColor(Color(hex: Colors.onSurface.dark))
            .background {
                PlayPause()
                    .foregroundColor(Color(hex: Colors.onSurface.dark))
            }
            .opacity(showUI ? 1.0 : 0.0)
            .background {
                Subtitles()
            }
            .overlay(alignment: .bottomTrailing) {
                if videoData != nil && videoData!.skips.count > 0 {
                    SkipTimeButton(skip: videoData!.skips[0])
                        .padding(.bottom, 88)
                        .padding(.trailing, 60)
                }
            }
            .background {
                Color(.black).opacity(showUI ? 0.4 : 0.0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showUI.toggle()
                    }
            }
            .animation(.spring(response: 0.3), value: showUI)
            .ignoresSafeArea()
        }
    }
    
    let tempList: [ServerData] = [
        ServerData(
            title: "Sub",
            list: [
                Server(name: "Vidstreaming", url: ""),
                Server(name: "Vizcloud", url: ""),
                Server(name: "Streamtape", url: ""),
                Server(name: "Filemoon", url: ""),
            ]
        ),
        ServerData(
            title: "Dub",
            list: [
                Server(name: "Vidstreaming", url: ""),
                Server(name: "Vizcloud", url: ""),
                Server(name: "Streamtape", url: ""),
                Server(name: "Filemoon", url: ""),
            ]
        )
    ]
    
    @State var selectedServerId: Int = 0
    @State var selectedServer: Int = 0
    @State var showServers: Bool = false
    
    @ViewBuilder
    func ServerList(proxy: GeometryProxy) -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(0..<tempList.count) {index in
                    Text(tempList[index].title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 12) {
                        ForEach(0..<tempList[index].list.count) { listIndex in
                            ServerCard(title: tempList[index].list[listIndex].name, selected: selectedServer == index && selectedServer == listIndex)
                                .onTapGesture {
                                    //selectedServerData = index
                                    //selectedServer = listIndex
                                    
                                    //globalData.serverUrl = globalData.servers[index].list[listIndex].url
                                }
                        }
                    }
                }
            }
            .padding(.vertical, 20)
        }
        .padding(.leading, 60)
        .padding(.trailing, 32)
        .frame(maxWidth: 360, maxHeight: proxy.size.height, alignment: .topLeading)
        .foregroundColor(Color(hex: Colors.onSurface.dark))
        .background {
            Color(hex: Colors.SurfaceContainer.dark)
        }
    }
    
    @ViewBuilder
    func StylisedSubtitle(text: String) -> some View {
        ZStack {
            Text(LocalizedStringKey(text))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .shadow(color: .black, radius: 0, x: 1, y: 1)
                .shadow(color: .black, radius: 0, x: 1, y: -1)
                .shadow(color: .black, radius: 0, x: -1, y: -1)
                .shadow(color: .black, radius: 0, x: -1, y: 1)
                .shadow(color: .black, radius: 0.1, x: -1, y: 0)
                .shadow(color: .black, radius: 0.1, x: 1, y: 0)
                .shadow(color: .black, radius: 0.1, x: 0, y: -1)
                .shadow(color: .black, radius: 0.1, x: 0, y: 1)
                .offset(x: 2, y: 2)
            
            Text(LocalizedStringKey(text))
                .multilineTextAlignment(.center)
                .shadow(color: .black, radius: 0, x: 1, y: 1)
                .shadow(color: .black, radius: 0, x: 1, y: -1)
                .shadow(color: .black, radius: 0, x: -1, y: -1)
                .shadow(color: .black, radius: 0, x: -1, y: 1)
                .shadow(color: .black, radius: 0.1, x: -1, y: 0)
                .shadow(color: .black, radius: 0.1, x: 1, y: 0)
                .shadow(color: .black, radius: 0.1, x: 0, y: -1)
                .shadow(color: .black, radius: 0.1, x: 0, y: 1)
        }
    }
    
    @ViewBuilder
    func Subtitles() -> some View {
        VStack {
            Spacer()
            
            ForEach(0..<playerVM.currentSubs.count, id:\.self) {index in
                StylisedSubtitle(
                    text: playerVM.currentSubs[index].text
                        .replacingOccurrences(of: "*", with: "**")
                        .replacingOccurrences(of: "_", with: "*")
                )
            }
        }
        .padding(.horizontal, 80)
        .font(Font.custom("Trebuchet MS", size: 18))
        .padding(.bottom, showUI ? 80 : 32)
        .animation(.spring(response: 0.3), value: showUI)
        .foregroundColor(.white)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .bottom
        )
        .ignoresSafeArea()
    }
    
    func getSkipPercentage(currentTime: Double, startTime: Double, endTime: Double) -> Double {
        if(startTime <= currentTime && endTime >= currentTime) {
            let timeElapsed = currentTime - startTime
            let totalTime = endTime - startTime
            let percentage = timeElapsed / totalTime
            return percentage
        }
        return 0.0
    }
    
    @ViewBuilder
    func SkipTimeButton(skip: SkipTime) -> some View {
        Button(action: {
            playerVM.isEditingCurrentTime = true
            playerVM.currentTime = skip.end
            playerVM.isEditingCurrentTime = false
        }) {
            ZStack(alignment: .trailing) {
                Rectangle()
                    .fill(Color(hex: Colors.Tertiary.dark))
                
                Rectangle()
                    .fill(Color(hex: Colors.Primary.dark))
                    .frame(width: buttonOffset)
                    .onReceive(playerVM.$currentTime) { currentTime in
                        //viewModel.showSkipButton(currentTime: currentTime)
                        let skipPercentage = getSkipPercentage(currentTime: currentTime, startTime: skip.start, endTime: skip.end)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            buttonOffset = textWidth - (textWidth * skipPercentage)
                        }
                    }
                
                
                Text("Skip \(skip.type)")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: Colors.onTertiary.dark))
                    //.blendMode(BlendMode.difference)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    self.textWidth = geometry.size.width
                                    buttonOffset = -textWidth
                                }
                        }
                    )
            }
            .fixedSize()
            .cornerRadius(12)
            .clipped()
        }
        .opacity(skip.start <= playerVM.currentTime && skip.end >= playerVM.currentTime ? 1.0 : 0.0)
    }
    
    @ViewBuilder
    func TopBar() -> some View {
        HStack {
            let info = globalData.getInfoData()
            let module = globalData.getModule()
            
            Image(systemName: "chevron.left")
                .font(.system(size: 32))
                .contentShape(Rectangle())
                .onTapGesture {
                    self.presentationMode.wrappedValue.dismiss()
                }
            
            if info != nil {
                VStack(alignment: .leading) {
                    if info!.mediaList.count > 0 && info!.mediaList[0].list.count >= index {
                        Text("\(formatDecimalNumber(info!.mediaList[0].list[index].number)): \(info!.mediaList[0].list[index].title ?? "Episode")")
                            .fontWeight(.bold)
                    }
                        
                    Text(info!.titles.primary)
                        .font(.subheadline)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(module?.name ?? "Module Name")
                    .fontWeight(.bold)
                if videoData == nil {
                    Text("Fetching \(servers.isEmpty ? "Servers" : "Sources")")
                        .font(.caption)
                }
                Text(
                    playerVM.getCurrentItem() != nil ?
                    String(
                        Int(playerVM.getCurrentItem()!.presentationSize.width)
                    ) + "x" +
                    String(
                        Int(playerVM.getCurrentItem()!.presentationSize.height)
                    )
                    : "Resolution"
                )
                .font(.caption)
            }
        }
    }
    
    @ViewBuilder
    func MiddleBar() -> some View {
        HStack {
            Spacer()
            
            VStack(spacing: 12) {
                VolumeSlider(percentage: $playerVM.player.volume, isDragging: $isDragging, total: 1.0)
                    .frame(maxWidth: 20, maxHeight: 140)
                
                Image(
                    systemName: playerVM.player.volume == 0.0
                                    ? ("speaker.slash.fill")
                                    : (
                                        playerVM.player.volume <= 0.33
                                        ? ("speaker.wave.1.fill")
                                        : (
                                            playerVM.player.volume <= 0.66
                                            ? ("speaker.wave.2.fill")
                                            : ("speaker.wave.3.fill")
                                        )
                                    )
                )
            }
            .offset(x: showUI ? 0 : 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    func PlayPause() -> some View {
        HStack(spacing: 90) {
            SkipButton(forward: false)
            
            Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 52))
                .onTapGesture {
                    if playerVM.isPlaying {
                        playerVM.player.pause()
                    } else {
                        playerVM.player.play()
                    }
                }
            
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
                                Task {
                                    if playerVM.player.currentItem != nil {
                                        await playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime - 10, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                                    }
                                    // add crunchy animation
                                    animateBackward = true
                                    //showUI = true
                                    try? await Task.sleep(nanoseconds: 400_000_000)
                                    animateBackward = false
                                    //showUI = false
                                }
                            }
                            .exclusively(
                                before:
                                    TapGesture(count: 1)
                                    .onEnded { _ in
                                        showUI = false
                                    }
                            )
                    )
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .frame(maxWidth: 200)
                    .onTapGesture {
                        showUI = false
                    }
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        TapGesture(count: 2)
                            .onEnded { _ in
                                print("skip forward")
                                Task {
                                    if playerVM.player.currentItem != nil {
                                        await playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime + 10, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                                    }
                                    // add crunchy animation
                                    animateForward = true
                                    //showUI = true
                                    try? await Task.sleep(nanoseconds: 400_000_000)
                                    animateForward = false
                                    //showUI = false
                                }
                            }
                            .exclusively(
                                before:
                                    TapGesture(count: 1)
                                    .onEnded { _ in
                                        showUI = false
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
                .opacity(
                    forward ?
                    (animateForward ? 0.0 : 1.0)
                    : (animateBackward ? 0.0 : 1.0)
                )
                .animation(.spring(response: 0.3), value: animateForward)
                .animation(.spring(response: 0.3), value: animateBackward)
            
            Image(systemName: forward ? "goforward" : "gobackward")
                .font(.system(size: 32))
                .rotationEffect(
                    forward ?
                    (animateForward ? Angle(degrees: 30) : .zero)
                    : (animateBackward ? Angle(degrees: -30) : .zero)
                )
                .animation(.spring(response: 0.3), value: animateForward)
                .animation(.spring(response: 0.3), value: animateBackward)
            
            Text("\(forward ? "+" : "-")10")
                .font(.system(size: 18, weight: .semibold))
                .offset(x:
                            forward ?
                        (animateForward ? 80 : 0.0)
                        : (animateBackward ? -80 : 0.0)
                        , y: 2
                )
                .opacity(
                    forward ?
                    (animateForward ? 1.0 : 0.0)
                    : (animateBackward ? 1.0 : 0.0)
                )
                .animation(.spring(response: 0.3), value: animateForward)
                .animation(.spring(response: 0.3), value: animateBackward)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            Task {
                if forward {
                    if playerVM.player.currentItem != nil {
                        await playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime + 10, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                    }
                    // add crunchy animation
                    animateForward = true
                    //showUI = true
                    try? await Task.sleep(nanoseconds: 400_000_000)
                    animateForward = false
                    //showUI = false
                } else {
                    if playerVM.player.currentItem != nil {
                        await playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime - 10, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                    }
                    // add crunchy animation
                    animateBackward = true
                    //showUI = true
                    try? await Task.sleep(nanoseconds: 400_000_000)
                    animateBackward = false
                    //showUI = false
                }
            }
        }
    }
    
    func secondsToMinutesSeconds(_ seconds: Int) -> String {
        let hours = (seconds / 3600)
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        
        let hourString = hours > 0 ? "\(hours)" : ""
        let minuteString = (minutes < 10 ? "0" : "") +  "\(minutes)"
        let secondsString = (seconds < 10 ? "0" : "") +  "\(seconds)"
        
        return (hours > 0 ? hourString + ":" : "") + minuteString + ":" + secondsString
    }
    
    @ViewBuilder
    func BottomBar() -> some View {
        VStack {
            if playerVM.duration != nil {
                Seekbar(percentage: $playerVM.currentTime, buffered: $playerVM.buffered, isDragging: $playerVM.isEditingCurrentTime, total: playerVM.duration!, isMacos: .constant(false))
                    .frame(maxHeight: 20)
            } else {
                Seekbar(percentage: .constant(0.0), buffered: .constant(0.0), isDragging: .constant(false), total: 1.0, isMacos: .constant(false))
                    .frame(maxHeight: 20)
            }
            
            HStack {
                if playerVM.duration != nil {
                    Text("\(secondsToMinutesSeconds(Int(playerVM.currentTime))) / \(secondsToMinutesSeconds(Int(playerVM.duration!)))")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                } else {
                    Text("--:--/--:--")
                }
                Spacer()
                
                HStack(spacing: 20) {
                    Image(systemName: "server.rack")
                        .clipShape(Rectangle())
                        .onTapGesture {
                            showServers.toggle()
                        }
                    
                    Image(systemName: "rectangle.stack.fill")
                        .clipShape(Rectangle())
                    
                    Image(systemName: "gear")
                        .clipShape(Rectangle())
                    
                    Image(systemName: "forward.fill")
                        .clipShape(Rectangle())
                }
                .font(.system(size: 20))
            }
            .offset(y: -4)
            
        }
    }
}

struct VideoControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.black)
            
            VideoControlsView(videoData: .constant(nil), servers: .constant([]), index: 0, playerVM: PlayerViewModel())
        }
        .prefersHomeIndicatorAutoHidden(true)
        .supportedOrientation(.landscape)
        .previewInterfaceOrientation(.landscapeRight)
        .ignoresSafeArea()
    }
}
