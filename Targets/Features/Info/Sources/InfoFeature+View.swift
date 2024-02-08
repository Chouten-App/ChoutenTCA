//
//  InfoFeature+View.swift
//
//
//  Created by Inumaki on 16.10.23.
//
// swiftlint:disable identifier_name file_length

import ComposableArchitecture
import CoreImage
import Kingfisher
import NukeUI
import SharedModels
import Shimmer
import SwiftUI
import ViewComponents
import Webview

// MARK: - ColorTheme

public struct ColorTheme: Equatable, Sendable {
  public let averageColor: Color
  public let contrastingTone: Color
  public let accentColor: Color
  public let accentText: Color
  public let dark: Bool
}

// MARK: - ColorThemeError

enum ColorThemeError: Error {
  case averageColorFailed
}

extension ColorTheme {
  static func generate(from image: UIImage) throws -> ColorTheme {
    guard let baseColor = image.averageColor else { throw ColorThemeError.averageColorFailed }

    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 0

    baseColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

    let contrastingTone = isLight(baseColor) ?
      UIColor(
        hue: hue,
        saturation: 0.9,
        brightness: 0.1,
        alpha: alpha
      ) :
      UIColor(
        hue: hue,
        saturation: min(saturation, 0.15),
        brightness: 0.95,
        alpha: alpha
      )

    let accentColor = UIColor(
      hue: (hue + 0.05).truncatingRemainder(dividingBy: 1),
      saturation: min(saturation * 2, 0.4),
      brightness: min(brightness * 3, 0.9),
      alpha: alpha
    )

    var accentHue: CGFloat = 0
    var accentSaturation: CGFloat = 0
    var accentBrightness: CGFloat = 0
    var accentAlpha: CGFloat = 0

    accentColor.getHue(&accentHue, saturation: &accentSaturation, brightness: &accentBrightness, alpha: &accentAlpha)

    let accentText = UIColor(
      hue: accentHue,
      saturation: min(accentSaturation, 0.1),
      brightness: isLight(accentColor) ? 0.05 : 0.95,
      alpha: accentAlpha
    )

    return ColorTheme(
      averageColor: Color(baseColor),
      contrastingTone: Color(contrastingTone),
      accentColor: Color(accentColor),
      accentText: Color(accentText),
      dark: !isLight(baseColor)
    )
  }

  private static func isLight(_ color: UIColor) -> Bool {
    var white: CGFloat = 0
    var alpha: CGFloat = 0

    color.getWhite(&white, alpha: &alpha)

    return white >= 0.5
  }
}

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

// MARK: - InfoFeature.View + View

