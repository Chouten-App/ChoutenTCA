//
//  InfoView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct InfoView: View {
    let url: String
    let store: StoreOf<InfoDomain>
    @StateObject var Colors = DynamicColors.shared
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(sortDescriptors: []) var mediaProgress: FetchedResults<MediaProgress>
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { proxy in
                ScrollView {
                    if let infoData = viewStore.infoData {
                        VStack {
                            Header(viewStore: viewStore, proxy: proxy)
                            ExtraInfo(viewStore: viewStore)
                            EpisodeList(viewStore: viewStore)
                        }
                        .background(GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey.self,
                                                   value: -$0.frame(in: .named("infoscroll")).origin.y)
                        })
                        .onPreferenceChange(ViewOffsetKey.self) {
                            if($0 >= 110 && $0 < 230) {
                                viewStore.send(.setHeader(newBool: true))
                                viewStore.send(.setRealHeader(newBool: false))
                            } else if($0 >= 230) {
                                viewStore.send(.setHeader(newBool: true))
                                viewStore.send(.setRealHeader(newBool: true))
                            } else {
                                viewStore.send(.setHeader(newBool: false))
                                viewStore.send(.setRealHeader(newBool: false))
                            }
                        }
                    } else {
                        VStack {
                            ShimmerHeader(proxy: proxy)
                            ShimmerInfo(proxy: proxy)
                            ShimmerMedia(proxy: proxy)
                        }
                    }
                }
                .coordinateSpace(name: "infoscroll")
                .foregroundColor(Color(hex: Colors.onSurface.dark))
                .background {
                    Color(hex: Colors.Surface.dark)
                }
                .background {
                    if !viewStore.webviewState.htmlString.isEmpty && !viewStore.webviewState.javaScript.isEmpty {
                        WebView(
                            viewStore: ViewStore(
                                self.store.scope(
                                    state: \.webviewState,
                                    action: InfoDomain.Action.webview
                                )
                            )
                        )
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    }
                }
                .overlay(alignment: .top) {
                    Sticky(viewStore: viewStore, proxy: proxy)
                }
                .ignoresSafeArea()
            }
            .navigationBarBackButtonHidden()
            .onAppear {
                viewStore.send(.resetWebview(url: url))
            }
            .onChange(of: viewStore.nextUrl) { newValue in
                if newValue != nil {
                    viewStore.send(.resetWebviewChange(url: newValue!))
                }
            }
        }
    }
    
    @ViewBuilder
    func ShimmerHeader(proxy: GeometryProxy) -> some View {
        ZStack {
            Rectangle()
                .frame(width: proxy.size.width, height: 280)
                .shimmer()
            
            HStack(alignment: .bottom) {
                Rectangle()
                    .frame(width: 120, height: 180)
                    .shimmer()
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 120, height: 20)
                        .shimmer()
                    
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 60, height: 16)
                        .shimmer()
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: proxy.size.width, alignment: .bottomLeading)
            .offset(y: 114)
        }
    }
    
    @ViewBuilder
    func ShimmerInfo(proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 20)
                    .shimmer()
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 20)
                    .shimmer()
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 20)
                    .shimmer()
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 20)
                    .shimmer()
                
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: proxy.size.width * 0.6, height: 20)
                    .shimmer()
            }
            
            RoundedRectangle(cornerRadius: 6)
                .frame(width: 72, height: 32)
                .shimmer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 80)
    }
    
    @ViewBuilder
    func ShimmerMedia(proxy: GeometryProxy) -> some View {
        VStack {
            ForEach(0..<4) { index in
                VStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: 160, height: 90)
                            .shimmer()
                        
                        VStack(alignment: .leading) {
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 2)
                                .frame(height: 20)
                                .shimmer()
                            
                            Spacer()
                            
                            HStack {
                                RoundedRectangle(cornerRadius: 2)
                                    .frame(width: 44, height: 20)
                                    .shimmer()
                                
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .frame(width: 44, height: 20)
                                    .shimmer()
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: 20)
                            .shimmer()
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: 20)
                            .shimmer()
                        RoundedRectangle(cornerRadius: 2)
                            .frame(width: proxy.size.width * 0.6,height: 20)
                            .shimmer()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func Sticky(viewStore: ViewStoreOf<InfoDomain>, proxy: GeometryProxy) -> some View {
        HStack {
            if let infoData = viewStore.infoData {
                Text(infoData.titles.primary)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: Colors.onPrimaryContainer.dark))
                    .lineLimit(1)
                    .opacity(viewStore.showRealHeader ? 1.0 : 0.0)
                    .animation(nil, value: viewStore.showRealHeader)
            }
            
            Spacer()
            
            Button {
                viewStore.send(.setGlobalInfoData(newValue: nil))
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(
                        Color(hex: Colors.onPrimary.dark)
                    )
                    .padding(8)
                    .background {
                        Circle()
                            .fill(Color(hex: Colors.Primary.dark))
                    }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: 110, alignment: .bottom)
        .background {
            Color(hex: Colors.SurfaceContainer.dark)
                .opacity(viewStore.showRealHeader ? 1.0 : 0.0)
                .animation(nil)
        }
    }
    
    @ViewBuilder
    func Header(viewStore: ViewStoreOf<InfoDomain>, proxy: GeometryProxy) -> some View {
        HStack(alignment: .bottom) {
            ZStack(alignment: .bottomLeading) {
                Color(hex: Colors.SurfaceContainer.dark)
                
                if let infoData = viewStore.infoData {
                    Text(infoData.titles.primary)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .padding(12)
                }
            }
            .foregroundColor(Color(hex: Colors.onPrimaryContainer.dark))
            .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width, maxHeight: 110, alignment: .bottomLeading)
            .padding(.bottom, -60)
            
            if let infoData = viewStore.infoData {
                ZStack(alignment: .bottomLeading) {
                    // Background image
                    GeometryReader {reader in
                        FillAspectImage(
                            url: URL(string: infoData.banner ?? infoData.poster),
                            doesAnimateHorizontal: false
                        )
                        .blur(radius: infoData.banner != nil ? 0.0 : 6.0)
                        .overlay {
                            LinearGradient(stops: [
                                Gradient.Stop(color: Color(hex: Colors.Surface.dark).opacity(0.9), location: 0.0),
                                Gradient.Stop(color: Color(hex: Colors.Surface.dark).opacity(0.4), location: 1.0),
                            ], startPoint: .bottom, endPoint: .top)
                        }
                        .frame(
                            width: reader.size.width,
                            height: reader.size.height + (reader.frame(in: .global).minY > 0 ? reader.frame(in: .global).minY : 0),
                            alignment: .top
                        )
                        .contentShape(Rectangle())
                        .clipped()
                        .offset(y: reader.frame(in: .global).minY <= 0 ? 0 : -reader.frame(in: .global).minY)
                        
                    }
                    .frame(height: 280)
                    .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                    
                    // Info
                    HStack(alignment: .bottom) {
                        KFImage(URL(string: infoData.poster))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 120, maxHeight: 180)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading) {
                            Text(infoData.titles.secondary ?? "")
                                .font(.caption)
                                .fontWeight(.heavy)
                                .lineLimit(2)
                                .opacity(0.7)
                            Text(infoData.titles.primary)
                                .font(.title2)
                                .fontWeight(.bold)
                                .lineLimit(2)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(infoData.status ?? "")
                                    .foregroundColor(Color(hex:Colors.Primary.dark))
                                    .fontWeight(.bold)
                                
                                Text("\(infoData.totalMediaCount ?? 0) \(infoData.mediaType)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 8)
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, -60)
                    .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                }
                .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
            }
        }
        .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width, alignment: .bottom)
        .offset(x: viewStore.showHeader ? proxy.size.width/2 : -proxy.size.width/2)
        .animation(.spring(response: 0.3), value: viewStore.showHeader)
    }
    
    @ViewBuilder
    func ExtraInfo(viewStore: ViewStoreOf<InfoDomain>) -> some View {
        if let infoData = viewStore.infoData {
            let seasons = viewStore.infoData!.mediaList.map({ list in
                list.title
            })
            
            VStack(alignment: .leading) {
                Text(infoData.description)
                    .font(.subheadline)
                    .lineLimit(9)
                    .opacity(0.7)
                
                Toggle(viewStore.isToggleOn ? "Dubbed" : "Subbed",
                       isOn: viewStore.binding(
                        get: \.isToggleOn,
                        send: InfoDomain.Action.setToggle(newValue:)
                       )
                )
                .toggleStyle(M3ToggleStyle())
                
                if seasons.count > 1 {
                    Dropdown(
                        options: seasons,
                        selectedOption: viewStore.binding(
                            get: \.selectedSeason,
                            send: InfoDomain.Action.setSelectedSeason(newValue:)
                        )
                    )
                    .zIndex(100)
                }
                
                
                Text(infoData.mediaType)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.vertical, 6)
            }
            .padding(.top, 60)
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    func EpisodeList(viewStore: ViewStoreOf<InfoDomain>) -> some View {
        if viewStore.infoData != nil && viewStore.infoData!.mediaList.count > viewStore.selectedSeason {
            ScrollView {
                VStack {
                    ForEach(0..<viewStore.infoData!.mediaList[viewStore.selectedSeason].list.count, id:\.self) { index in
                        NavigationLink(
                            destination: WatchView(
                                url: viewStore.infoData!.mediaList[viewStore.selectedSeason].list[index].url,
                                index: index,
                                store: self.store.scope(
                                    state: \.watchState,
                                    action: InfoDomain.Action.watch
                                )
                            )
                        ) {
                            EpisodeCard(item: viewStore.infoData!.mediaList[viewStore.selectedSeason].list[index], poster: viewStore.infoData!.poster)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(maxHeight: 700)
        }
    }
    
    func forTrailingZero(temp: Double) -> String {
        return String(format: "%g", temp)
    }
    
    func secondsToMinute(sec: Double) -> String {
        let minutes = Int(sec / 60)
        let minuteText = minutes == 1 ? "Min left" : "Mins left"
        
        return "\(minutes) \(minuteText)"
    }
    
    @ViewBuilder
    func EpisodeCard(item: MediaItem, poster: String) -> some View {
        let progress = mediaProgress.filter { progress in
            progress.url == item.url && progress.number == item.number
        }.first
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                KFImage(URL(string: item.image ?? poster))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 150, maxHeight: 90)
                    .cornerRadius(12)
                    .overlay(alignment: .topLeading) {
                        if let prog = progress {
                            GeometryReader { proxy in
                                VStack(alignment: .leading) {
                                    
                                    if prog.progress / prog.duration > 0.8 {
                                        Text("Watched")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 12)
                                            .foregroundColor(Color(hex: Colors.onTertiary.dark))
                                            .background {
                                                Color(hex: Colors.Tertiary.dark)
                                                    .cornerRadius(12, corners: [.bottomRight, .topLeft])
                                            }
                                    }
                                    Spacer()
                                    if prog.progress / prog.duration < 0.8 {
                                        VStack(alignment: .trailing, spacing: 6) {
                                            Text(secondsToMinute(sec: prog.duration - prog.progress))
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                            
                                            ZStack {
                                                Capsule()
                                                    .fill(.white.opacity(0.4))
                                                    .frame(height: 4)
                                                Capsule()
                                                    .fill(Color(hex: Colors.Primary.dark))
                                                    .frame(height: 4)
                                                    .offset(
                                                        x: -proxy.size.width
                                                        + (
                                                            proxy.size.width * (
                                                                (prog.progress / prog.duration)
                                                            )
                                                        )
                                                    )
                                            }
                                            .frame(height: 4)
                                            .cornerRadius(4)
                                            .clipped()
                                        }
                                        .padding(8)
                                    }
                                }
                                .background {
                                    if prog.progress / prog.duration < 0.8 {
                                        Color.black.opacity(0.4)
                                    }
                                }
                            }
                            .frame(maxWidth: 150, maxHeight: 90, alignment: .leading)
                            .onAppear {
                                print(prog.progress / prog.duration)
                            }
                        }
                    }
                
                VStack(alignment: .leading) {
                    Spacer()
                    
                    HStack {
                        Text(item.title ?? "Episode \(forTrailingZero(temp: item.number))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Spacer()
                    
                    HStack {
                        Text("Episode \(forTrailingZero(temp: item.number))")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        
                        Text("Filler")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: Colors.Primary.dark))
                    }
                    .opacity(0.7)
                    .padding(.bottom, 6)
                }
                .padding(.trailing, 8)
                .frame(maxWidth: .infinity, maxHeight: 90, alignment: .leading)
            }
            if item.description != nil {
                Text(item.description!)
                    .font(.caption)
                    .lineLimit(4)
                    .opacity(0.7)
                    .padding(12)
            }
            /*
             HStack {
             Text("Filler")
             .font(.system(size: 14))
             .fontWeight(.medium)
             .padding(.horizontal, 12)
             .padding(.vertical, 6)
             .foregroundColor(Color(hex: Colors.onSurfaceVariant.dark))
             .overlay {
             RoundedRectangle(cornerRadius: 8)
             .stroke(Color(hex: Colors.Outline.dark), lineWidth: 1.5)
             }
             
             Spacer()
             }
             .padding(12)
             .padding(.top, -12)
             */
        }
        .background {
            Color(hex: Colors.SurfaceContainer.dark)
                .cornerRadius(12)
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(
            url: "",
            store: Store(
                initialState: InfoDomain.State(),
                reducer: InfoDomain()
            )
        )
    }
}
