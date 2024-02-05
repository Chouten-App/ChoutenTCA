//
//  AppFeature+View.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import Discover
import GRDB
import Kingfisher
import ModuleSheet
import More
import NukeUI
import Player
import SharedModels
import SwiftUI
import ViewComponents

// MARK: - AppFeature.View + View

extension AppFeature.View: View {
  @MainActor public var body: some View {
    WithViewStore(store, observe: \.`self`) { viewStore in
      GeometryReader { proxy in
        VStack(spacing: 0) {
          Group {
            switch viewStore.state.selected {
            case .home:
              ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                  HStack(alignment: .bottom, spacing: 12) {
                    LazyImage(
                      url: URL(string: "https://pxbar.com/wp-content/uploads/2023/10/anime-boy-pfp.jpg"),
                      transaction: .init(animation: .easeInOut(duration: 0.4))
                    ) { state in
                      if let image = state.image {
                        image
                          .resizable()
                      } else {
                        let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)

                        RoundedRectangle(cornerRadius: 12)
                          .frame(width: 100, height: 100)
                          .shimmering(
                            active: true,
                            animation: anim
                          )
                          .opacity(0.3)
                      }
                    }
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading) {
                      Text("Inumaki")
                        .font(.title2)
                        .fontWeight(.bold)

                      Text("Welcome back ^^")
                        .opacity(0.7)
                    }
                    .padding(.bottom, 12)
                  }
                  .padding(.horizontal)
                  .padding(.bottom, 30)
                  .padding(.top, 60)
                  .blur(radius: showContextMenu || press ? 4 : 0)

                  HStack(spacing: 8) {
                    Text("Continue Watching")
                      .font(.title3)
                      .fontWeight(.bold)

                    Spacer()

                    Text("see all")
                      .font(.footnote)
                      .fontWeight(.semibold)
                      .opacity(0.7)

                    Image(systemName: "chevron.right")
                      .resizable()
                      .scaledToFit()
                      .frame(height: 14)
                      .opacity(0.7)
                  }
                  .padding(.horizontal)
                  .blur(radius: showContextMenu || press ? 4 : 0)

                  ScrollView(.horizontal) {
                    HStack {
                      ForEach(0..<viewStore.mediaItems.count, id: \.self) { index in
                        let item = viewStore.mediaItems[index]

                        let module = viewStore.modules.first { m in
                          m.id == item.moduleID
                        }

                        ContinueCard(
                          item: item,
                          module: module,
                          show: $showContextMenu,
                          press: $press,
                          hoveredIndex: $hoveredIndex,
                          index: index,
                          changeMediaData: $changeMediaData,
                          showAlert: $showAlert,
                          viewStore: viewStore
                        )
                        .blur(radius: (showContextMenu || press) && hoveredIndex != index ? 4.0 : 0.0)
                        .zIndex((showContextMenu || press) && hoveredIndex == index ? 10.0 : 1.0)
                      }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                  }

                  HStack(spacing: 8) {
                    Text("Anime")
                      .font(.title3)
                      .fontWeight(.bold)

                    Spacer()

                    Text("see all")
                      .font(.footnote)
                      .fontWeight(.semibold)
                      .opacity(0.7)

                    Image(systemName: "chevron.right")
                      .resizable()
                      .scaledToFit()
                      .frame(height: 14)
                      .opacity(0.7)
                  }
                  .padding(.horizontal)
                  .blur(radius: showContextMenu || press ? 4 : 0)

                  ScrollView(.horizontal) {
                    HStack {
                      CollectionItemCard()
                    }
                    .padding(.horizontal)
                  }
                  .padding(.bottom, 160)
                }
              }
              .scaleEffect(showContextMenu || press ? 0.95 : 1.0)
              .animation(.easeInOut, value: showContextMenu)
              .animation(.easeInOut, value: press)
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
              .background(.background)
              .overlay {
                if showAlert {
                  Rectangle()
                    .fill(.black.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showAlert)
                }
              }
              .overlay {
                if showAlert {
                  if let changeMediaData {
                    EditThumbnail(original: changeMediaData.image) { url in
                      if let url {
                        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                          var isDirectory: ObjCBool = false
                          if !FileManager.default.fileExists(atPath: documentsDirectory.appendingPathComponent("Databases").path, isDirectory: &isDirectory) {
                            do {
                              try FileManager.default.createDirectory(
                                at: documentsDirectory.appendingPathComponent("Databases"),
                                withIntermediateDirectories: false,
                                attributes: nil
                              )
                              print("Created Database Directory")
                            } catch {
                              print("Error: \(error)")
                            }
                          }

                          var items: [Media] = []

                          do {
                            let dbQueue = try DatabaseQueue(
                              path: documentsDirectory.appendingPathComponent("Databases").appendingPathComponent("chouten.sqlite")
                                .absoluteString
                            )

                            try dbQueue.write { db in
                              // Fetch the Media item using moduleID from the database
                              if var mediaItem = try Media.filter(Column("mediaUrl") == changeMediaData.mediaUrl).fetchOne(db) {
                                // Perform the update in the database
                                mediaItem.image = url

                                try mediaItem.update(db)
                              }

                              items = try Media.fetchAll(db)
                            }
                          } catch {
                            print(error.localizedDescription)
                          }

                          viewStore.send(.view(.updateMediaItems(items)))
                        }

                      } else {
                        showAlert = false
                      }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: showAlert)
                  }
                }
              }
            case .repos:
              VStack {
                Text("REPOS")
              }
              .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .more:
              MoreFeature.View(
                store: store.scope(
                  state: \.more,
                  action: Action.InternalAction.more
                )
              )
            case .discover:
              DiscoverFeature.View(
                store: store.scope(
                  state: \.discover,
                  action: Action.InternalAction.discover
                )
              )
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .bottom) {
          VStack(spacing: 0) {
            ModuleSheetFeature.View(
              store: store.scope(
                state: \.sheet,
                action: Action.InternalAction.sheet
              )
            )
            NavBar(viewStore.selected)
          }
          .offset(y: viewStore.showTabbar ? 0 : proxy.safeAreaInsets.bottom + 120)
          .allowsHitTesting(viewStore.showTabbar)
        }
        .overlay {
          if viewStore.videoUrl != nil, viewStore.videoIndex != nil {
            PlayerFeature.View(
              store: store.scope(
                state: \.player,
                action: Action.InternalAction.player
              )
            )
            // .frame(width: proxy.size.width, height: proxy.size.height)
            .offset(y: viewStore.showPlayer ? 0 : proxy.size.height + 60)
            .transition(.move(edge: .bottom))
            .animation(.easeInOut, value: viewStore.showPlayer)
            .animation(.easeInOut, value: viewStore.videoUrl)
            .animation(.easeInOut, value: viewStore.videoIndex)
          }
        }
        .onAppear {
          viewStore.send(.view(.onAppear))
        }
      }
      .supportedOrientation(viewStore.fullscreen ? .landscape : .portrait)
      .prefersHomeIndicatorAutoHidden(viewStore.fullscreen)
      .preferredColorScheme(
        colorScheme == 0 ? .light :
          colorScheme == 1 ? .dark :
          .none
      )
      .animation(.easeInOut, value: colorScheme)
    }
  }
}