extension InfoFeature.View: View {
  @MainActor public var body: some View {
    WithPerceptionTracking {
      GeometryReader { proxy in
        LoadableView(loadable: store.infoLoadable) { infoData in
          if proxy.size.width > 900 {
            HStack {
              ScrollView {
                VStack {
                  Header(proxy: proxy, infoData: infoData)

                  ExtraInfo(proxy: proxy, infoData: infoData)
                }
              }
              .frame(maxWidth: proxy.size.width - 360, maxHeight: .infinity, alignment: .top)

              ScrollView {
                VStack(alignment: .leading) {
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

                        // Image("arrow.down.filter")
                        // .resizable()
                        // .aspectRatio(contentMode: .fit)
                        // .frame(width: 16, height: 16)
                        // .foregroundColor(.white)
                        // .opacity(1.0)
                        // .contentShape(Rectangle())
                        //
                        // Image("arrow.down.filter")
                        // .resizable()
                        // .aspectRatio(contentMode: .fit)
                        // .frame(width: 16, height: 16)
                        // .scaleEffect(CGSize(width: 1.0, height: -1.0))
                        // .foregroundColor(.white)
                        // .opacity(0.7)
                        // .contentShape(Rectangle())
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

                        // Image("arrow.down.filter")
                        // .resizable()
                        // .aspectRatio(contentMode: .fit)
                        // .frame(width: 16, height: 16)
                        // .foregroundColor(.white)
                        // .opacity(1.0)
                        // .contentShape(Rectangle())
                        //
                        // Image("arrow.down.filter")
                        // .resizable()
                        // .aspectRatio(contentMode: .fit)
                        // .frame(width: 16, height: 16)
                        // .scaleEffect(CGSize(width: 1.0, height: -1.0))
                        // .foregroundColor(.white)
                        // .opacity(0.7)
                        // .contentShape(Rectangle())
                      }
                    }
                    .padding(.vertical, 6)
                    .padding(.trailing, 24)
                    .padding(.leading, 20)
                    .padding(.top, 20)
                  }

                  EpisodeList(infoData: infoData, proxy: proxy)
                }
              }
              .frame(minWidth: 360, maxWidth: 360, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(store.colorTheme.averageColor)
            .foregroundColor(store.colorTheme.contrastingTone)
            .ignoresSafeArea()
          } else {
            ScrollView {
              VStack {
                Header(proxy: proxy, infoData: infoData)

                ExtraInfo(proxy: proxy, infoData: infoData)

                EpisodeList(infoData: infoData, proxy: proxy)
              }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(store.colorTheme.averageColor)
            .foregroundColor(store.colorTheme.contrastingTone)
            .ignoresSafeArea()
          }
        } failedView: { error in
          Text("\(error.localizedDescription)")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(store.colorTheme.averageColor)
            .foregroundColor(store.colorTheme.contrastingTone)
            .ignoresSafeArea()
        } loadingView: {
          ScrollView {
            VStack {
              ShimmerHeader(proxy: proxy)

              ShimmerExtraInfo()

              ShimmerEpisodeList(proxy: proxy)
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
          .background(store.colorTheme.averageColor)
          .foregroundColor(store.colorTheme.contrastingTone)
          .ignoresSafeArea()
        } pendingView: {
          ScrollView {
            VStack {
              ShimmerHeader(proxy: proxy)

              ShimmerExtraInfo()

              ShimmerEpisodeList(proxy: proxy)
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
          .background(store.colorTheme.averageColor)
          .foregroundColor(store.colorTheme.contrastingTone)
          .ignoresSafeArea()
        }
        .overlay(alignment: .topLeading) {
          Navbar()
            .frame(maxWidth: proxy.size.width > 900 ? proxy.size.width - 410 : .infinity)
        }
      }
      .background {
        if !store.webviewState.htmlString.isEmpty, !store.webviewState.javaScript.isEmpty {
          if let info = store.infoLoadable.value, let episodes = info.epListURLs.first, !episodes.isEmpty {
            WebviewFeature.View(
              store: self.store.scope(
                state: \.webviewState,
                action: \.internal.webview
              ),
              payload: episodes,
              action: "eplist"
            ) { result in
              print(result)
              store.send(.view(.parseMediaResult(data: result)))
            }
            .hidden()
            .frame(maxWidth: 0, maxHeight: 0)
          } else {
            WebviewFeature.View(
              store: self.store.scope(
                state: \.webviewState,
                action: \.internal.webview
              ),
              payload: store.url
            ) { result in
              print(result)
              store.send(.view(.parseResult(data: result)))
            }
            .hidden()
            .frame(maxWidth: 0, maxHeight: 0)
          }
        }
      }
      .offset(x: isVisible ? dragState.width : UIScreen.main.bounds.width)
      .onAppear {
        print("onAppear")
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
          store.send(.view(.setInfoData(data: InfoData.sample)))
        } else {
          store.send(.view(.info))
        }
      }
      .overlay(alignment: .leading) {
        Color.clear
          .contentShape(Rectangle())
          .frame(maxWidth: 30)
          .ignoresSafeArea()
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
}

extension InfoFeature.View {
  @MainActor
  func Navbar() -> some View {
    HStack {
      Button {
        store.send(.view(.navigateBack))
      } label: {
        Image(systemName: "chevron.left")
          .font(.caption)
          .foregroundColor(
            store.colorTheme.accentText
          )
          .padding(8)
          .background {
            Circle()
              .fill(
                store.colorTheme.accentColor
              )
          }
          .contentShape(Rectangle())
          .foregroundColor(.white)
      }

      Spacer()

      Button {} label: {
        Image(systemName: "bookmark")
          .font(.caption)
          .foregroundColor(
            store.colorTheme.accentText
          )
          .padding(8)
          .background {
            Circle()
              .fill(
                store.colorTheme.accentColor
              )
          }
          .contentShape(Rectangle())
          .foregroundColor(.white)
      }

      Button {} label: {
        Image(systemName: "square.and.arrow.down")
          .font(.caption)
          .foregroundColor(
            store.colorTheme.accentText
          )
          .padding(8)
          .background {
            Circle()
              .fill(
                store.colorTheme.accentColor
              )
          }
          .contentShape(Rectangle())
          .foregroundColor(.white)
      }
    }
    .padding(.horizontal)
    .frame(maxWidth: .infinity)
  }
}

extension InfoFeature.View {
  @MainActor
  public func Header(proxy _: GeometryProxy, infoData: InfoData) -> some View {
    ZStack(alignment: .bottomLeading) {
      // Background image
      GeometryReader { reader in
        FillAspectImage(
          url: URL(string: infoData.banner ?? infoData.poster)
        ) { image in
          if store.dynamicInfo {
            do {
              let theme = try ColorTheme.generate(from: image)
              store.send(
                .view(
                  .setColorTheme(theme)
                )
              )
            } catch {
              print(error.localizedDescription)
            }
          }
        }
        .blur(radius: 6.0)
        .overlay {
          LinearGradient(stops: [
            Gradient.Stop(
              color: store.colorTheme.averageColor.opacity(0.9),
              location: 0.0
            ),
            Gradient.Stop(color: store.colorTheme.averageColor.opacity(0.4), location: 1.0)
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
      .frame(maxWidth: .infinity)

      // Info
      HStack(alignment: .bottom) {
        LazyImage(
          url: URL(string: infoData.poster),
          transaction: .init(animation: .easeInOut(duration: 0.4))
        ) { state in
          if let image = state.image {
            image
              .resizable()
          } else {
            let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)

            RoundedRectangle(cornerRadius: 12)
              .frame(width: 120, height: 180)
              .shimmering(
                active: true,
                animation: anim
              )
              .opacity(0.3)
          }
        }
        .scaledToFill()
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

          HStack(spacing: 8) {
            if let status = infoData.status {
              Text(status)
                .foregroundColor(store.colorTheme.accentColor)
                .fontWeight(.bold)
            }

            Spacer()

            if let rating = infoData.rating {
              let formatted = String(format: "%.1f", rating)
              HStack {
                Text(formatted)
                  .font(.subheadline)
                  .fontWeight(.bold)
                Image(systemName: "heart.fill")
                  .foregroundColor(.red)
              }
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
      .frame(maxWidth: .infinity)
    }
    .frame(maxWidth: .infinity)
  }

  @MainActor
  public func ShimmerHeader(proxy: GeometryProxy) -> some View {
    ZStack(alignment: .bottomLeading) {
      // Background image
      GeometryReader { reader in
        GeometryReader { inner_proxy in
          Rectangle()
            .frame(
              width: inner_proxy.size.width,
              height: inner_proxy.size.height,
              alignment: .center
            )
            .redacted(reason: .placeholder)
            .shimmering()
            .opacity(0.4)
        }
        .blur(radius: 6.0)
        .overlay {
          LinearGradient(stops: [
            Gradient.Stop(
              color: store.colorTheme.averageColor.opacity(0.9),
              location: 0.0
            ),
            Gradient.Stop(color: store.colorTheme.averageColor.opacity(0.4), location: 1.0)
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
        RoundedRectangle(cornerRadius: 12)
          .frame(maxWidth: 120, maxHeight: 180)
          .redacted(reason: .placeholder)
          .shimmering()
          .opacity(0.3)

        VStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 6)
            .frame(maxWidth: 60, maxHeight: 12)
            .redacted(reason: .placeholder)
            .shimmering()
            .opacity(0.2)

          RoundedRectangle(cornerRadius: 6)
            .frame(maxWidth: 80, maxHeight: 18)
            .redacted(reason: .placeholder)
            .shimmering()
            .opacity(0.4)

          HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 6)
              .frame(maxWidth: 40, maxHeight: 12)
              .redacted(reason: .placeholder)
              .shimmering()
              .opacity(0.2)

            Spacer()

            HStack {
              RoundedRectangle(cornerRadius: 6)
                .frame(maxWidth: 40, maxHeight: 15)
                .redacted(reason: .placeholder)
                .shimmering()
                .opacity(0.2)

              Circle()
                .frame(maxWidth: 22, maxHeight: 22)
                .redacted(reason: .placeholder)
                .shimmering()
                .opacity(0.2)
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
  public func ExtraInfo(proxy: GeometryProxy, infoData: InfoData) -> some View {
    VStack(alignment: .leading) {
      // Tags
      if !infoData.altTitles.isEmpty {
        ScrollView(.horizontal) {
          HStack {
            ForEach(infoData.altTitles, id: \.self) { tag in
              Text(tag)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(.regularMaterial)
                .cornerRadius(6)
            }
          }
          .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
        .preferredColorScheme(store.colorTheme.dark ? .dark : .light)
      }

      Text(infoData.description)
        .font(.subheadline)
        .lineLimit(9)
        .opacity(0.7)
        .padding(.vertical, 6)
        .contentShape(Rectangle())

      if proxy.size.width < 900 {
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

              // Image("arrow.down.filter")
              // .resizable()
              // .aspectRatio(contentMode: .fit)
              // .frame(width: 16, height: 16)
              // .foregroundColor(.white)
              // .opacity(1.0)
              // .contentShape(Rectangle())
              //
              // Image("arrow.down.filter")
              // .resizable()
              // .aspectRatio(contentMode: .fit)
              // .frame(width: 16, height: 16)
              // .scaleEffect(CGSize(width: 1.0, height: -1.0))
              // .foregroundColor(.white)
              // .opacity(0.7)
              // .contentShape(Rectangle())
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

              // Image("arrow.down.filter")
              // .resizable()
              // .aspectRatio(contentMode: .fit)
              // .frame(width: 16, height: 16)
              // .foregroundColor(.white)
              // .opacity(1.0)
              // .contentShape(Rectangle())
              //
              // Image("arrow.down.filter")
              // .resizable()
              // .aspectRatio(contentMode: .fit)
              // .frame(width: 16, height: 16)
              // .scaleEffect(CGSize(width: 1.0, height: -1.0))
              // .foregroundColor(.white)
              // .opacity(0.7)
              // .contentShape(Rectangle())
            }
          }
          .padding(.vertical, 6)
        }
      }
    }
    .padding(.top, 44)
    .padding(.horizontal, 20)
  }

  @MainActor
  public func ShimmerExtraInfo() -> some View {
    VStack(alignment: .leading) {
      // Tags
      ScrollView(.horizontal) {
        HStack {
          ForEach(0..<10, id: \.self) { _ in
            RoundedRectangle(cornerRadius: 6)
              .frame(width: 32, height: 12)
              .redacted(reason: .placeholder)
              .shimmering()
              .opacity(0.0)
              .padding(.vertical, 8)
              .padding(.horizontal, 12)
              .background(.regularMaterial)
              .cornerRadius(8)
              .redacted(reason: .placeholder)
              .shimmering()
          }
        }
        .padding(.horizontal, 20)
      }
      .padding(.horizontal, -20)
      .padding(.bottom, 12)
      .preferredColorScheme(store.colorTheme.dark ? .dark : .light)

      VStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: 6)
          .frame(maxWidth: .infinity, minHeight: 15, maxHeight: 15)
          .redacted(reason: .placeholder)
          .shimmering()
        RoundedRectangle(cornerRadius: 6)
          .frame(maxWidth: .infinity, minHeight: 15, maxHeight: 15)
          .redacted(reason: .placeholder)
          .shimmering()
        RoundedRectangle(cornerRadius: 6)
          .frame(maxWidth: .infinity, minHeight: 15, maxHeight: 15)
          .redacted(reason: .placeholder)
          .shimmering()
        RoundedRectangle(cornerRadius: 6)
          .frame(maxWidth: .infinity, minHeight: 15, maxHeight: 15)
          .redacted(reason: .placeholder)
          .shimmering()
        RoundedRectangle(cornerRadius: 6)
          .frame(maxWidth: .infinity, minHeight: 15, maxHeight: 15)
          .redacted(reason: .placeholder)
          .shimmering()
        RoundedRectangle(cornerRadius: 6)
          .frame(maxWidth: .infinity, minHeight: 15, maxHeight: 15)
          .redacted(reason: .placeholder)
          .shimmering()
        RoundedRectangle(cornerRadius: 6)
          .frame(maxWidth: .infinity, minHeight: 15, maxHeight: 15)
          .redacted(reason: .placeholder)
          .shimmering()
        RoundedRectangle(cornerRadius: 6)
          .frame(maxWidth: .infinity, minHeight: 15, maxHeight: 15)
          .redacted(reason: .placeholder)
          .shimmering()
        RoundedRectangle(cornerRadius: 6)
          .frame(maxWidth: 200, minHeight: 15, maxHeight: 15)
          .redacted(reason: .placeholder)
          .shimmering()
      }
      .opacity(0.3)

      VStack(alignment: .leading, spacing: 6) {
        HStack {
          RoundedRectangle(cornerRadius: 6)
            .frame(width: 80, height: 20)
            .redacted(reason: .placeholder)
            .shimmering()
            .opacity(0.4)

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
            .opacity(0.2)

          Spacer()

          // Image("arrow.down.filter")
          // .resizable()
          // .aspectRatio(contentMode: .fit)
          // .frame(width: 16, height: 16)
          // .foregroundColor(.white)
          // .opacity(1.0)
          // .contentShape(Rectangle())
          //
          // Image("arrow.down.filter")
          // .resizable()
          // .aspectRatio(contentMode: .fit)
          // .frame(width: 16, height: 16)
          // .scaleEffect(CGSize(width: 1.0, height: -1.0))
          // .foregroundColor(.white)
          // .opacity(0.7)
          // .contentShape(Rectangle())
        }
      }
      .padding(.vertical, 6)
    }
    .padding(.top, 44)
    .padding(.horizontal, 20)
  }
}

extension InfoFeature.View {
  // Calculate the total number of pages
  func pageCount(infoData: InfoData) -> Int {
    if infoData.mediaList.isEmpty {
      return 0
    }
    return (infoData.mediaList[0].list.count + mediaPerPage - 1) / mediaPerPage
  }

  // Calculate the episode range for a given page
  func episodeRange(forPage page: Int, infoData: InfoData, mediaIncrease: Bool = true) -> String {
    if infoData.mediaList.isEmpty {
      return ""
    }

    if mediaIncrease {
      let startIndex = (page - 1) * mediaPerPage
      let endIndex = min(page * mediaPerPage, infoData.mediaList[0].list.count)
      return "\(startIndex + 1) - \(endIndex)"
    } else {
      let startIndex = infoData.mediaList[0].list.count - (page - 1) * mediaPerPage
      let endIndex = max(infoData.mediaList[0].list.count - page * mediaPerPage, 1)
      return "\(startIndex == infoData.mediaList[0].list.count ? startIndex : startIndex - 1) - \(endIndex)"
    }
  }

  @MainActor
  func EpisodeList(infoData: InfoData, proxy: GeometryProxy) -> some View {
    VStack {
      // PAGINATION
      Group {
        if infoData.mediaList.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack {
              ForEach(0..<6, id: \.self) { _ in
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
          if infoData.mediaList[0].list.count > 12 {
            ScrollView(.horizontal, showsIndicators: false) {
              HStack {
                ForEach(1..<pageCount(infoData: infoData) + 1, id: \.self) { page in
                  Button(action: {
                    // store.send(.setCurrentPage(page: page))
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
      }

      // LIST
      // TODO: add seasons value here
      if !infoData.mediaList.isEmpty {
        let startIndex = true ?
          (store.currentPage - 1) * mediaPerPage
          : infoData.mediaList[0].list.count - (store.currentPage - 1) * mediaPerPage - (store.currentPage == 1 ? 0 : 1)

        let endIndex = true ?
          min(store.currentPage * mediaPerPage, infoData.mediaList[0].list.count)
          : max(infoData.mediaList[0].list.count - store.currentPage * mediaPerPage - 1, 0)
        let episodeList = true ? Array(infoData.mediaList[0].list[startIndex..<endIndex]) : Array(infoData.mediaList[0].list[endIndex..<startIndex])

        ScrollView(proxy.size.width > 900 ? .vertical : .horizontal) {
          if proxy.size.width > 900 {
            VStack {
              if true {
                ForEach(episodeList, id: \.self) { episode in
                  EpisodeCard(item: episode, infoData: infoData, proxy: proxy)
                    .frame(maxWidth: 320)
                    .onTapGesture {
                      store.send(.view(.episodeTap(item: episode, index: episodeList.firstIndex { $0 == episode } ?? 0)), animation: .easeInOut)
                    }
                }
              } else {
                ForEach(episodeList.reversed(), id: \.self) { episode in
                  EpisodeCard(item: episode, infoData: infoData, proxy: proxy)
                    .frame(maxWidth: 320)
                    .onTapGesture {
                      store.send(.view(.episodeTap(item: episode, index: episodeList.firstIndex { $0 == episode } ?? 0)), animation: .easeInOut)
                    }
                }
              }
            }
            .padding(.horizontal, 20)
          } else {
            HStack {
              if true {
                ForEach(episodeList, id: \.self) { episode in
                  EpisodeCard(item: episode, infoData: infoData, proxy: proxy)
                    .frame(width: proxy.size.width - 140)
                    .onTapGesture {
                      store.send(.view(.episodeTap(item: episode, index: episodeList.firstIndex { $0 == episode } ?? 0)), animation: .easeInOut)
                    }
                }
              } else {
                ForEach(episodeList.reversed(), id: \.self) { episode in
                  EpisodeCard(item: episode, infoData: infoData, proxy: proxy)
                    .frame(maxWidth: proxy.size.width - 140)
                    .onTapGesture {
                      store.send(.view(.episodeTap(item: episode, index: episodeList.firstIndex { $0 == episode } ?? 0)), animation: .easeInOut)
                    }
                }
              }
            }
            .padding(.horizontal, 20)
          }
        }
        .padding(.bottom, 40)
      }
    }
  }

  @MainActor
  func ShimmerEpisodeList(proxy: GeometryProxy) -> some View {
    VStack {
      // PAGINATION
      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          ForEach(0..<6, id: \.self) { _ in
            RoundedRectangle(cornerRadius: 6)
              .fill(.regularMaterial)
              .frame(width: 70, height: 27)
              .redacted(reason: .placeholder)
              .shimmering()
              .opacity(0.4)
          }
        }
        .padding(.horizontal)
      }
      .padding(.bottom, 6)
      .padding(.top, 8)

      ScrollView(.horizontal) {
        HStack {
          ForEach(0..<12, id: \.self) { _ in
            ShimmerEpisodeCard(proxy: proxy)
              .frame(maxWidth: proxy.size.width - 140, maxHeight: (proxy.size.width - 140) / 16 * 9)
          }
        }
        .padding(.horizontal, 20)
      }
      .padding(.bottom, 40)
    }
  }
}

extension InfoFeature.View {
  func forTrailingZero(temp: Double) -> String {
    String(format: "%g", temp)
  }

  func secondsToMinute(sec: Double) -> String {
    let minutes = Int(sec / 60)
    let minuteText = minutes == 1 ? "Min left" : "Mins left"

    return "\(minutes) \(minuteText)"
  }

  @MainActor
  func EpisodeCard(item: MediaItem, infoData: InfoData, proxy _: GeometryProxy) -> some View {
    VStack {
      LazyImage(
        url: URL(string: item.image ?? infoData.poster),
        transaction: .init(animation: .easeInOut(duration: 0.4))
      ) { state in
        if let image = state.image {
          image
            .resizable()
        } else {
          let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)

          RoundedRectangle(cornerRadius: 12)
            .frame(width: 320, height: 320 / 16 * 9)
            .shimmering(
              active: true,
              animation: anim
            )
            .opacity(0.3)
        }
      }
      .scaledToFill()
      .frame(width: 320, height: 320 / 16 * 9)
      .cornerRadius(12)
      .overlay(alignment: .topTrailing) {
        Text(forTrailingZero(temp: item.number))
          .fontWeight(.semibold)
          .foregroundColor(
            store.colorTheme.accentText
          )
          .padding(.vertical, 2)
          .padding(.horizontal, 8)
          .background {
            Capsule()
              .fill(
                store.colorTheme.accentColor
              )
          }
          .padding()
      }
      //    .overlay(alignment: .topTrailing) {
      //        HStack {
      //
      //             if let prog = progress {
      //             if prog.progress / prog.duration > 0.8 {
      //             Text("Watched")
      //             .font(.title2)
      //             .fontWeight(.bold)
      //             .foregroundColor(.white)
      //             }
      //             }
      //
      //
      //            Button {
      //                // Download button pressed
      //                // store infodata as json
      //                downloadManager.storeInfo(infoData, self.url)
      //            } label: {
      //                Image(systemName: downloaded ? "checkmark" : "square.and.arrow.down")
      //                    .font(.caption)
      //                    .padding(10)
      //                    .foregroundColor(Color(hex: Colors.onSurface.dark))
      //                    .background {
      //                        Circle()
      //                            .fill(
      //                                Color(hex: Colors.SurfaceContainer.dark)
      //                            )
      //                    }
      //                    .overlay {
      //                        Circle()
      //                            .trim(from: 0.0, to: downloadProgress)
      //                            .stroke(
      //                                Color(hex: Colors.Primary.dark),
      //                                style: StrokeStyle(
      //                                    lineWidth: 2,
      //                                    lineCap: .round
      //                                )
      //                            )
      //                            .rotationEffect(Angle(degrees: -90))
      //                    }
      //            }
      //            Spacer()
      //
      //
      //            Text("\(forTrailingZero(temp: item.number))")
      //                .fontWeight(.bold)
      //                .padding(.vertical, 4)
      //                .padding(.horizontal, 12)
      //                .foregroundColor(Color(hex: Colors.onPrimary.dark))
      //                .background {
      //                    Capsule()
      //                        .fill(Color(hex: Colors.Primary.dark))
      //                }
      //        }
      //        .padding(12)
      //    }
      //    .overlay(alignment: .bottom) {
      //        if let prog = progress {
      //            if prog.progress / prog.duration < 0.8 {
      //                VStack(alignment: .trailing, spacing: 6) {
      //                    Text(secondsToMinute(sec: prog.duration - prog.progress))
      //                        .font(.caption2)
      //                        .fontWeight(.bold)
      //                        .foregroundColor(.white)
      //
      //                    ZStack {
      //                        Capsule()
      //                            .fill(.white.opacity(0.4))
      //                            .frame(height: 4)
      //                        Capsule()
      //                            .fill(Color(hex: Colors.Primary.dark))
      //                            .frame(height: 4)
      //                            .offset(
      //                                x: -134
      //                                + (
      //                                    134 * (
      //                                        (prog.progress / prog.duration)
      //                                    )
      //                                )
      //                            )
      //                    }
      //                    .frame(height: 4)
      //                    .cornerRadius(4)
      //                    .clipped()
      //                }
      //                .padding(12)
      //                //.frame(maxHeight: 24)
      //            }
      //        }
      //
      //    }
      VStack(spacing: 4) {
        Text(item.title ?? "Episode \(forTrailingZero(temp: item.number))")
          .fontWeight(.semibold)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)

        // Text("Filler")
        // .font(.caption)
        // .fontWeight(.bold)
        // .foregroundColor(Color(hex: Colors.Primary.dark))
        // .frame(maxWidth: .infinity, alignment: .leading)
        // .padding(.vertical, 4)
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

  @MainActor
  func ShimmerEpisodeCard(proxy: GeometryProxy) -> some View {
    VStack {
      RoundedRectangle(cornerRadius: 12)
        .frame(minWidth: proxy.size.width - 140, maxWidth: proxy.size.width - 140, minHeight: (proxy.size.width - 140) / 16 * 9, maxHeight: (proxy.size.width - 140) / 16 * 9)
        .redacted(reason: .placeholder)
        .shimmering()
        .opacity(0.3)
        .overlay(alignment: .topTrailing) {
          RoundedRectangle(cornerRadius: 12)
            .frame(width: 16, height: 16)
            .opacity(0.0)
            .foregroundColor(
              store.colorTheme.accentText
            )
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background {
              Capsule()
                .fill(
                  store.colorTheme.accentColor
                )
                .redacted(reason: .placeholder)
                .shimmering()
                .opacity(0.3)
            }
            .padding()
        }

      VStack(spacing: 4) {
        RoundedRectangle(cornerRadius: 6)
          .frame(width: 44, height: 16)
          .redacted(reason: .placeholder)
          .shimmering()
          .opacity(0.4)
          .frame(maxWidth: .infinity, alignment: .leading)

        VStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 6)
            .frame(width: proxy.size.width - 140 - 24, height: 14)
            .redacted(reason: .placeholder)
            .shimmering()
            .opacity(0.2)
          RoundedRectangle(cornerRadius: 6)
            .frame(width: proxy.size.width - 140 - 24, height: 14)
            .redacted(reason: .placeholder)
            .shimmering()
            .opacity(0.2)
          RoundedRectangle(cornerRadius: 6)
            .frame(width: 60, height: 14)
            .redacted(reason: .placeholder)
            .shimmering()
            .opacity(0.2)
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
