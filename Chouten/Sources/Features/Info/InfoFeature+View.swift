//
//  SwiftUIView.swift
//
//
//  Created by Inumaki on 16.10.23.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import CoreImage
import ViewComponents
import Webview
import SharedModels
import Shimmer

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        typealias NativeColor = UIColor
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }
        
        return (r, g, b, o)
    }
}

extension UIColor {
    static var dynamicGreen: UIColor {
        return UIColor { (traitCollection) -> UIColor in
            let c = Color(uiColor: .systemIndigo).components
            print(c)
            if traitCollection.userInterfaceStyle == .dark {
                let c = Color(uiColor: .systemIndigo).components
                
                return UIColor(red: 14/255, green: 64/255, blue: 26/255, alpha: c.opacity)
            } else {
                return .systemIndigo
            }
        }
    }
    
    // Define light and dark versions of your colors
    static var darkGreen: UIColor = UIColor(red: 0.6, green: 0.8, blue: 0.4, alpha: 1.0)
    static var lightIndigo: UIColor = UIColor(red: 0.3, green: 0.6, blue: 0.84, alpha: 1.0)
}

extension UIColor {
    func complementaryColor() -> UIColor {
        var brightness: CGFloat = 0.0
        self.getWhite(&brightness, alpha: nil)
        
        // Compare brightness to determine text color
        return brightness > 0.5 ? .black : .white
    }
}

