//
//  InfoViewiOS.swift
//  ChoutenTCA
//
//  Created by Inumaki on 11.08.23.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct InfoViewiOS: View {
    let url: String
    let store: StoreOf<InfoDomain>
    @StateObject var Colors = DynamicColors.shared
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(sortDescriptors: []) var mediaProgress: FetchedResults<MediaProgress>
    @Environment(\.managedObjectContext) var moc
    
    let mediaPerPage = 50
    
    // TEMP
    @State var averageColor: UIColor? = nil
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { proxy in
                ScrollView {
                    if viewStore.infoData != nil {
                        VStack {
                            Header(viewStore: viewStore, proxy: proxy)
                            ExtraInfo(viewStore: viewStore)
                            EpisodeList(viewStore: viewStore, proxy: proxy)
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
                    if let averageColor {
                        Color(uiColor: averageColor)
                    } else {
                        Color(hex: Colors.Surface.dark)
                    }
                }
                .background {
                    if !viewStore.webviewState.htmlString.isEmpty && !viewStore.webviewState.javaScript.isEmpty {
                        if viewStore.infoData != nil && !viewStore.infoData!.epListURLs[0].isEmpty {
                            WebView(
                                viewStore: ViewStore(
                                    self.store.scope(
                                        state: \.webviewState,
                                        action: InfoDomain.Action.webview
                                    )
                                ),
                                payload: viewStore.infoData!.epListURLs[0],
                                action: "eplist"
                            ) { result in
                                //print(result)
                                //viewStore.send(.parseResult(data: result))
                                viewStore.send(.parseMediaResult(data: result))
                            }
                            .hidden()
                            .frame(maxWidth: 0, maxHeight: 0)
                        } else {
                            WebView(
                                viewStore: ViewStore(
                                    self.store.scope(
                                        state: \.webviewState,
                                        action: InfoDomain.Action.webview
                                    )
                                ),
                                payload: self.url
                            ) { result in
                                //print(result)
                                if viewStore.infoData == nil {
                                    viewStore.send(.parseResult(data: result))
                                    viewStore.send(.resetWebviewChange(url: self.url))
                                }
                            }
                            .hidden()
                            .frame(maxWidth: 0, maxHeight: 0)
                        }
                    }
                }
                .overlay(alignment: .top) {
                    Sticky(viewStore: viewStore, proxy: proxy)
                }
                .overlay {
                    if let infoData = viewStore.infoData {
                        if infoData.mediaList.count > 0 {
                            VStack(spacing: 20) {
                                ForEach(0..<infoData.mediaList.count, id: \.self) { index in
                                    let delay = 0.1 + ( 0.1 * Double(index) )
                                    
                                    Text(infoData.mediaList[index].title)
                                        .font(index == viewStore.selectedSeason ? .title : .title3)
                                        .fontWeight(index == viewStore.selectedSeason ? .bold : .semibold)
                                        .opacity(index == viewStore.selectedSeason ? 1.0 : 0.7)
                                        .offset(y: viewStore.showSeasonSelector ? 0 : 60)
                                        .opacity(viewStore.showSeasonSelector ? 1 : 0)
                                        .animation(.spring(response: 0.3).delay(delay), value: viewStore.showSeasonSelector)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            viewStore.send(.setSelectedSeason(newValue: index), animation: .spring(response: 0.3))
                                        }
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.ultraThinMaterial)
                            .overlay(alignment: .bottom) {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .padding(12)
                                    .foregroundColor(.black)
                                    .background {
                                        Circle()
                                            .fill(.white)
                                    }
                                    .padding(.bottom, 80)
                                    .onTapGesture {
                                        viewStore.send(.setSeasonSelectorState(bool: false))
                                    }
                                    .offset(y: viewStore.showSeasonSelector ? 0 : 130)
                                    .animation(.spring(response: 0.3).delay(0.2), value: viewStore.showSeasonSelector)
                            }
                            .ignoresSafeArea()
                            .opacity(viewStore.showSeasonSelector ? 1.0 : 0.0)
                            .animation(.spring(response: 0.3), value: viewStore.showSeasonSelector)
                        }
                    }
                }
                .ignoresSafeArea()
            }
            .navigationBarBackButtonHidden()
            .onAppear {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                    viewStore.send(.resetWebview(url: url))
                }
            }
            .onDisappear {
                averageColor = nil
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
            Button {
                viewStore.send(.setGlobalInfoData(newValue: nil))
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
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
            .padding(.leading, 12)
            
            Spacer()
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
        if let infoData = viewStore.infoData {
            ZStack(alignment: .bottomLeading) {
                // Background image
                GeometryReader {reader in
                    FillAspectImage(
                        url: URL(string: infoData.banner ?? infoData.poster),
                        doesAnimateHorizontal: false,
                        color: $averageColor
                    )
                    .blur(radius: infoData.banner != nil ? 0.0 : 6.0)
                    .overlay {
                        LinearGradient(stops: [
                            Gradient.Stop(
                                color: averageColor != nil ? Color(uiColor: averageColor!).opacity(0.9) : Color(hex: Colors.Surface.dark).opacity(0.9),
                                location: 0.0),
                            Gradient.Stop(color: averageColor != nil ? Color(uiColor: averageColor!).opacity(0.4) : Color(hex: Colors.Surface.dark).opacity(0.4), location: 1.0),
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
                .frame(height: 360)
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
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, -36)
                .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
            }
            .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
        }
    }
    
    // Calculate the total number of pages
    func pageCount(infoData: InfoData) -> Int {
        if infoData.mediaList.count == 0 {
            return 0
        }
        return (infoData.mediaList[0].list.count + mediaPerPage - 1) / mediaPerPage
    }
    
    // Calculate the episode range for a given page
    func episodeRange(forPage page: Int, infoData: InfoData, mediaIncrease: Bool = true) -> String {
        if infoData.mediaList.count == 0 {
            return ""
        }
        
        if mediaIncrease {
            let startIndex = (page - 1) * mediaPerPage
            let endIndex = min(page * mediaPerPage, infoData.mediaList[0].list.count)
            return "\(startIndex + 1) - \(endIndex)"
        } else {
            let startIndex = infoData.mediaList[0].list.count - (page - 1) * mediaPerPage
            let endIndex = max(infoData.mediaList[0].list.count - (page) * mediaPerPage, 1)
            return "\(startIndex == infoData.mediaList[0].list.count ? startIndex : startIndex - 1) - \(endIndex)"
        }
    }
    
    @ViewBuilder
    func ExtraInfo(viewStore: ViewStoreOf<InfoDomain>) -> some View {
        if let infoData = viewStore.infoData {
            let seasons = viewStore.infoData!.mediaList.map({ list in
                list.title
            })
            
            VStack(alignment: .leading) {
                // continue watching
                if infoData.mediaList.count > 0 {
                    let progress = mediaProgress.filter { progress in
                        progress.url == infoData.mediaList[0].list[viewStore.selectedSeason].url && progress.number == infoData.mediaList[0].list[viewStore.selectedSeason].number
                    }.first
                    
                    if let progress {
                        VStack {
                            KFImage(URL(string: infoData.mediaList[0].list[viewStore.selectedSeason].image ?? infoData.poster))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: 80)
                                .clipped()
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: Colors.SurfaceContainer.dark).opacity(0.4))
                                }
                                .overlay {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Episode \(forTrailingZero(temp: infoData.mediaList[0].list[viewStore.selectedSeason].number)): \(infoData.mediaList[0].list[viewStore.selectedSeason].title ?? "")")
                                                .fontWeight(.bold)
                                            
                                            if progress.progress / progress.duration < 0.8 {
                                                Text(secondsToMinute(sec: progress.duration - progress.progress))
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .blendMode(.difference)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        ZStack {
                                            Image(systemName: "chevron.right")
                                                .offset(x: -8)
                                                .opacity(0.7)
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 26, weight: .medium))
                                        }
                                    }
                                    .padding(12)
                                }
                                .overlay(alignment: .bottom) {
                                    if progress.progress / progress.duration < 0.8 {
                                        VStack(alignment: .trailing, spacing: 6) {
                                            ZStack {
                                                Capsule()
                                                    .fill(.white.opacity(0.4))
                                                    .frame(height: 4)
                                                Capsule()
                                                    .fill(Color(hex: Colors.Primary.dark))
                                                    .frame(height: 4)
                                                    .offset(
                                                        x: -134
                                                        + (
                                                            134 * (
                                                                (progress.progress / progress.duration)
                                                            )
                                                        )
                                                    )
                                            }
                                            .frame(height: 4)
                                            .cornerRadius(4)
                                            .clipped()
                                        }
                                        .padding(12)
                                    }
                                }
                            
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                Text(infoData.description)
                    .font(.subheadline)
                    .lineLimit(viewStore.descriptionExpanded ? nil : 9)
                    .animation(.spring(response: 0.3), value: viewStore.descriptionExpanded)
                    .opacity(0.7)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.toggleDescriptionExpanded)
                    }
                
                if seasons.count > 0 {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("\(seasons[viewStore.selectedSeason])")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .padding(6)
                                .background {
                                    Circle()
                                        .fill(Color(hex: Colors.SurfaceContainer.dark))
                                }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewStore.send(.setSeasonSelectorState(bool: true))
                        }
                        
                        HStack {
                            Text("\(infoData.totalMediaCount ?? 0) \(infoData.mediaType)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .opacity(0.7)
                            
                            Spacer()
                            
                            Image("arrow.down.filter")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .foregroundColor(.white)
                                .opacity(viewStore.mediaIncrease ? 1.0 : 0.7)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewStore.send(.setMediaIncrease(bool: true))
                                    viewStore.send(.setCurrentPage(page: 1))
                                }
                            
                            Image("arrow.down.filter")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .scaleEffect(CGSize(width: 1.0, height: -1.0))
                                .foregroundColor(.white)
                                .opacity(viewStore.mediaIncrease ? 0.7 : 1.0)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewStore.send(.setMediaIncrease(bool: false))
                                    viewStore.send(.setCurrentPage(page: 1))
                                }
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                // pagination
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(1 ..< pageCount(infoData: infoData) + 1, id: \.self) { page in
                            Button(action: {
                                viewStore.send(.setCurrentPage(page: page))
                            }) {
                                Text("\(episodeRange(forPage: page, infoData: infoData, mediaIncrease: viewStore.mediaIncrease))")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .foregroundColor(Color(hex: viewStore.currentPage == page ? Colors.onPrimary.dark : Colors.onSurface.dark))
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(hex: viewStore.currentPage == page ? Colors.Primary.dark : Colors.SurfaceContainer.dark))
                                    )
                            }
                        }
                    }
                }
                .padding(.bottom, 6)
                .padding(.top, 8)
            }
            .padding(.top, 44)
            .padding(.horizontal, 20)
            .animation(.spring(response: 0.3), value: viewStore.descriptionExpanded)
        }
    }
    
    @Dependency(\.globalData) var globalData
    
    @ViewBuilder
    func EpisodeList(viewStore: ViewStoreOf<InfoDomain>, proxy: GeometryProxy) -> some View {
        if viewStore.infoData != nil && viewStore.infoData!.mediaList.count > viewStore.selectedSeason {
            
            let startIndex = viewStore.mediaIncrease ?
                (viewStore.currentPage - 1) * mediaPerPage
            : viewStore.infoData!.mediaList[viewStore.selectedSeason].list.count - (viewStore.currentPage - 1) * mediaPerPage - (viewStore.currentPage == 1 ? 0 : 1)
            
            let endIndex = viewStore.mediaIncrease ?
                min(viewStore.currentPage * mediaPerPage, viewStore.infoData!.mediaList[viewStore.selectedSeason].list.count)
            : max(viewStore.infoData!.mediaList[viewStore.selectedSeason].list.count - viewStore.currentPage * mediaPerPage - 1, 0)
            let episodeList = viewStore.mediaIncrease ? Array(viewStore.infoData!.mediaList[viewStore.selectedSeason].list[startIndex..<endIndex]) : Array(viewStore.infoData!.mediaList[viewStore.selectedSeason].list[endIndex..<startIndex])
            
            
            ScrollView(.horizontal) {
                HStack {
                    if viewStore.mediaIncrease {
                        ForEach(episodeList, id: \.self) { episode in
                            NavigationLink(
                                destination: globalData.getModule()?.type == "Book" ? AnyView(
                                    ReaderView(
                                        store: self.store.scope(
                                            state: \.readerState,
                                            action: InfoDomain.Action.reader
                                        ),
                                        url: episode.url
                                    )
                                ) : AnyView(
                                    WatchView(
                                        url: episode.url,
                                        index: Int(episode.number - 1),
                                        store: self.store.scope(
                                            state: \.watchState,
                                            action: InfoDomain.Action.watch
                                        )
                                    )
                                )
                            ) {
                                EpisodeCard(item: episode, poster: viewStore.infoData!.poster, proxy: proxy)
                                    .frame(maxWidth: proxy.size.width - 140)
                            }
                        }
                    } else {
                        ForEach(episodeList.reversed(), id: \.self) { episode in
                            NavigationLink(
                                destination: globalData.getModule()?.type == "Book" ? AnyView(
                                    ReaderView(
                                        store: self.store.scope(
                                            state: \.readerState,
                                            action: InfoDomain.Action.reader
                                        ),
                                        url: episode.url
                                    )
                                ) : AnyView(
                                    WatchView(
                                        url: episode.url,
                                        index: Int(episode.number - 1),
                                        store: self.store.scope(
                                            state: \.watchState,
                                            action: InfoDomain.Action.watch
                                        )
                                    )
                                )
                            ) {
                                EpisodeCard(item: episode, poster: viewStore.infoData!.poster, proxy: proxy)
                                    .frame(maxWidth: proxy.size.width - 140)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
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
    func EpisodeCard(item: MediaItem, poster: String, proxy: GeometryProxy) -> some View {
        let progress = mediaProgress.filter { progress in
            progress.url == item.url && progress.number == item.number
        }.first
        
        VStack {
            KFImage(URL(string: item.image ?? poster))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: proxy.size.width - 140, maxWidth: proxy.size.width - 140, minHeight: (proxy.size.width - 140) / 16 * 9, maxHeight: (proxy.size.width - 140) / 16 * 9)
                .cornerRadius(12)
                .overlay(alignment: .topTrailing) {
                    HStack {
                        if let prog = progress {
                            if prog.progress / prog.duration > 0.8 {
                                Text("Watched")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        
                        Text("\(forTrailingZero(temp: item.number))")
                            .fontWeight(.bold)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .foregroundColor(Color(hex: Colors.onPrimary.dark))
                            .background {
                                Capsule()
                                    .fill(Color(hex: Colors.Primary.dark))
                            }
                            .padding(12)
                    }
                }
                .overlay(alignment: .bottom) {
                    if let prog = progress {
                        if prog.progress / prog.duration < 0.8 {
                            VStack(alignment: .trailing, spacing: 6) {
                                Text(secondsToMinute(sec: prog.duration - prog.progress))
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                ZStack {
                                    Capsule()
                                        .fill(.white.opacity(0.4))
                                        .frame(height: 4)
                                    Capsule()
                                        .fill(Color(hex: Colors.Primary.dark))
                                        .frame(height: 4)
                                        .offset(
                                            x: -134
                                            + (
                                                134 * (
                                                    (prog.progress / prog.duration)
                                                )
                                            )
                                        )
                                }
                                .frame(height: 4)
                                .cornerRadius(4)
                                .clipped()
                            }
                            .padding(12)
                            //.frame(maxHeight: 24)
                        }
                    }
                }
            
            VStack(spacing: 4) {
                Text(item.title ?? "Episode \(forTrailingZero(temp: item.number))")
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                /*
                Text("Filler")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: Colors.Primary.dark))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                */
                if let description = item.description {
                    Text(description)
                        .font(.caption)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .opacity(0.7)
                        .frame(height: 50)
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

struct InfoViewiOS_Bridge: View {
    let list: [MediaItem]
    init() {
        let nums = Array(1...60)
        list = nums.map {index in
            MediaItem(
                url: "",
                number: Double(index),
                title: "Media Title",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc eget sem tellus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Sed maximus justo neque, vitae faucibus mauris facilisis non.",
                image: nil
            )
        }
    }
    
    var body: some View {
        InfoViewiOS(
            url: "",
            store: Store(
                initialState: InfoDomain.State(
                    infoData: InfoData(
                        id: "",
                        titles: Titles(primary: "Primary", secondary: "Secondary"),
                        altTitles: [],
                        epListURLs: [],
                        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc eget sem tellus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Sed maximus justo neque, vitae faucibus mauris facilisis non. Quisque volutpat nunc quis tortor commodo, at tempus ante imperdiet. Suspendisse lobortis dapibus justo. Nunc ut odio commodo, varius mauris tristique, consequat nibh. Mauris tincidunt sapien purus, id maximus purus posuere ut. Aliquam nec ex ligula. Sed viverra velit libero, quis euismod erat molestie ut. Nunc eleifend condimentum nulla ut rutrum. Sed condimentum eu lectus id facilisis. Integer ut velit feugiat, feugiat augue sit amet, finibus tortor. Etiam id magna ac odio feugiat semper. Donec sit amet diam eget est dignissim efficitur. Aliquam molestie ante porttitor lacus rutrum, non eleifend tellus facilisis.",
                        poster: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg",
                        banner: nil,
                        status: "Finished",
                        totalMediaCount: 12,
                        mediaType: "Media",
                        seasons: [],
                        mediaList: [
                            MediaList(
                                title: "Season 1",
                                list: list
                            ),
                            MediaList(
                                title: "Season 2",
                                list: list
                            ),
                            MediaList(
                                title: "Season 3",
                                list: list
                            ),
                            MediaList(
                                title: "Season 4",
                                list: list
                            )
                        ]
                    )
                ),
                reducer: InfoDomain()
            )
        )
    }
}

struct InfoViewiOS_Previews: PreviewProvider {
    static var previews: some View {
        InfoViewiOS_Bridge()
    }
}
