//
//  PlayerItem.swift
//  ChoutenTCA
//
//  Created by Inumaki on 13.10.23.
//

import AVFoundation
import AVKit
import Foundation

// MARK: - VideoCompositionItem

struct VideoCompositionItem {
  let link: URL
  let headers: [String: String]
  let subtitles: [SubtitleINTERNAL]

  init(
    link: URL,
    headers: [String: String] = [:],
    subtitles: [SubtitleINTERNAL] = []
  ) {
    self.link = link
    self.headers = headers
    self.subtitles = subtitles
  }

  public struct SubtitleINTERNAL {
    let name: String
    let `default`: Bool
    let autoselect: Bool
    let forced: Bool
    let link: URL

    public init(
      name: String,
      default: Bool,
      autoselect: Bool,
      forced: Bool = false,
      link: URL
    ) {
      self.name = name
      self.default = `default`
      self.autoselect = autoselect
      self.forced = forced
      self.link = link
    }
  }
}

// MARK: - PlayerItem

final class PlayerItem: AVPlayerItem {
  static let dashCustomPlaylistScheme = "chouten-mpd"

  let payload: VideoCompositionItem

  private let resourceQueue: DispatchQueue

  enum ResourceLoaderError: Swift.Error {
    case responseError
    case emptyData
    case failedToCreateM3U8
  }

  init(_ payload: VideoCompositionItem) {
    self.payload = payload
    self.resourceQueue = DispatchQueue(label: "playeritem-\(payload.link.absoluteString)", qos: .utility)

    let headers = payload.headers
    let url: URL = if payload.subtitles.isEmpty {
      payload.link
    } else {
      payload.link.change(scheme: Self.hlsCommonScheme)
    }

    let asset = AVURLAsset(
      url: url,
      // TODO: Validate if this is allowed or considered a private api
      options: ["AVURLAssetHTTPHeaderFieldsKey": headers]
    )

    super.init(
      asset: asset,
      automaticallyLoadedAssetKeys: [
        "duration",
        "availableMediaCharacteristicsWithMediaSelectionOptions"
      ]
    )

    asset.resourceLoader.setDelegate(self, queue: resourceQueue)
  }
}

// MARK: AVAssetResourceLoaderDelegate

extension PlayerItem: AVAssetResourceLoaderDelegate {
  func resourceLoader(
    _: AVAssetResourceLoader,
    shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
  ) -> Bool {
//        if payload.source.format == .mpd {
//            if url.pathExtension == "ts" {
//                loadingRequest.redirect = URLRequest(url: url.recoveryScheme)
//                loadingRequest.response = HTTPURLResponse(
//                    url: url.recoveryScheme,
//                    statusCode: 302,
//                    httpVersion: nil,
//                    headerFields: nil
//                )
//                loadingRequest.finishLoading()
//            } else {
//                handleDASHRequest(url, callback)
//            }
//        } else {
    handleHLSRequest(loadingRequest: loadingRequest)
//        }
  }
}

extension URL {
  func change(scheme: String) -> URL {
    var component = URLComponents(url: self, resolvingAgainstBaseURL: false)
    component?.scheme = scheme
    return component?.url ?? self
  }

  var recoveryScheme: URL {
    var component = URLComponents(url: self, resolvingAgainstBaseURL: false)
    component?.scheme = "https"
    return component?.url ?? self
  }
}
