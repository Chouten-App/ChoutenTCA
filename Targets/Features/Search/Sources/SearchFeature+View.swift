//
//  SearchFeature+View.swift
//
//
//  Created by Inumaki on 14.10.23.
//
// swiftlint:disable identifier_name

import ASCollectionView
import ComposableArchitecture
import Info
import Kingfisher
import NukeUI
import SharedModels
import Shimmer
import SwiftUI
import ViewComponents
import Webview

// MARK: - ScrollOffsetPreferenceKey

struct ScrollOffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGPoint = .zero

  static func reduce(value _: inout CGPoint, nextValue _: () -> CGPoint) {}
}

extension SearchFeature.View {
  @MainActor public var body: some View {
    WithPerceptionTracking {
      GeometryReader { proxy in
        ZStack {
          LoadableView(loadable: store.searchLoadable) { results in
            SuccessView(
              results: results,
              proxy: proxy
            )
          } failedView: { _ in
            ErrorView()
          } loadingView: {
            LoadingView(proxy: proxy)
          } pendingView: {
            NotStartedView(proxy: proxy)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.black)
          .background {
            if !store.webviewState.htmlString.isEmpty, !store.webviewState.javaScript.isEmpty {
              WebviewFeature.View(
                store: self.store.scope(
                  state: \.webviewState,
                  action: \.internal.webview
                ),
                payload: "{\"query\": \"\(store.query)\", \"page\": \(store.page)}"
              ) { result in
                send(.parseResult(data: result))
              }
              .hidden()
              .frame(maxWidth: 0, maxHeight: 0)
            }
          }
          .overlay(alignment: .top) {
            Navbar(proxy: proxy)
          }

          if store.infoVisible {
            InfoFeature.View(
              store: self.store.scope(
                state: \.info,
                action: \.internal.info
              ),
              isVisible: $store.infoVisible.sending(\.view.setInfoVisible),
              dragState: $store.dragState.sending(\.view.setDragState)
            )
            .transition(.move(edge: .trailing))
          }
        }
        .onAppear {
          // TODO: move to reducer
          if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            // viewStore.send(.setLoadable(.loading))
            send(.setSearchData(SearchData.sampleList))
          }
        }
        .onChange(of: searchbarFocused) { newValue in
          send(.setSearchFocused(newValue))
        }
      }
    }
  }
}

// navbar
extension SearchFeature.View {
  @MainActor
  func Navbar(proxy _: GeometryProxy) -> some View {
    HStack {
      if !store.searchFocused {
        NavigationBackButton {
          send(.backButtonPressed, animation: .easeInOut)
        }
        .animation(.easeInOut, value: store.searchFocused)
        .transition(.move(edge: .leading))
      }

      ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: store.searchFocused ? 12 : 6)
          .fill(.regularMaterial)
          .frame(maxWidth: .infinity, maxHeight: 32)
          .matchedGeometryEffect(id: "searchBG", in: animation)

        VStack {
          HStack {
            Image(systemName: "magnifyingglass")
              .font(.subheadline)
              .foregroundColor(.primary)
              .matchedGeometryEffect(id: "searchIcon", in: animation)

            TextField("Search for something", text: $store.query) {
              send(.search)
            }
            .tint(.indigo)
            .focused($searchbarFocused)
          }
        }
        .padding(.horizontal, 8)
        .padding(.top, 5)
      }
      .animation(.easeInOut, value: store.searchFocused)
    }
    .clipped()
    .padding(.bottom)
    .padding(.horizontal)
    .background(
      .regularMaterial
        .opacity(store.headerOpacity)
    )
    /// .overlay(alignment: .bottom) {
    //    if searchbarFocused {
    //        VStack(alignment: .leading, spacing: 8) {
    //            ForEach(0..<viewStore.queryHistory.count, id: \.self) { index in
    //                let history = viewStore.queryHistory[index]
    //
    //                VStack {
    //                    HStack {
    //                        Text(history)
    //                            .font(.subheadline)
    //                            .lineLimit(1)
    //                            .opacity(0.7)
    //
    //                        Spacer()
    //
    //                        Button {
    //                            viewStore.send(.removeQuery(at: index), animation: .easeInOut)
    //                        } label: {
    //                            Image(systemName: "xmark")
    //                                .font(.caption)
    //                                .foregroundColor(.primary)
    //                        }
    //                    }
    //
    //                    if index != viewStore.queryHistory.count - 1 {
    //                        Divider()
    //                    }
    //                }
    //            }
    //        }
    //        .padding(12)
    //        .background(.regularMaterial)
    //        .cornerRadius(12)
    //        .padding(.horizontal)
    //        .offset(y: proxy.safeAreaInsets.top + 12)
    //        .animation(.easeInOut, value: viewStore.searchFocused)
    //        .transition(.scale(scale: 1.0, anchor: .top))
    //    }
    // }
    .animation(.easeInOut, value: store.searchFocused)
  }
}