// MARK: - NavBarItem

private struct NavBarItem: View {
  let tab: AppFeature.State.Tab
  var selected: Bool

  var animation: Namespace.ID

  var body: some View {
    VStack(spacing: 4) {
      if selected {
        RoundedRectangle(cornerRadius: 4)
          .frame(width: 20, height: 4)
          .padding(.bottom, 8)
          .foregroundColor(
            .indigo
          )
          .matchedGeometryEffect(id: "indicator", in: animation)
      } else {
        Spacer()
          .frame(height: 12)
      }

      VStack(spacing: 4) {
        Image(systemName: selected ? tab.selected : tab.image)
          .font(.system(size: 18, weight: .bold))
          .contentShape(Rectangle())
          .frame(width: 24, height: 24)

        Text(tab.rawValue)
          .font(.caption)
          .fontWeight(.medium)
      }
      .background {
        if selected {
          Circle()
            .fill(.indigo)
            .frame(minWidth: 200)
            .blur(radius: 20)
            .scaleEffect(1.5)
            .opacity(0.2)
            .matchedGeometryEffect(id: "indicatorBG", in: animation)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: 64, alignment: .top)
    .animation(.spring(response: 0.2), value: selected)
  }
}

extension AppFeature.View {
  // swiftlint:disable identifier_name
  @MainActor
  func NavBar(_ selected: Self.State.Tab) -> some View {
    HStack(alignment: .bottom, spacing: 0) {
      ForEach(State.Tab.allCases, id: \.rawValue) { tab in
        NavBarItem(tab: tab, selected: tab == selected, animation: animation)
          .onTapGesture {
            store.send(.view(.changeTab(tab)))
          }
      }
    }
    .background(.regularMaterial)
    .background(.regularMaterial)
  }
}

// MARK: - EditThumbnail

struct EditThumbnail: View {
  let original: String
  let completion: (String?) -> Void

  @State var imageUrl: String = ""
  @State var imageText: String = ""

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      HStack {
        LazyImage(
          url: URL(string: original),
          transaction: .init(animation: .easeInOut(duration: 0.4))
        ) { state in
          if let image = state.image {
            image
              .resizable()
          } else {
            let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)

            RoundedRectangle(cornerRadius: 8)
              .frame(width: 100, height: 100 / 16 * 9)
              .shimmering(
                active: true,
                animation: anim
              )
              .opacity(0.3)
          }
        }
        .scaledToFill()
        .frame(width: 100, height: 100 / 16 * 9)
        .clipShape(RoundedRectangle(cornerRadius: 8))

        Spacer()

        Image(systemName: "arrow.right")

        Spacer()

        LazyImage(
          url: URL(string: imageUrl),
          transaction: .init(animation: .easeInOut(duration: 0.4))
        ) { state in
          if let image = state.image {
            image
              .resizable()
          } else {
            let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)

            RoundedRectangle(cornerRadius: 8)
              .frame(width: 100, height: 100 / 16 * 9)
              .shimmering(
                active: true,
                animation: anim
              )
              .opacity(0.3)
          }
        }
        .scaledToFill()
        .frame(width: 100, height: 100 / 16 * 9)
        .clipShape(RoundedRectangle(cornerRadius: 8))
      }
      .padding(.vertical, 20)
      .padding(.horizontal)
      .frame(maxWidth: .infinity)

