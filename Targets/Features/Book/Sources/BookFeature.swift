import Architecture
import Combine
import Nuke
import RelayClient
@preconcurrency import SharedModels
import SwiftUI

@Reducer
public struct BookFeature: Reducer {
    @Dependency(\.relayClient) var relayClient
    @Dependency(\.mainQueue) var mainQueue

    @ObservableState
    public struct State: FeatureState {
        public var infoData: InfoData
        public var item: MediaItem
        public var index: Int
        public var readerMode: ReaderMode = .auto
        public var autoReaderMode: ReaderMode? = nil
        public var mediaItems: [MediaItem]
        public var chapters: [Double: [ImageModel]] = [:]
        public var lastAppendedChapter: [ImageModel] = []

        public init(infoData: InfoData, item: MediaItem, index: Int, mediaItems: [MediaItem]) {
            self.infoData = infoData
            self.item = item
            self.index = index
            self.mediaItems = mediaItems
        }
    }

    @CasePathable
    @dynamicMemberLookup
    public enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        public enum ViewAction: SendableAction {
            case onAppear
            case appendChapter(_ data: [ImageModel])
            case automaticReaderMode(url: String)
            case loadChapter(url: String, number: Double)
        }

        @CasePathable
        @dynamicMemberLookup
        public enum DelegateAction: SendableAction {}

        @CasePathable
        @dynamicMemberLookup
        public enum InternalAction: SendableAction {
            case setAspectRatio(CGFloat?)
        }

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }

    public init() { }

    @ReducerBuilder<State, Action> public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onAppear:
                    return .send(.view(.loadChapter(url: state.item.url, number: state.item.number)))
                case let .loadChapter(url, number):
                    if state.chapters[number] != nil { return .none }
                    return .merge(
                        .run { send in
                            do {
                                let chapterData = try await relayClient.pages(url)
                                await send(.view(.automaticReaderMode(url: chapterData.first ?? "")))

                                let chapter = chapterData.map { ImageModel(url: $0, chapter: number) }
                                await send(.view(.appendChapter(chapter)))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    )
                case .automaticReaderMode(let urlString):
                    guard let url = URL(string: urlString) else { return .none }
                    if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) {
                        if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? {
                            // swiftlint:disable force_cast
                            let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as! Int
                            let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as! Int
                            // swiftlint:enable force_cast
                            // check if aspect ratio is bigger than screen aspect ratio
                            let imageAspect = CGFloat(pixelWidth) / CGFloat(pixelHeight)
                            let screenAspect = UIScreen.main.bounds.width / UIScreen.main.bounds.height

                            if imageAspect < screenAspect {
                                // webtoon
                                print("Detected Webtoon.")
                                state.autoReaderMode = .webtoon
                            } else if imageAspect < 1 && imageAspect > screenAspect {
                                print("Detected Horizontal")
                                state.autoReaderMode = .rtl
                            } else if imageAspect > 1 {
                                print("Detected Horizontal")
                                state.autoReaderMode = .rtl
                            }
                            print("Width: \(pixelWidth), Height: \(pixelHeight)")
                            return .none
                        }
                    }
                    return .none
                case .appendChapter(let data):
                    state.lastAppendedChapter = data
                    if let chapterNumber = data.first?.chapter {
                        state.chapters[chapterNumber] = data
                    }
                    return .none
                }

            case let .internal(internalAction):
                switch internalAction {
                case .setAspectRatio(let aspectRatio):
                    if let aspectRatio = aspectRatio {
                        // Update the state based on the aspect ratio if needed
                        print("Aspect ratio: \(aspectRatio)")
                    } else {
                        // Handle the case where the aspect ratio could not be determined
                        print("Failed to get aspect ratio")
                    }
                    return .none
                }
            }
        }
    }
}