// Not Started
extension SearchFeature.View {
  @MainActor
  public func NotStartedView(proxy _: GeometryProxy) -> some View {
    VStack(spacing: 24) {
      Text("(         ) ?")
        .font(.largeTitle)
        .fontWeight(.bold)

      Text("Why not try to search for something?")
        .opacity(0.7)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .overlay {
      HStack(spacing: 28) {
        RoundedRectangle(cornerRadius: 6)
          .fill(.white)
          .frame(width: 6, height: 6)

        RoundedRectangle(cornerRadius: 6)
          .fill(.white)
          .frame(width: 6, height: 6)
      }
      .offset(x: -17, y: -20)
    }
    .ignoresSafeArea()
    .transition(.opacity)
  }
}

// Loading
extension SearchFeature.View {
  @MainActor
  public func LoadingView(proxy: GeometryProxy) -> some View {
    VStack {
      let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)

      ForEach(0..<4, id: \.self) { _ in
        HStack(spacing: 12) {
          ForEach(0..<3, id: \.self) { index in
            VStack {
              RoundedRectangle(cornerRadius: 12)
                .frame(width: 110, height: 160)
                .shimmering(
                  active: true,
                  animation: anim.delay(0.2 * Double(index))
                )
                .opacity(0.3)

              VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                  .frame(width: 110, height: 160)
                  .shimmering(
                    active: true,
                    animation: anim.delay(0.1 + (0.2 * Double(index)))
                  )
                  .frame(width: 110, height: 16)
                  .clipShape(RoundedRectangle(cornerRadius: 6))
                  .opacity(0.2)

                RoundedRectangle(cornerRadius: 4)
                  .frame(width: 110, height: 160)
                  .shimmering(
                    active: true,
                    animation: anim.delay(0.2 + (0.2 * Double(index)))
                  )
                  .frame(width: 40, height: 12)
                  .clipShape(RoundedRectangle(cornerRadius: 6))
                  .opacity(0.3)
              }
            }
            .opacity(store.itemOpacity)
            .animation(.easeInOut(duration: 2.0).repeatForever().delay(0.2 * Double(index)), value: store.itemOpacity)
          }
        }
      }
    }
    .padding(.horizontal)
    .padding(.top, proxy.safeAreaInsets.top)
    .onAppear {
      send(.setItemOpacity(value: Double(0.0)))
    }
  }
}

// Success
extension SearchFeature.View {
  @MainActor
  public func SuccessView(results: [SearchData], proxy _: GeometryProxy) -> some View {
    ASCollectionView(data: results, dataID: \.self) { result, _ in
      Button {
        send(.setInfo(result.url), animation: .easeInOut)
      } label: {
        VStack {
          LazyImage(
            url: URL(string: result.img),
            transaction: .init(animation: .easeInOut(duration: 0.4))
          ) { state in
            if let image = state.image {
              image
                .resizable()
            } else {
              let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)

              RoundedRectangle(cornerRadius: 12)
                .frame(width: 110, height: 160)
                .shimmering(
                  active: true,
                  animation: anim
                )
                .opacity(0.3)
            }
          }
          .scaledToFill()
          .frame(width: 110, height: 160)
          .cornerRadius(12)

          VStack(alignment: .leading) {
            Text(result.title)
              .font(.subheadline)
              .lineLimit(2)
              .multilineTextAlignment(.leading)
              .frame(width: 94, alignment: .leading)

            Text("\(result.currentCountString)/\(result.totalCountString)")
              .font(.caption)
              .frame(width: 94, alignment: .leading)
              .opacity(0.7)
          }
          .foregroundColor(.white)
        }
      }
      .contentShape(Rectangle())
      .frame(width: 110)
    }
    .layout {
      .grid(
        layoutMode: .adaptive(withMinItemSize: 120),
        itemSpacing: 8,
        lineSpacing: 12,
        itemSize: .estimated(110),
        sectionInsets: .init(top: 50, leading: 12, bottom: 0, trailing: 12)
      )
    }
    .onReachedBoundary { boundary in
      if boundary == .bottom, !store.isFetching {
        print("Load next results")
        // Run search logic with page count + 1
        send(.increasePageNumber)
        send(.search)
      }
    }
    .onScroll { contentOffset, _ in
      if 50 + contentOffset.y > 90 {
        if store.headerOpacity < 1.0 {
          send(.setHeaderOpacity(1.0))
        }
      } else {
        send(.setHeaderOpacity((50.0 + contentOffset.y) / CGFloat(90)))
      }
    }
    .ignoresSafeArea()
  }
}

// Error
extension SearchFeature.View {
  @MainActor
  public func ErrorView() -> some View {
    VStack(spacing: 24) {
      Text("(×﹏×)")
        .font(.largeTitle)
        .fontWeight(.bold)

      Text("Nothing was found with that query. Please try a different search term.")
        .opacity(0.7)
    }
  }
}

#Preview("Search") {
  SearchFeature.View(
    store: .init(
      initialState: .init(),
      reducer: { SearchFeature() }
    ),
    animation: Namespace().wrappedValue
  )
}
