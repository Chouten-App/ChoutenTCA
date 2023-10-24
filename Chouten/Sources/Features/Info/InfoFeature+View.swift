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
                Group {
                    switch viewStore.state.state {
                    case .notStarted:
                        Text("not started")
                    case .loading:
                        Text("loading")
                    case .error:
                        Text("error")
                    case .success:
                        ScrollView {
                            VStack {
                                Header(proxy: proxy, viewStore: viewStore)
                                
                                ExtraInfo(viewStore: viewStore)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .background(Color(uiColor: viewStore.backgroundColor))
                        .foregroundColor(Color(uiColor: viewStore.textColor))
                        .ignoresSafeArea()
                    }
                }
            }
            .background {
                if !viewStore.webviewState.htmlString.isEmpty && !viewStore.webviewState.javaScript.isEmpty {
                    WebviewFeature.View(
                        store: self.store.scope(
                            state: \.webviewState,
                            action: Action.InternalAction.webview
                        ),
                        payload: viewStore.url
                    ) { result in
                        print(result)
                        /*
                        viewStore.send(.parseResult(data: result))
                         */
                    }
                    .hidden()
                    .frame(maxWidth: 0, maxHeight: 0)
                }
            }
        }
    }
}

extension InfoFeature.View {
    @MainActor
    public func Header(proxy: GeometryProxy, viewStore: ViewStoreOf<InfoFeature>) -> some View {
        ZStack(alignment: .bottomLeading) {
            let infoData = viewStore.infoData
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
    public func ExtraInfo(viewStore: ViewStoreOf<InfoFeature>) -> some View {
        VStack(alignment: .leading) {
            let infoData = viewStore.infoData
            Text(infoData.description)
                .font(.subheadline)
                .lineLimit(9)
                .opacity(0.7)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Season 1")
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
            
            
            // pagination
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0 ..< 2, id: \.self) { page in
                        Button(action: {
                            //viewStore.send(.setCurrentPage(page: page))
                        }) {
                            Text("\(page * 50 + 1) - \(page * 50 + 50)")
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
            }
            .padding(.bottom, 6)
            .padding(.top, 8)
        }
        .padding(.top, 44)
        .padding(.horizontal, 20)
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