      Text("Change Episode Thumbnail")
        .font(.title2)
        .fontWeight(.bold)
        .padding(.bottom, -6)

      Text("Change the thumbnail of the current episode to the new url provided below:")

      TextField("URL...", text: $imageText)
        .onSubmit {
          imageUrl = imageText
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(.regularMaterial)
        .cornerRadius(6)
        .padding(.bottom, 12)

      Button {
        completion(imageUrl)
      } label: {
        Text("Save")
          .fontWeight(.bold)
          .padding(.vertical, 12)
          .foregroundColor(.primary)
          .frame(maxWidth: .infinity)
          .background {
            RoundedRectangle(cornerRadius: 6)
              .fill(.indigo)
          }
      }
      .padding(.bottom, -8)

      Button {
        completion(nil)
      } label: {
        Text("Cancel")
          .fontWeight(.bold)
          .padding(.vertical, 12)
          .foregroundColor(.primary)
          .frame(maxWidth: .infinity)
          .background {
            RoundedRectangle(cornerRadius: 6)
              .fill(.gray)
          }
      }
    }
    .padding()
    .background(.regularMaterial)
    .cornerRadius(12)
    .padding()
  }
}

// MARK: - ContinueCard

struct ContinueCard: View {
  let item: Media
  let module: Module?
  @Binding var show: Bool
  @GestureState var press: Bool
  @Binding var hoveredIndex: Int
  let index: Int
  @Binding var changeMediaData: Media?
  @Binding var showAlert: Bool
  var viewStore: ViewStoreOf<AppFeature>
  let frame: String

  var formattedValue: String {
    if item.number.truncatingRemainder(dividingBy: 1) == 0 {
      String(format: "%.0f", item.number)
    } else {
      String(item.number)
    }
  }

  init(
    item: Media,
    module: Module?,
    show: Binding<Bool>,
    press: GestureState<Bool>,
    hoveredIndex: Binding<Int>,
    index: Int,
    changeMediaData: Binding<Media?>,
    showAlert: Binding<Bool>,
    viewStore: ViewStoreOf<AppFeature>
  ) {
    self.item = item
    self.module = module
    self._show = show
    self._press = press
    self._hoveredIndex = hoveredIndex
    self.index = index
    self._changeMediaData = changeMediaData
    self._showAlert = showAlert
    self.viewStore = viewStore

    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let module {
      let fileURL = documentsDirectory
        .appendingPathComponent("Frames")
        .appendingPathComponent(module.id)
        .appendingPathComponent(
          item.mediaUrl
            .replacingOccurrences(of: "://", with: "_")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        )
        .appendingPathComponent("frame.jpg")

      print(fileURL.path)

      // https_aniwatch.to_ajax_v2_episode_servers?episodeId=12865

      if FileManager.default.fileExists(atPath: fileURL.path) {
        print("found")
        self.frame = fileURL.absoluteString
      } else {
        print("not found")
        self.frame = item.image
      }
    } else {
      self.frame = item.image
    }
  }