extension InfoFeature.View: View {
    @MainActor
    public var body: some View {
        WithViewStore(store, observe: \.`self`) { viewStore in
            GeometryReader { proxy in
                LoadableView(loadable: viewStore.infoLoadable) { infoData in
                    ScrollView {
                        VStack {
                            Header(proxy: proxy, viewStore: viewStore, infoData: infoData)
                            
                            ExtraInfo(viewStore: viewStore, infoData: infoData)
                            
                            EpisodeList(viewStore: viewStore, infoData: infoData, proxy: proxy)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(Color(uiColor: viewStore.backgroundColor))
                    .foregroundColor(Color(uiColor: viewStore.textColor))
                    .ignoresSafeArea()
                } failedView: { error in
                    Text("\(error.localizedDescription)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .background(Color(uiColor: viewStore.backgroundColor))
                        .foregroundColor(Color(uiColor: viewStore.textColor))
                        .ignoresSafeArea()
                } loadingView: {
                    Text("Loading")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .background(Color(uiColor: viewStore.backgroundColor))
                        .foregroundColor(Color(uiColor: viewStore.textColor))
                        .ignoresSafeArea()
                } pendingView: {
                    Text("not started")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .background(Color(uiColor: viewStore.backgroundColor))
                        .foregroundColor(Color(uiColor: viewStore.textColor))
                        .ignoresSafeArea()
                }
            }
            .background {
                if !viewStore.webviewState.htmlString.isEmpty && !viewStore.webviewState.javaScript.isEmpty {
                    if viewStore.infoLoadable.value != nil && !viewStore.infoLoadable.value!.epListURLs[0].isEmpty {
                        WebviewFeature.View(
                            store: self.store.scope(
                                state: \.webviewState,
                                action: Action.InternalAction.webview
                            ),
                            payload: viewStore.infoLoadable.value!.epListURLs[0],
                            action: "eplist"
                        ) { result in
                            print(result)
                            viewStore.send(.view(.parseMediaResult(data: result)))
                        }
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    } else {
                        WebviewFeature.View(
                            store: self.store.scope(
                                state: \.webviewState,
                                action: Action.InternalAction.webview
                            ),
                            payload: viewStore.url
                        ) { result in
                            print(result)
                            viewStore.send(.view(.parseResult(data: result)))
                        }
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    }
                }
            }
            .offset(x: isVisible ? dragState.width : UIScreen.main.bounds.width)
            .onAppear {
                print("onAppear")
                viewStore.send(.view(.info))
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragState = value.translation
                    }
                    .onEnded { value in
                        print(value.translation.width)
                        if value.translation.width > UIScreen.main.bounds.width - 100 {
                            // Swipe to the left, dismiss the second view
                            withAnimation(.easeInOut) {
                                isVisible = false
                            }
                        }
                        // Reset dragState
                        withAnimation(.easeInOut) {
                            dragState = .zero
                        }
                    }
            )
        }
    }
}

extension InfoFeature.View {
    @MainActor
    public func Header(proxy: GeometryProxy, viewStore: ViewStoreOf<InfoFeature>, infoData: InfoData) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            GeometryReader {reader in
                FillAspectImage(
                    url: URL(string: infoData.banner ?? infoData.poster)
                ) { image in
                    let averageColor = image.averageColor
                    
                    viewStore.send(.view(.setBackgroundColor(color: averageColor ?? .systemBackground)))
                }
                .blur(radius: 6.0)
                .overlay {
                    LinearGradient(stops: [
                        Gradient.Stop(
                            color: Color(uiColor: viewStore.backgroundColor).opacity(0.9),
                            location: 0.0),
                        Gradient.Stop(color: Color(uiColor: viewStore.backgroundColor).opacity(0.4), location: 1.0),
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
                    if let secondary = infoData.titles.secondary {
                        Text(secondary)
                            .font(.caption)
                            .fontWeight(.heavy)
                            .lineLimit(2)
                            .opacity(0.7)
                    }
                    
                    Text(infoData.titles.primary)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if let status = infoData.status {
                            Text(status)
                                .foregroundColor(Color(uiColor: viewStore.textColor == .white ? .lightIndigo : .systemIndigo))
                                .fontWeight(.bold)
                        }
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

extension InfoFeature.View {
    @MainActor
    public func ExtraInfo(viewStore: ViewStoreOf<InfoFeature>, infoData: InfoData) -> some View {
        VStack(alignment: .leading) {
            
            Text(infoData.description)
                .font(.subheadline)
                .lineLimit(9)
                .opacity(0.7)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            
            if infoData.mediaList.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 80, height: 20)
                            .redacted(reason: .placeholder)
                            .shimmering()
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(6)
                            .foregroundColor(.primary)
                            .background {
                                Circle()
                                    .fill(.regularMaterial)
                            }
                    }
                    .contentShape(Rectangle())
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 60, height: 15)
                            .redacted(reason: .placeholder)
                            .shimmering()
                            .opacity(0.7)
                        
                        Spacer()
                        
                        /*
                         Image("arrow.down.filter")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 16, height: 16)
                         .foregroundColor(.white)
                         .opacity(1.0)
                         .contentShape(Rectangle())
                         
                         Image("arrow.down.filter")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 16, height: 16)
                         .scaleEffect(CGSize(width: 1.0, height: -1.0))
                         .foregroundColor(.white)
                         .opacity(0.7)
                         .contentShape(Rectangle())
                         */
                    }
                }
                .padding(.vertical, 6)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(infoData.mediaList[0].title)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(6)
                            .foregroundColor(.primary)
                            .background {
                                Circle()
                                    .fill(.regularMaterial)
                            }
                    }
                    .contentShape(Rectangle())
                    
                    HStack {
                        Text("\(infoData.totalMediaCount ?? 0) \(infoData.mediaType)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .opacity(0.7)
                        
                        Spacer()
                        
                        /*
                         Image("arrow.down.filter")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 16, height: 16)
                         .foregroundColor(.white)
                         .opacity(1.0)
                         .contentShape(Rectangle())
                         
                         Image("arrow.down.filter")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 16, height: 16)
                         .scaleEffect(CGSize(width: 1.0, height: -1.0))
                         .foregroundColor(.white)
                         .opacity(0.7)
                         .contentShape(Rectangle())
                         */
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .padding(.top, 44)
        .padding(.horizontal, 20)
    }
}

extension InfoFeature.View {
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
    
    @MainActor
    func EpisodeList(viewStore: ViewStoreOf<InfoFeature>, infoData: InfoData, proxy: GeometryProxy) -> some View {
        VStack {
            // PAGINATION
            Group {
                if infoData.mediaList.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0 ..< 6, id: \.self) { page in
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.regularMaterial)
                                    .frame(width: 70, height: 27)
                                    .redacted(reason: .placeholder)
                                    .shimmering()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 6)
                    .padding(.top, 8)
                    .transition(.opacity)
                } else {
                    // pagination
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(1 ..< pageCount(infoData: infoData) + 1, id: \.self) { page in
                                Button(action: {
                                    //viewStore.send(.setCurrentPage(page: page))
                                }) {
                                    Text("\(episodeRange(forPage: page, infoData: infoData, mediaIncrease: true))")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .foregroundColor(.primary)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(.regularMaterial)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 6)
                    .padding(.top, 8)
                    .transition(.opacity)
                }
            }
            
            // LIST
            // TODO: add seasons value here
            if infoData.mediaList.count > 0 {
                let startIndex = true ?
                (viewStore.currentPage - 1) * mediaPerPage
                : infoData.mediaList[0].list.count - (viewStore.currentPage - 1) * mediaPerPage - (viewStore.currentPage == 1 ? 0 : 1)
                
                let endIndex = true ?
                min(viewStore.currentPage * mediaPerPage, infoData.mediaList[0].list.count)
                : max(infoData.mediaList[0].list.count - viewStore.currentPage * mediaPerPage - 1, 0)
                let episodeList = true ? Array(infoData.mediaList[0].list[startIndex..<endIndex]) : Array(infoData.mediaList[0].list[endIndex..<startIndex])
                
                ScrollView(.horizontal) {
                    HStack {
                        if true {
                            ForEach(episodeList, id: \.self) { episode in
                                EpisodeCard(item: episode, infoData: infoData, proxy: proxy)
                                    .frame(maxWidth: proxy.size.width - 140)
                                    .onTapGesture {
                                        viewStore.send(.view(.episodeTap(item: episode)), animation: .easeInOut)
                                    }
                            }
                        } else {
                            ForEach(episodeList.reversed(), id: \.self) { episode in
                                EpisodeCard(item: episode, infoData: infoData, proxy: proxy)
                                    .frame(maxWidth: proxy.size.width - 140)
                                    .onTapGesture {
                                        viewStore.send(.view(.episodeTap(item: episode)), animation: .easeInOut)
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

extension InfoFeature.View {
    func forTrailingZero(temp: Double) -> String {
        return String(format: "%g", temp)
    }
    
    func secondsToMinute(sec: Double) -> String {
        let minutes = Int(sec / 60)
        let minuteText = minutes == 1 ? "Min left" : "Mins left"
        
        return "\(minutes) \(minuteText)"
    }
    
    @MainActor
    func EpisodeCard(item: MediaItem, infoData: InfoData, proxy: GeometryProxy) -> some View {
        VStack {
            KFImage(URL(string: item.image ?? infoData.poster))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: proxy.size.width - 140, maxWidth: proxy.size.width - 140, minHeight: (proxy.size.width - 140) / 16 * 9, maxHeight: (proxy.size.width - 140) / 16 * 9)
                .cornerRadius(12)
            /*
                .overlay(alignment: .topTrailing) {
                    HStack {
                        /*
                         if let prog = progress {
                         if prog.progress / prog.duration > 0.8 {
                         Text("Watched")
                         .font(.title2)
                         .fontWeight(.bold)
                         .foregroundColor(.white)
                         }
                         }
                         */
                        
                        Button {
                            // Download button pressed
                            // store infodata as json
                            downloadManager.storeInfo(infoData, self.url)
                        } label: {
                            Image(systemName: downloaded ? "checkmark" : "square.and.arrow.down")
                                .font(.caption)
                                .padding(10)
                                .foregroundColor(Color(hex: Colors.onSurface.dark))
                                .background {
                                    Circle()
                                        .fill(
                                            Color(hex: Colors.SurfaceContainer.dark)
                                        )
                                }
                                .overlay {
                                    Circle()
                                        .trim(from: 0.0, to: downloadProgress)
                                        .stroke(
                                            Color(hex: Colors.Primary.dark),
                                            style: StrokeStyle(
                                                lineWidth: 2,
                                                lineCap: .round
                                            )
                                        )
                                        .rotationEffect(Angle(degrees: -90))
                                }
                        }
                        Spacer()
                        
                        
                        Text("\(forTrailingZero(temp: item.number))")
                            .fontWeight(.bold)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .foregroundColor(Color(hex: Colors.onPrimary.dark))
                            .background {
                                Capsule()
                                    .fill(Color(hex: Colors.Primary.dark))
                            }
                    }
                    .padding(12)
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
            */
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

#Preview("Info") {
    InfoFeature.View(
        store: .init(
            initialState: .init(
                url: ""
            ),
            reducer: { InfoFeature() }
        )
    )
}