  var body: some View {
    VStack(alignment: .leading) {
      LazyImage(
        url: URL(string: frame),
        transaction: .init(animation: .easeInOut(duration: 0.4))
      ) { state in
        if let image = state.image {
          image
            .resizable()
        } else {
          let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)

          RoundedRectangle(cornerRadius: 12)
            .frame(width: 240, height: 240 / 16 * 9)
            .shimmering(
              active: true,
              animation: anim
            )
            .opacity(0.3)
        }
      }
      .scaledToFill()
      .frame(width: 240, height: 240 / 16 * 9)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .overlay(alignment: .topLeading) {
        HStack(alignment: .top) {
          if let module, let image = module.icon {
            LazyImage(
              url: URL(string: image),
              transaction: .init(animation: .easeInOut(duration: 0.4))
            ) { state in
              if let image = state.image {
                image
                  .resizable()
              } else {
                let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)

                RoundedRectangle(cornerRadius: 4)
                  .frame(width: 24, height: 24)
                  .shimmering(
                    active: true,
                    animation: anim
                  )
                  .opacity(0.3)
              }
            }
            .scaledToFill()
            .frame(width: 24, height: 24)
            .cornerRadius(4)
            .overlay {
              RoundedRectangle(cornerRadius: 4)
                .stroke(.white.opacity(0.4), lineWidth: 0.5)
            }
          }

          Spacer()

          Text(formattedValue)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background {
              Capsule()
                .fill(.regularMaterial)
            }
        }
        .padding(8)
      }
      .overlay(alignment: .bottomLeading) {
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 4)
            .fill(.primary)
            .frame(width: 240 - 24, height: 4)
            .opacity(0.5)

          RoundedRectangle(cornerRadius: 4)
            .fill(.indigo)
            .frame(width: (240 - 24) * (item.current / item.duration), height: 4)
        }
        .padding(8)
      }

      VStack(alignment: .leading) {
        Text(item.title)
          .font(.footnote)
          .fontWeight(.semibold)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: 240 - 24, alignment: .leading)
        // if let description = item.description {
        //    Text(description)
        //        .font(.caption)
        //        .lineLimit(3)
        //        .multilineTextAlignment(.leading)
        //        .opacity(0.7)
        // }
      }
      .padding(.horizontal, 12)
      .frame(maxWidth: 240 - 24, alignment: .leading)
    }
  }
}

// MARK: - CollectionItemCard

struct CollectionItemCard: View {
  var body: some View {
    VStack(alignment: .leading) {
      LazyImage(
        url: URL(string: InfoData.img),
        transaction: .init(animation: .easeInOut(duration: 0.4))
      ) { state in
        if let image = state.image {
          image
            .resizable()
        } else {
          let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)

          RoundedRectangle(cornerRadius: 12)
            .frame(width: 40, height: 240 / 16 * 9)
            .shimmering(
              active: true,
              animation: anim
            )
            .opacity(0.3)
        }
      }
      .scaledToFill()
      .frame(width: 120, height: 160)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .overlay(alignment: .topLeading) {
        LazyImage(
          url: URL(string: "https://cdn.glitch.global/a65741ca-e4a3-4b9c-9f87-1568672f0160/aniwatch.png"),
          transaction: .init(animation: .easeInOut(duration: 0.4))
        ) { state in
          if let image = state.image {
            image
              .resizable()
          } else {
            let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)

            RoundedRectangle(cornerRadius: 12)
              .frame(width: 24, height: 24)
              .shimmering(
                active: true,
                animation: anim
              )
              .opacity(0.3)
          }
        }
        .scaledToFill()
        .frame(width: 24, height: 24)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay {
          RoundedRectangle(cornerRadius: 6)
            .stroke(.white.opacity(0.4), lineWidth: 0.5)
        }
        .padding(8)
      }
      .overlay(alignment: .bottomTrailing) {
        Text("Watching")
          .font(.caption)
          .fontWeight(.bold)
          .padding(.vertical, 4)
          .padding(.horizontal, 8)
          .background {
            Capsule()
              .fill(.regularMaterial)
          }
          .padding(8)
      }

      VStack {
        Text("Title")
          .font(.footnote)
          .fontWeight(.semibold)
          .lineLimit(2)
          .multilineTextAlignment(.leading)

        Text("1/12")
          .font(.caption)
          .fontWeight(.medium)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
          .opacity(0.7)
      }
      .padding(.horizontal, 12)
    }
  }
}

#Preview("App") {
  AppFeature.View(
    store: .init(
      initialState: .init(),
      reducer: { AppFeature() }
    )
  )
}
